#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <notify.h>

#define kPreferencesPath @"/User/Library/Preferences/com.imokhles.volchangetrack.plist"
#define kPreferencesChanged "com.imokhles.volchangetrack.preferences-changed"

#define kEnableTweak @"enableTweak"

static CFNotificationCenterRef darwinNotifyCenter = CFNotificationCenterGetDarwinNotifyCenter();

@interface VolChangeTrackSwitch : NSObject <FSSwitchDataSource>
@end

@implementation VolChangeTrackSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"VolChangeTrack";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	NSNumber *enableTweakNU = tweakSettings[kEnableTweak];
	BOOL editNum = enableTweakNU ? [enableTweakNU boolValue] : 1;
    return editNum ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
    NSMutableDictionary *mutableDict = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
        case FSSwitchStateOn:
            [mutableDict setObject:[NSNumber numberWithBool:YES] forKey:kEnableTweak];
            break;
        case FSSwitchStateOff:
            [mutableDict setObject:[NSNumber numberWithBool:NO] forKey:kEnableTweak];
            break;
    }
    [mutableDict writeToFile:kPreferencesPath atomically:YES];
	notify_post(kPreferencesChanged);
}

@end
