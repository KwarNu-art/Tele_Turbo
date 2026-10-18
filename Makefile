TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e

INSTALL_TARGET_PROCESSES = Telegraph SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TeleTurbo

TeleTurbo_FILES = src/Tweak.x
TeleTurbo_CFLAGS = -fobjc-arc -O3 -flto -DNDEBUG -Wno-unused-variable -Wno-deprecated-declarations
TeleTurbo_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
TeleTurbo_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Telegraph || true"
