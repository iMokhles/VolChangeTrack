GO_EASY_ON_ME = 1

TARGET = iphone:clang:latest:7.0
ARCHS = armv7 arm64

THEOS_DEVICE_IP = 192.168.2.103
THEOS_DEVICE_PORT = 22
THEOS_PACKAGE_DIR_NAME = deb

include theos/makefiles/common.mk

TWEAK_NAME = VolChangeTrack
VolChangeTrack_FILES = Tweak.xm
VolChangeTrack_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete
after-install::
	install.exec "killall -9 backboardd"
