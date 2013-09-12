//
// Copyright (c) 2013 MoPub. All rights reserved.
//


#import "FakeEKEventStore.h"

@implementation FakeEKEventStore

- (void)dealloc
{
    self.requestAccessCompletionHandler = nil;
    [super dealloc];
}

#pragma mark - API Overrides

- (void)requestAccessToEntityType:(EKEntityType)entityType completion:(EKEventStoreRequestAccessCompletionHandler)completion
{
    self.requestAccessCompletionHandler = completion;
}

- (BOOL)saveEvent:(EKEvent *)event span:(EKSpan)span error:(NSError **)error
{
    if (self.shouldFailToSaveEvent) {
        return NO;
    } else {
        self.lastSavedEvent = event;
        return YES;
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
// XXX jren
// iOS 7 requires actual permission to access the calendar. Return nil for now
// and investigate later.
- (EKCalendar *)defaultCalendarForNewEvents
{
    return nil;
}
#endif

#pragma mark -

- (void)simulateGrantingAccess
{
    if (self.requestAccessCompletionHandler) {
        self.requestAccessCompletionHandler(YES, nil);
    }
}

- (void)simulateDenyingAccess
{
    if (self.requestAccessCompletionHandler) {
        self.requestAccessCompletionHandler(NO, [NSErrorFactory genericError]);
    }
}

@end
