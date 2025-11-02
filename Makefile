#!/usr/bin/env make -f

# === Project meta ===
APP_NAME       := RDM-Apple-Silicon
IDENTIFIER     := com.ayush.rdm.applesilicon
VERSION        := 1.0

# === Toolchain & arch ===
CXX            := clang++
ARCH           := $(shell uname -m)

# NOTE: NO -fobjc-arc (code uses NSAutoreleasePool/release)
OBJCXXFLAGS    := -std=c++11 -mmacosx-version-min=13.0 -Wall -Wextra -Wno-deprecated-declarations
ARCH_FLAGS     := -arch $(ARCH)

# === Frameworks ===
FRAMEWORKS     := -framework Foundation -framework ApplicationServices -framework AppKit -framework CoreGraphics -framework IOKit

# === Sources/objects ===
SRC            := main.mm SRApplicationDelegate.mm ResMenuItem.mm cmdline.mm utils.mm
OBJ            := $(SRC:.mm=.o)

# === Paths ===
APP            := $(APP_NAME).app
APP_CONT       := $(APP)/Contents
APP_MACOS      := $(APP_CONT)/MacOS
APP_RES        := $(APP_CONT)/Resources
PLIST_DST      := $(APP_CONT)/Info.plist

DMG_NAME       := $(APP_NAME)-$(VERSION).dmg
PKGROOT        := pkgroot
DMGROOT        := dmgroot

PACKAGE_BUILD  := /usr/bin/pkgbuild
PLISTBUDDY     := /usr/libexec/PlistBuddy

.PHONY: all app dmg pkg install clean

# Default: build the app bundle
all: app

# === Build binary ===
SetResX: $(OBJ)
	$(CXX) $(OBJCXXFLAGS) $(ARCH_FLAGS) $^ -o $@ $(FRAMEWORKS)

%.o: %.mm
	$(CXX) $(OBJCXXFLAGS) $(ARCH_FLAGS) -c $< -o $@

# === App bundle ===
app: $(APP)

$(APP): SetResX Resources Info.plist monitor.icns
	mkdir -p $(APP_MACOS) $(APP_RES)
	cp SetResX $(APP_MACOS)/
	cp -r Resources $(APP_CONT)/
	cp Info.plist $(PLIST_DST)
	- rm $(APP_RES)/Icon_512x512.png
	- rm $(APP_RES)/StatusIcon_sel.png
	- rm $(APP_RES)/StatusIcon_sel@2x.png
	mv monitor.icns $(APP_RES)

	# Patch Info.plist metadata (ignore if keys missing)
	- $(PLISTBUDDY) -c "Set :CFBundleName $(APP_NAME)" $(PLIST_DST)
	- $(PLISTBUDDY) -c "Set :CFBundleDisplayName $(APP_NAME)" $(PLIST_DST)
	- $(PLISTBUDDY) -c "Set :CFBundleIdentifier $(IDENTIFIER)" $(PLIST_DST)
	- $(PLISTBUDDY) -c "Set :CFBundleShortVersionString $(VERSION)" $(PLIST_DST)
	- $(PLISTBUDDY) -c "Set :CFBundleVersion $(VERSION)" $(PLIST_DST)

# === DMG (distribute this on Releases) ===
dmg: app
	rm -rf $(DMGROOT)
	mkdir -p $(DMGROOT)
	cp -R "$(APP)" $(DMGROOT)/
	hdiutil create -fs HFS+ -volname "$(APP_NAME)" -srcfolder "$(DMGROOT)" -ov "$(DMG_NAME)"
	@echo "Created $(DMG_NAME)"

# === Optional: .pkg (not usually needed for menu bar apps) ===
pkg: app
	rm -rf $(PKGROOT)
	mkdir -p $(PKGROOT)/Applications
	cp -R "$(APP)" $(PKGROOT)/Applications/
	$(PACKAGE_BUILD) --root $(PKGROOT)/ --identifier $(IDENTIFIER) \
	  --version $(VERSION) "$(APP_NAME)-$(VERSION).pkg"
	@echo "Created $(APP_NAME)-$(VERSION).pkg"

# === Optional: install locally ===
install: app
	cp -R "$(APP)" /Applications/
	@echo "Installed to /Applications/$(APP)"

# === Clean ===
clean:
	rm -f SetResX
	rm -f *.o
	rm -f *icns
	rm -rf "$(APP)"
	rm -rf $(PKGROOT) $(DMGROOT)
	rm -f *.pkg *.dmg

# Build .icns from the PNG icon
monitor.icns: monitor.png
	sips -s format icns monitor.png --out monitor.icns