//
//  MyFiziq-Turnkey
//
//  Copyright (c) 2018-2020 MyFiziq. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "MYQTKSubViewOnboarding.h"
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>
#import <MyFiziqSDKOnboardingView/MyFiziqOnboardingView.h>
#import "MyFiziqTurnkey.h"

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKSubViewOnboarding () <MyFiziqOnboardingViewDelegate, MyFiziqOnboardingViewDatasource>
@property (strong, nonatomic) MyFiziqOnboardingView *viewOnboarding;
@end

@implementation MYQTKSubViewOnboarding

#pragma mark - Properties

- (MyFiziqOnboardingView *)viewOnboarding {
  if (!_viewOnboarding) {
    _viewOnboarding = [[MyFiziqOnboardingView alloc] init];
    _viewOnboarding.delegate = self;
    _viewOnboarding.datasource = self;
  }
  return _viewOnboarding;
}

#pragma mark - Methods

- (void)commonInit {
  [self.view addSubview:self.viewOnboarding];
}

- (void)commonSetContraints {
  [self.viewOnboarding autoPinEdgesToSuperviewEdges];
}

- (void)returnToHomeScreen {
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self dismissViewControllerAnimated:NO completion:^{
      self.viewOnboarding.hidden = NO;
    }];
  }];
}

// This method handles the call to MyFiziq to initiate the avatar creation process.
- (void)beginAvatarCreationProcess {
  // REQUIRED: After user details are updated, the MyFiziq avatar creation process can now be initiated.
  // NOTE: This process will present a capture screen modally, with the calling view controller appearing when the capture process completes.
  [[MyFiziqSDKCoreLite shared] initiateAvatarCreationWithOptions:nil withMiscellaneousData:[MyFiziqTurnkey shared].miscData fromViewController:self completion:^(NSError * _Nullable errCapture) {
      if (errCapture) {
          switch (errCapture.code) {
              case MFZSdkErrorCodeOKCaptureCancel:
              case MFZSdkErrorCodeCancelCreation: {
                  [self returnToHomeScreen];
                  break;
              }
              default: {
                  NSString *errTitle = errCapture.localizedDescription ? errCapture.localizedDescription : @"Error";
                  NSString *errBody = errCapture.localizedRecoverySuggestion ? errCapture.localizedRecoverySuggestion : @"Failed to start the measurement creation process. Please try again or contact support.";
                  id<MyFiziqCommonAlertDelegate> alert = MFZAlert(MyFiziqTurnkeyCommon, errTitle, errBody);
                  [alert addAction:[[MyFiziqCommonAlertAction alloc] initWithTitle:@"OK" style:MFZAlertActionStyleHighlighted block:^{
                      [self returnToHomeScreen];
                  }]];
                  [alert showWithOverlay:YES];
                  break;
              }
          }
      } else {
          [[MyFiziqTurnkey shared] refresh:YES];
          [self returnToHomeScreen];
          if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteAvatarProcessSuccessfully:)]) {
              [self.delegate didCompleteAvatarProcessSuccessfully:YES];
          }
      }
  }];
}

#pragma mark - Onboarding View Delegate Methods

// No skip if first time user, other allow skip.
- (MyFiziqOnboardingViewMode)onboardingMode {
  if ([MyFiziqSDKCoreLite shared].avatars.all.count == 0) {
    return MyFiziqOnboardingViewModeFull;
  }
  return MyFiziqOnboardingViewModeSkip;
}

// Unwind back to new measurement
- (void)didTapCloseButton:(MyFiziqOnboardingView * _Nonnull)onboardingView {
  [self dismissViewControllerAnimated:YES completion:nil];
}

// Starts the avatar creation process
- (void)didFinishOnboarding:(MyFiziqOnboardingView *)onboardingView {
  [self beginAvatarCreationProcess];
}

// Starts the avatar creation process
- (void)didTapSkipButton:(MyFiziqOnboardingView * _Nonnull)onboardingView {
  [self beginAvatarCreationProcess];
}

@end
