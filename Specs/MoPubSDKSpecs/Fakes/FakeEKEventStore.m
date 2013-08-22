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
