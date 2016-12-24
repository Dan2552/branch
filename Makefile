PWD=$(shell pwd)
APP_NAME=branch
BUILD_PATH=$(PWD)/build
SOURCES=$(shell ls src/*.swift)

build: prepare cart compile

clean:
	rm -rf build
	rm -rf Carthage

prepare:
	rm -rf build
	mkdir build

cart:
	[[ -d Carthage/Build/Mac ]] || carthage bootstrap --platform macOS
	cp -R Carthage/Build/Mac/*.framework build/

compile:
	swiftc \
		-sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
		-o $(BUILD_PATH)/$(APP_NAME) \
		-target x86_64-apple-macosx10.12 \
		-F $(PWD)/Carthage/Build/Mac \
		-emit-executable \
		-Xlinker -rpath -Xlinker @executable_path/ \
		$(SOURCES)
