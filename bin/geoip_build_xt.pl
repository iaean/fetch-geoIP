#!/usr/bin/perl
#
#	Converter for MaxMind CSV database to binary, for xt_geoip
#	Copyright © Jan Engelhardt <jengelh@medozas.de>, 2008
#
#	Use -b argument to create big-endian tables.

use Getopt::Long;
use IO::Handle;
use strict;

my %country;
my %names;

my $mode = "VV";
my $target_dir = "/usr/share/xt_geoip/LE";

&Getopt::Long::Configure(qw(bundling));
&GetOptions(
  "d=s" => \$target_dir,
  "b"   => sub { $mode = "NN"; },
);

if (!-d $target_dir) {
  print STDERR "Target directory $target_dir does not exist.\n";
  exit 1; }

# "1.0.0.0","1.0.0.255","16777216","16777471","AU","Australia"
while (<>) {
  chomp;  # avoid \n on last field
  my @row = split(/,/);
  (my $cc = $row[4]) =~ s/^"(.*)"$/$1/;
  (my $cn = $row[5]) =~ s/^"(.*)"$/$1/;
  (my $nipf = $row[2]) =~ s/^"(.*)"$/$1/;
  (my $nipl = $row[3]) =~ s/^"(.*)"$/$1/;

  if (!defined($country{$cc})) {
    $country{$cc} = [];
    $names{$cc} = $cn; }
  my $c = $country{$cc};
  push(@$c, [$nipf, $nipl]);
  if ($. % 4096 == 0) { print STDERR "\r\e[2K$. entries"; } }

print STDERR "\r\e[2K$. entries total\n";

foreach my $iso_code (sort keys %country) {
  printf "%5u ranges for %s %s", scalar(@{$country{$iso_code}}), $iso_code, $names{$iso_code};
  open(my $fh, "> $target_dir/".uc($iso_code).".iv4");
  foreach my $range (@{$country{$iso_code}}) {
    print $fh pack($mode, $range->[0], $range->[1]); }
  close $fh;
  printf " wrote to %s\n", $target_dir."/".uc($iso_code).".iv4"; }
