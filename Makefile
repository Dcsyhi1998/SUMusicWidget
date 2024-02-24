ARCHS = arm64 arm64e
DEBUG = 0
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

THEOS_DEVICE_IP=localhost
THEOS_DEVICE_PORT=2222

THEOS_PACKAGE_SCHEME=rootless
TARGET := iphone:clang:15.6:14.0
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SUMusicWidget

$(BUNDLE_NAME)_FILES = $(wildcard Widget/*.m) $(wildcard Widget/Classes/*.m)
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_INSTALL_PATH = /Library/Airaw/Widgets/Controls
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = MediaRemote


include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	-@install.exec "killall -9 Preferences"
	@install.exec "uiopen prefs:root=Airaw"

after-package::
	-@rm -rf .theos
	@rm -rf .DS_Store