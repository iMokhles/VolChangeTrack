GO_EASY_ON_ME = 1
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = VolChangeTrack
VolChangeTrack_FILES = Tweak.xm
VolChangeTrack_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += volchangetrack
include $(THEOS_MAKE_PATH)/aggregate.mk
