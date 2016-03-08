PWD=$(shell pwd)
APP_NAME=branch
LIB_PATH=Frameworks
BUILD_PATH=$(PWD)/build
LIB_BUILD_PATH=$(BUILD_PATH)/$(LIB_PATH)
LIBS = Swiftline PySwiftyRegex
SOURCES =$(shell ls src/*.swift)

build: clean cart $(LIBS)
	xcrun -sdk macosx swiftc $(SOURCES) \
		-o $(BUILD_PATH)/$(APP_NAME) \
		-I $(LIB_BUILD_PATH) \
		-L $(LIB_BUILD_PATH) \
		-Xlinker -rpath \
		-Xlinker @executable_path/ \
		-v

$(LIBS):
	mkdir -p $(LIB_BUILD_PATH)
	xcrun -sdk macosx swiftc \
		-emit-library \
		-o $(LIB_BUILD_PATH)/lib$@.dylib \
		-Xlinker -install_name \
		-Xlinker @rpath/$(LIB_PATH)/lib$@.dylib \
		-emit-module \
		-emit-module-path $(LIB_BUILD_PATH)/$@.swiftmodule \
		-module-name $@ \
		-module-link-name $@ \
		-v \
		Frameworks/$@/*.swift

cart:
	carthage update --no-build
	mkdir Frameworks
	mkdir Frameworks/PySwiftyRegex
	mkdir Frameworks/Swiftline

	cp Carthage/Checkouts/PySwiftyRegex/PySwiftyRegex/*.swift Frameworks/PySwiftyRegex/
	cp Carthage/Checkouts/swiftline/Source/*.swift Frameworks/Swiftline/

clean:
	rm -rf Frameworks
	rm -rf build
