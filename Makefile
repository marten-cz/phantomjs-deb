# full operation: make src_delete src_import ppa_upload

# define variables
# - to get the codename => $ lsb_release -c -s
PKGNAME="phantomjs"
VERSION="1.6.0"
CODENAME="precise"

PWD	:= $(shell pwd)
TMP_DIR	:= $(PWD)/tmp
SRC_DIR	:= $(TMP_DIR)/$(PKGNAME)
SRC_TAR	:= http://phantomjs.googlecode.com/files/phantomjs-1.6.0-linux-i686-dynamic.tar.bz2

DESTDIR=""

all: build

mydistclean: src_delete deb_clean

#################################################################################
#		node src handling						#
#################################################################################

src_import:
	mkdir -p $(SRC_DIR)
	cd $(SRC_DIR) && wget $(SRC_TAR)
	cd $(SRC_DIR) && tar -jxvf $(SRC_DIR)/phantomjs-1.6.0-linux-i686-dynamic.tar.bz2
	mv $(SRC_DIR)/phantomjs-1.6.0-linux-i686-dynamic/* $(SRC_DIR)/
	rm -rf $(SRC_DIR)/phantomjs-1.6.0-linux-i686-dynamic.tar.bz2

src_delete:
	rm -rf $(SRC_DIR)

#################################################################################
#		classic targets (use by dpkg)					#
#################################################################################

clean:
	#(cd $(SRC_DIR) && qmake && make clean; true)

build:
	#(cd $(SRC_DIR) && qmake && make)

install:
	mkdir -p $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/opt/phantomjs
	cp -r $(SRC_DIR)/* $(DESTDIR)/opt/phantomjs
	chmod 0777 $(DESTDIR)/opt/phantomjs/bin/phantomjs
	ln -s /opt/phantomjs/bin/phantomjs $(DESTDIR)/usr/bin/phantomjs
	#mkdir -p $(DESTDIR)/usr/share/doc/phantomjs
	#cp -a $(SRC_DIR)/examples $(DESTDIR)/usr/share/doc/phantomjs

#################################################################################
#		deb package handling						#
#################################################################################

deb_base_build:
	cp -a debian-base debian
	for i in debian/*; do sed -i s/lucid/$(CODENAME)/g $$i; done

deb_src_build:
	debuild -S -k'9007FC14' -I.git

deb_bin_build:
	debuild -i -us -uc -b

deb_upd_changelog:
	dch --newversion $(VERSION)~$(CODENAME)1~ppa`date +%Y%m%d%H%M` --maintmaint --force-bad-version --distribution `lsb_release -c -s` Another build

deb_clean:
	rm -fr ./debian
	rm -f ../$(PKGNAME)_$(VERSION)~$(CODENAME)1~ppa*

ppa_upload: src_delete src_import clean deb_clean deb_base_build deb_upd_changelog deb_src_build
	dput testing-ppa ../$(PKGNAME)_$(VERSION)~$(CODENAME)1~ppa*_source.changes 
