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

#import "MYQTKNew.h"
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>
#import <MyFiziqSDKInputView/MyFiziqInputView.h>
#import <PureLayout/PureLayout.h>
#import "MYQTKSubViewOnboarding.h"
#import "MyFiziqTurnKey.h"
#import "MYQTKNoAvatarsView.h"

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKNew ()<MyFiziqInputViewDelegate, MyFiziqInputViewDataSource, MYQTKSubViewOnboardingDelegate>
@property (strong, nonatomic) MyFiziqInputView *inputView;
@property (readonly, nonatomic) MyFiziqSDKCoreLite *myfiziq;
@property (strong, nonatomic) MYQTKNoAvatarsView *myqNoAvatarsTrackView;
@end

@implementation MYQTKNew

#pragma mark - Properties

- (MyFiziqSDKCoreLite *)myfiziq {
    return [MyFiziqSDKCoreLite shared];
}

- (MyFiziqInputView *)inputView {
    if (!_inputView) {
        _inputView = [[MyFiziqInputView alloc] init];
        _inputView.delegate = self;
        _inputView.datasource = self;
    }
    return _inputView;
}

- (MYQTKNoAvatarsView *)myqNoAvatarsTrackView {
    if (!_myqNoAvatarsTrackView) {
        _myqNoAvatarsTrackView = [[MYQTKNoAvatarsView alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ONLY_NEW_TITLE", @"Subscription Ended")
                                                                detailText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ONLY_NEW_DETAIL", @"Renew your subscription\nto take a Body Scan.")
                                                          shouldShowButton:NO];
        _myqNoAvatarsTrackView.delegate = self;
        _myqNoAvatarsTrackView.hidden = NO;
    }
    return _myqNoAvatarsTrackView;
}

#pragma mark - Methods

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-input-view");
    self.navigationItem.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_TITLE_NEW_MEASUREMENT", @"New Measurement");
    [self.view addSubview:self.inputView];
    if ([MFZStyleVarBool(MyFiziqTurnkeyCommon, @"myqtkShowTabBarNames") boolValue]) {
        self.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_TITLE_NEW_MEASUREMENT", @"New Measurements");
    }
    [self.view addSubview:self.myqNoAvatarsTrackView];
}

- (void)commonSetContraints {
    [self.inputView autoPinEdgesToSuperviewSafeArea];
    [self.myqNoAvatarsTrackView autoPinEdgesToSuperviewSafeArea];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL hideNew = [MyFiziqTurnkey shared].datasource ? [[MyFiziqTurnkey shared].datasource newScansAllowed] : NO;
    self.myqNoAvatarsTrackView.hidden = hideNew;
    self.inputView.hidden = !hideNew;
}

#pragma mark - MyFiziqInputViewDataSource

- (MyFiziqInputMeasurementsToDisplay)measurementsToDisplay {
    return MyFiziqInputMeasurementsToDisplayAll;
}

- (double)inputHeightCM {
    return self.myfiziq.user.heightInCm;
}

- (MFZMeasurement)inputHeightUnit {
    return self.myfiziq.user.measurementPreference;
}

- (double)inputWeightKG {
    return self.myfiziq.user.weightInKg;
}

- (MFZMeasurement)inputWeightUnit {
    return self.myfiziq.user.measurementPreference;
}

- (BOOL)showDateOfBirth {
  return NO;
}

- (NSDate *)inputDateOfBirth {
  return self.myfiziq.user.birthdate;
}

#pragma mark - MyFiziqInputViewDelegate

- (void)didCompleteInputWithValues:(NSArray<id<MyFiziqCommonPickerValueDelegate>> *)values miscData:(NSDictionary<NSString *,id> *)miscData {
    [self.myfiziq.user setGender:[self.inputView getInputViewGender]];
    [self.myfiziq.user setHeightInCm:[[self.inputView getInputViewHeight] getHeightCM]];
    [self.myfiziq.user setWeightInKg:[[self.inputView getInputViewWeight] getWeightKG]];
    MYQTKSubViewOnboarding *vcOnboarding = [[MYQTKSubViewOnboarding alloc] init];
    vcOnboarding.delegate = self;
    [self presentViewController:vcOnboarding animated:YES completion:nil];
}

- (void)didCompleteAvatarProcessSuccessfully:(BOOL)success {
    if (success) {
        // Need the slight delay for Core Light to update with new result.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tabBarController setSelectedIndex:0];
        });
    }
}

@end
