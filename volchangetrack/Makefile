GO_EASY_ON_ME = 1
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

BUNDLE_NAME = VolChangeTrack
VolChangeTrack_FILES = Switch.xm
VolChangeTrack_FRAMEWORKS = UIKit
VolChangeTrack_LIBRARIES = flipswitch
VolChangeTrack_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
