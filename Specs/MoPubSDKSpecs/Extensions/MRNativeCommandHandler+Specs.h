//
//  MRNativeCommandHandler+Specs.h
//  MoPubSDK
//
//  Created by Evan Davis on 11/11/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MRNativeCommandHandler.h"
#import "MRCalendarManager.h"
#import "MRPictureManager.h"
#import "MRVideoPlayerManager.h"
#import "MRCommand.h"

@interface MRNativeCommandHandler (Specs) <MRCalendarManagerDelegate, MRPictureManagerDelegate, MRVideoPlayerManagerDelegate, MRCommandDelegate>

@property (nonatomic, strong) MRCalendarManager *calendarManager;

@end
