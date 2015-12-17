GEOIP_UPDATE = /usr/bin/geoipupdate
MAXMIND_CDN = http://geolite.maxmind.com/download/geoip/database

all: bin csv xt ipdb

bin: geoipupdate GeoLite/GeoLiteASNumv6.dat

csv: csv/GeoIPCountryWhois.csv \
	csv/GeoIPv6.csv csv/GeoLiteCityv6.csv \
	csv/GeoLiteCity-Blocks.csv \
	csv/GeoIPASNum2.csv csv/GeoIPASNum2v6.csv \
	csv/GeoLite2-City-Blocks-IPv4.csv csv/GeoLite2-Country-Blocks-IPv4.csv

xt: xt_geoip/LE/DE.iv4

ipdb: bng/IPDB.csv bng/IPDB6.csv

.SECONDARY:

bng/IPDB.csv: csv/GeoIPCountryWhois.csv
	mkdir -p $(dir $@)
	./bin/geoip_build_ipdb.pl -4 $< > $@
bng/IPDB6.csv: csv/GeoIPv6.csv
	mkdir -p $(dir $@)
	./bin/geoip_build_ipdb.pl -6 $< > $@

xt_geoip/LE/%.iv4: csv/GeoIPCountryWhois.csv
	mkdir -p $(dir $@)
	./bin/geoip_build_xt.pl -d $(dir $@) $<

geoipupdate:
	mkdir -p GeoLite
	$(GEOIP_UPDATE) -f GeoIP.conf -d GeoLite/

GeoLite/GeoLiteASNumv6.dat: zip/GeoIPASNumv6.dat.gz
	mkdir -p $(dir $@)
	zcat $< > $@
	touch $@
	
# legacy BIN ASv6
zip/GeoIPASNumv6.dat.gz:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/asnum/GeoIPASNumv6.dat.gz" -O $@.download
	mv $@.download $@

# v2 CSV
zip/GeoLite2-City.zip:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/GeoLite2-City-CSV.zip" -O $@.download
	mv $@.download $@
zip/GeoLite2-Country.zip:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/GeoLite2-Country-CSV.zip" -O $@.download
	mv $@.download $@

# legacy CSV
zip/GeoLiteCountry.csv.zip:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/GeoIPCountryCSV.zip" -O $@.download
	mv $@.download $@
zip/GeoIPv6.csv.gz:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/GeoIPv6.csv.gz" -O $@.download
	mv $@.download $@
zip/GeoLiteASNum.csv.zip:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/asnum/GeoIPASNum2.zip" -O $@.download
	mv $@.download $@
zip/GeoLiteASNumv6.csv.zip:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/asnum/GeoIPASNum2v6.zip" -O $@.download
	mv $@.download $@
zip/GeoLiteCity.zip:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/GeoLiteCity_CSV/GeoLiteCity-latest.zip" -O $@.download
	mv $@.download $@
zip/GeoLiteCityv6.csv.gz:
	mkdir -p $(dir $@)
	wget -nv  "$(MAXMIND_CDN)/GeoLiteCityv6-beta/GeoLiteCityv6.csv.gz" -O $@.download
	mv $@.download $@

csv/GeoIPv6.csv: zip/GeoIPv6.csv.gz
	mkdir -p $(dir $@)
	zcat $< > $@
	touch $@
csv/GeoLiteCityv6.csv: zip/GeoLiteCityv6.csv.gz
	mkdir -p $(dir $@)
	zcat $< > $@
	touch $@

csv/GeoIPCountryWhois.csv: zip/GeoLiteCountry.csv.zip
	mkdir -p $(dir $@)
	unzip -o -d $(dir $@) $<
	touch $@
csv/GeoLiteCity-%.csv: zip/GeoLiteCity.zip
	mkdir -p $(dir $@)
	unzip -o -j -d $(dir $@) $<
	touch $@

csv/GeoIPASNum2.csv: zip/GeoLiteASNum.csv.zip
	mkdir -p $(dir $@)
	unzip -o -d $(dir $@) $<
	touch $@
csv/GeoIPASNum2v6.csv: zip/GeoLiteASNumv6.csv.zip
	mkdir -p $(dir $@)
	unzip -o -d $(dir $@) $<
	touch $@

csv/GeoLite2-City-%.csv: zip/GeoLite2-City.zip
	mkdir -p $(dir $@)
	unzip -o -j -d $(dir $@) $< GeoLite2-*/GeoLite2-*
	touch $@
csv/GeoLite2-Country-%.csv: zip/GeoLite2-Country.zip
	mkdir -p $(dir $@)
	unzip -o -j -d $(dir $@) $< GeoLite2-*/GeoLite2-*
	touch $@

.PHONY: all bin csv xt ipdb clean distclean test

clean:
	rm -Rf csv
	rm -Rf bng
	rm -Rf xt_geoip

distclean: clean
	rm -Rf zip
	rm -Rf GeoLite
