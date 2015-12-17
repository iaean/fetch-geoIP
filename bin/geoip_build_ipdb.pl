#!/usr/bin/perl
#
#	Converter for MaxMind CSV database to CSV for BNG
#	Copyright © Andreas Schulze <asl@iaean.net>, 2015

use Getopt::Long;
use IO::Handle;
use strict;

my %country;
my %names;

my $mode = 4;

&Getopt::Long::Configure(qw(bundling));
&GetOptions(
  "4"   => sub { $mode = 4; },
  "6"   => sub { $mode = 6; },
);

my $inject_rfc1918 = '"167772160","184549375","x","y","X0","z","10.0.0.0/8"
"2886729728","2887778303","x","y","X1","z","172.16.0.0/12"
"3232235520","3232301055","x","y","X2","z","192.168.0.0/16"';

my $inject_rfc4193 = 'fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,X0,fc00::/7 ULA,0';

# "2001:256::", "2001:256:ffff:ffff:ffff:ffff:ffff:ffff", "42540535540417026290624237364582547456", "42540535619645188804888574958126497791", "CN", "China"
# "1.0.0.0","1.0.0.255","16777216","16777471","AU","Australia"

while (<>) {
  chomp;  # avoid \n on last field
  my @row = split(/"[ \t]*,[ \t]*"/);
  (my $cc = $row[4]) =~ s/^"(.*)"$/$1/;
  (my $cn = $row[5]) =~ s/^(.*)"$/$1/;
  (my $nipf = $row[2]) =~ s/^"(.*)"$/$1/;
  (my $nipl = $row[3]) =~ s/^"(.*)"$/$1/;
  (my $ipf = $row[0]) =~ s/^"(.*)$/$1/;
  (my $ipl = $row[1]) =~ s/^"(.*)"$/$1/;
  $cn =~ s/^(.*), (.*)$/$1/;

  if (!defined($country{$cc})) {
    $country{$cc} = [];
    $names{$cc} = $cn; }
  my $c = $country{$cc};
  if ($mode == 4) { push(@$c, [$nipf, $nipl]); }
  elsif ($mode == 6) { push(@$c, [$ipf, $ipl]); }
  if ($. % 4096 == 0) { print STDERR "\r\e[2K$. entries"; } }

print STDERR "\r\e[2K$. entries total\n";

if ($mode == 4) { print $inject_rfc1918, "\n"; }
elsif ($mode == 6) { print $inject_rfc4193, "\n"; }

foreach my $iso_code (sort keys %country) {
  printf STDERR "%5u ranges for %s %s\n", scalar(@{$country{$iso_code}}), $iso_code, $names{$iso_code};
  foreach my $range (@{$country{$iso_code}}) {
    if ($mode == 4) {
      printf "\"%d\",\"%d\",\"x\",\"y\",\"%s\",\"z\",\"%s\"\n", $range->[0], $range->[1], $iso_code, $names{$iso_code}; }
    elsif ($mode == 6) {
      printf "%s-%s,%s,%s,0\n", $range->[0], $range->[1], $iso_code, $names{$iso_code}; } } }
