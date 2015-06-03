//
//  VolChangeTrack.h
//  VolChangeTrack
//
//  Created by Mokhles Hussien & Timm Kandziora on 02.06.15.
//  Copyright (c) 2015 Mokhles Hussien & Timm Kandziora. All rights reserved.
//

#import <substrate.h>

@interface VolumeControl : NSObject
+(id)sharedVolumeControl;

- (void)decreaseVolume;
- (void)increaseVolume;
-(BOOL)_isMusicPlayingSomewhere;
-(float)getMediaVolume;
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (_Bool)togglePlayPause;
- (_Bool)changeTrack:(int)arg1;
- (float)setVolume:(float)vol;
@end
