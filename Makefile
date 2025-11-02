#!/usr/bin/env make -f

PREFIX=/usr
IDENTIFIER=net.alkalay.RDM
VERSION=2.2

# Toolchain & arch
CXX := clang++
ARCH := $(shell uname -m)

# ObjC++ flags (NO ARC: this code uses NSAutoreleasePool/release)
OBJCXXFLAGS := -std=c++11 -mmacosx-version-min=13.0 -Wall -Wextra -Wno-deprecated-declarations
ARCH_FLAGS := -arch $(ARCH)

PACKAGE_BUILD=/usr/bin/pkgbuild

# Frameworks needed by RDM (Quartz/IOKit bits too)
FRAMEWORKS := -framework Foundation -framework ApplicationServices -framework AppKit -framework CoreGraphics -framework IOKit

# Sources/objects
SRC := main.mm SRApplicationDelegate.mm ResMenuItem.mm cmdline.mm utils.mm
OBJ := $(SRC:.mm=.o)

.PHONY: all build pkg dmg install clean

all: RDM.app

# App bundle
RDM.app: SetResX Resources Info.plist monitor.icns
	mkdir -p RDM.app/Contents/MacOS/
	cp SetResX RDM.app/Contents/MacOS/
	cp -r Info.plist Resources RDM.app/Contents
	- rm RDM.app/Contents/Resources/Icon_512x512.png
	- rm RDM.app/Contents/Resources/StatusIcon_sel.png
	- rm RDM.app/Contents/Resources/StatusIcon_sel@2x.png
	mv monitor.icns RDM.app/Contents/Resources

# Link the CLI binary that the app bundles
SetResX: $(OBJ)
	$(CXX) $(OBJCXXFLAGS) $(ARCH_FLAGS) $^ -o $@ $(FRAMEWORKS)

# Compile each ObjC++ source
%.o: %.mm
	$(CXX) $(OBJCXXFLAGS) $(ARCH_FLAGS) -c $< -o $@

# Make an .icns from the provided .png
%.icns: %.png
	sips -s format icns $< --out $@

# Packaging (optional)
pkg: RDM.app
	mkdir -p pkgroot/Applications
	mv $< pkgroot/Applications/
	$(PACKAGE_BUILD) --root pkgroot/ --identifier $(IDENTIFIER) \
		--version $(VERSION) "RDM-$(VERSION).pkg"
	rm -f RDM.pkg
	ln -s RDM-$(VERSION).pkg RDM.pkg

dmg: pkg
	mkdir -p dmgroot
	cp RDM-$(VERSION).pkg dmgroot/
	rm -f RDM-$(VERSION).dmg
	hdiutil makehybrid -hfs -hfs-volume-name "RDM $(VERSION)" \
		-o "RDM-$(VERSION).dmg" dmgroot/
	rm -f RDM.dmg
	ln -s RDM-$(VERSION).dmg RDM.dmg

# Install convenience (copies app to /Applications)
install: RDM.app
	cp -R RDM.app /Applications/

clean:
	rm -f SetResX
	rm -f *.o
	rm -f *icns
	rm -rf RDM.app
	rm -rf pkgroot dmgroot
	rm -f *.pkg *.dmg