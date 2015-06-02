#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

#define kPreferencesPath @"/User/Library/Preferences/com.imokhles.volchangetrack.plist"
#define kPreferencesChanged "com.imokhles.volchangetrack.preferences-changed"

#define kEnableTweak @"enableTweak"

static BOOL changeTrackBOOL;
NSTimer *timer;

@interface VolumeControl : NSObject
- (void)decreaseVolume;
- (void)increaseVolume;
@end


@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (_Bool)togglePlayPause;
- (_Bool)changeTrack:(int)arg1;
@end

static void reloadChangeTrackPrefs() {
	NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];

	NSNumber *tweakEnabledKey = tweakSettings[kEnableTweak];
    changeTrackBOOL = tweakEnabledKey ? [tweakEnabledKey boolValue] : 0;
}

static void handleChangeTrackUpdate() {
	reloadChangeTrackPrefs();
}

static void changeTrackSBInit() {
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *block) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handleChangeTrackUpdate, CFSTR(kPreferencesChanged), NULL, 0);
		handleChangeTrackUpdate();
 
     }];
}

static void changeTrack(int trackNumber, id target) {
	[[objc_getClass("SBMediaController") sharedInstance] changeTrack:trackNumber];
}

static void toggleTrack() {
	[[objc_getClass("SBMediaController") sharedInstance] togglePlayPause];
}

%hook SpringBoard
- (id)init {
	SpringBoard *SB = %orig;
	changeTrackSBInit();
	return SB;
}
- (void)_lockButtonDown:(id)arg1 fromSource:(int)arg2 {
	if (changeTrackBOOL) {
		toggleTrack();
	} else {
		%orig;
	}
}
- (void)_lockButtonUp:(id)arg1 fromSource:(int)arg2  {
	if (changeTrackBOOL) {
		return;
	} else {
		%orig;
	}
}
%end

%hook VolumeControl

- (void)increaseVolume {
	if (changeTrackBOOL) {
		changeTrack(1, self);
	} else {
		%orig;
	}
}

- (void)decreaseVolume {
	if (changeTrackBOOL) {
		changeTrack(-1, self);
	} else {
		%orig;
	}
}
// supports ( Activator )
- (void)_changeVolumeBy:(CGFloat)arg1 {
	if (changeTrackBOOL) {
		if (arg1 > 0) {
			[self increaseVolume];
		} else {
			[self decreaseVolume];
		}
	} else {
		%orig;
	}
}
%end
