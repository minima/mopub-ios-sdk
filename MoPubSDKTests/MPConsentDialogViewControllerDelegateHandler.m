//
//  MPConsentDialogViewControllerDelegateHandler.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPConsentDialogViewControllerDelegateHandler.h"

@implementation MPConsentDialogViewControllerDelegateHandler

- (void)consentDialogViewControllerDidReceiveConsentResponse:(BOOL)response consentDialogViewController:(MPConsentDialogViewController *)consentDialogViewController { if (self.consentDialogViewControllerDidReceiveConsentResponse) self.consentDialogViewControllerDidReceiveConsentResponse(response, consentDialogViewController); }
- (void)consentDialogViewControllerWillDisappear:(MPConsentDialogViewController *)consentDialogViewController { if (self.consentDialogViewControllerWillDisappear) self.consentDialogViewControllerWillDisappear(consentDialogViewController); }

@end
