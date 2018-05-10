//
//  MPConsentDialogViewControllerDelegateHandler.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPConsentDialogViewController.h"

@interface MPConsentDialogViewControllerDelegateHandler : NSObject <MPConsentDialogViewControllerDelegate>

@property (nonatomic, copy, nullable) void (^consentDialogViewControllerDidReceiveConsentResponse)(BOOL response, MPConsentDialogViewController * _Nullable consentDialogViewController);
@property (nonatomic, copy, nullable) void (^consentDialogViewControllerWillDisappear)(MPConsentDialogViewController * _Nullable consentDialogViewController);

@end
