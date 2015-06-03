//
//  Tweak.xm
//  VolChangeTrack
//
//  Created by Mokhles Hussien & Timm Kandziora on 02.06.15.
//  Copyright (c) 2015 Mokhles Hussien & Timm Kandziora. All rights reserved.
//

#import "VolChangeTrack.h"

#define kPreferencesPath @"/User/Library/Preferences/com.imokhles.volchangetrack.plist"
#define kPreferencesChanged "com.imokhles.volchangetrack.preferences-changed"

#define kEnableTweak @"enableTweak"

static BOOL volChangeTrackEnabled = YES;

static int lastButtonPressed; // Volume Down is -1, Volume Up is 1
static float lastVolume;
static NSTimeInterval lastTimePressed;

static void ResetVolume()
{
	[[objc_getClass("SBMediaController") sharedInstance] setVolume:lastVolume];
}

static void ToggleTrack()
{
	ResetVolume();
	[[objc_getClass("SBMediaController") sharedInstance] togglePlayPause];
}

static void ChangeTrack(int trackNumber)
{
	ResetVolume();
	[[objc_getClass("SBMediaController") sharedInstance] changeTrack:trackNumber];
}

%hook VolumeControl

/*

BUG: Holding volume up/down now changes tracks fast instead of continuously turning volume up/down
POSSIBLE FIX: Check the time stamps; if the time between the time stamps is really low then maybe the bug above occured

*/

- (void)increaseVolume
{
	if (volChangeTrackEnabled) {
		if (lastButtonPressed == 1) {
			if (lastTimePressed + 300 >= [[NSDate date] timeIntervalSince1970] * 1000  && [self _isMusicPlayingSomewhere]) {
				lastTimePressed = [[NSDate date] timeIntervalSince1970] * 1000;
				ChangeTrack(1);
				return;
			}
		} else if (lastButtonPressed == -1) {
			if (lastTimePressed + 300 >= [[NSDate date] timeIntervalSince1970] * 1000) {
				lastTimePressed = [[NSDate date] timeIntervalSince1970] * 1000;
				ToggleTrack();
				return;
			}
		}

		lastButtonPressed = 1;
		lastTimePressed = [[NSDate date] timeIntervalSince1970] * 1000;
	}

	lastVolume = [self getMediaVolume];

	%orig();
}

- (void)decreaseVolume
{
	if (volChangeTrackEnabled) {
		if (lastButtonPressed == -1) {
			if (lastTimePressed + 300 >= [[NSDate date] timeIntervalSince1970] * 1000  && [self _isMusicPlayingSomewhere]) {
				lastTimePressed = [[NSDate date] timeIntervalSince1970] * 1000;
				ChangeTrack(-1);
				return;
			}
		} else if (lastButtonPressed == 1) {
			if (lastTimePressed + 300 >= [[NSDate date] timeIntervalSince1970] * 1000) {
				lastTimePressed = [[NSDate date] timeIntervalSince1970] * 1000;
				ToggleTrack();
				return;
			}
		}

		lastButtonPressed = -1;
		lastTimePressed = [[NSDate date] timeIntervalSince1970] * 1000;
	}

	lastVolume = [self getMediaVolume];

	%orig();
}

/*
// supports ( Activator )
- (void)_changeVolumeBy:(CGFloat)arg1
{
	if (volChangeTrackEnabled) {
		if (arg1 > 0) {
			[self increaseVolume];
		} else {
			[self decreaseVolume];
		}
	} else {
		%orig;
	}
}
*/

%end

static void ReloadSettings()
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];

	if (settings) {
		if ([settings objectForKey:kEnableTweak]) {
			volChangeTrackEnabled = [[settings objectForKey:kEnableTweak] boolValue];
		}
	}

	[settings release];
}

%ctor {
	@autoreleasepool {
		ReloadSettings();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR(kPreferencesChanged), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}
