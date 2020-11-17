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

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKNew ()<MyFiziqInputViewDelegate, MyFiziqInputViewDataSource, MYQTKSubViewOnboardingDelegate, MyFiziqTurnkeyDatasourceDelegate>
@property (strong, nonatomic) MyFiziqInputView *inputView;
@property (readonly, nonatomic) MyFiziqSDKCoreLite *myfiziq;
@property (strong, nonatomic) UIView *restrictedScansAccessView;
@property (strong, nonatomic) UIView *restrictedScansTitleView;
@property (strong, nonatomic) UILabel *noAccessLabel;
@property (strong, nonatomic) UILabel *noAccessSubLabel;
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

- (UIView *)restrictedScansAccessView {
    if (!_restrictedScansAccessView) {
        _restrictedScansAccessView = [[UIView alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _restrictedScansAccessView, @"myq-tk-input-view-restricted-access");
    }
    return _restrictedScansAccessView;
}

- (UIView *)restrictedScansTitleView {
    if (!_restrictedScansTitleView) {
        _restrictedScansTitleView = [[UIView alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _restrictedScansTitleView, @"myq-tk-input-view-restricted-access-title-view");
    }
    return _restrictedScansTitleView;
}

- (UILabel *)noAccessLabel {
    if (!_noAccessLabel) {
        _noAccessLabel = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _noAccessLabel, @"myq-tk-input-view-restricted-access-title");
    }
    return _noAccessLabel;
}

- (UILabel *)noAccessSubLabel {
    if (!_noAccessSubLabel) {
        _noAccessSubLabel = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _noAccessSubLabel, @"myq-tk-input-view-restricted-access-sub-title");
    }
    return _noAccessSubLabel;
}

#pragma mark - Methods

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-input-view");
    [self.view addSubview:self.inputView];
    self.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_TITLE_NEW_MEASUREMENT", @"New Measurements");
    [self setRestrictedScansView];
    if (![MyFiziqTurnkey shared].datasource && ![[MyFiziqTurnkey shared].datasource respondsToSelector:@selector(newScansAllowed)]) {
        MFZLog(MFZLogLevelInfo, @"Datasource method `newScansAllowed:` has not been implemented.");
        self.restrictedScansAccessView.hidden = NO;
        return;
    }
    self.restrictedScansAccessView.hidden = [[MyFiziqTurnkey shared].datasource newScansAllowed];
}

- (void)commonSetContraints {
    [self.inputView autoPinEdgesToSuperviewSafeArea];
    [self.restrictedScansAccessView autoPinEdgesToSuperviewSafeArea];
    [self.restrictedScansTitleView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake([MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqInputNoAccessViewTitleViewTop") doubleValue], [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqInputNoAccessViewTitleViewLeft") doubleValue], 0, [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqInputNoAccessViewTitleViewRight") doubleValue]) excludingEdge:ALEdgeBottom];
    [self.noAccessLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.noAccessLabel autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqInputNoAccessViewTitleHeight") doubleValue]];
    [self.noAccessSubLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.noAccessLabel withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqInputNoAccessViewSubTitleTop") doubleValue]];
    [self.noAccessSubLabel autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqInputNoAccessViewSubTitleHeight") doubleValue]];
    [self.noAccessSubLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
}

- (void)setRestrictedScansView {
    [self.restrictedScansAccessView addSubview:self.restrictedScansTitleView];
    [self.restrictedScansTitleView addSubview:self.noAccessLabel];
    [self.restrictedScansTitleView addSubview:self.noAccessSubLabel];
    [self.view addSubview:self.restrictedScansAccessView];
    self.noAccessLabel.text = MFZString(MyFiziqTurnkeyCommon, @"MFZ_INPUT_NO_SCAN_ACCESS_TITLE", @"You are unable to start a new scan as your access has expired.");
    self.noAccessSubLabel.text = MFZString(MyFiziqTurnkeyCommon, @"MFZ_INPUT_NO_SCAN_ACCESS_SUB_TITLE", @"For more information, please contact support from the app where you purchased Body Scan on Demand.");
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

- (void)didCompleteInputWithValues:(NSArray<id<MyFiziqCommonPickerValueDelegate>> * _Nonnull)values {
    [self.myfiziq.user setGender:[self.inputView getInputViewGender]];
    [self.myfiziq.user setHeightInCm:[[self.inputView getInputViewHeight] getHeightCM]];
    [self.myfiziq.user setWeightInKg:[[self.inputView getInputViewWeight] getWeightKG]];
    MYQTKSubViewOnboarding *vcOnboarding = [[MYQTKSubViewOnboarding alloc] init];
    vcOnboarding.delegate = self;
    [self presentViewController:vcOnboarding animated:YES completion:nil];
}

- (void)didCompleteAvatarProcessSuccessfully:(BOOL)success {
    if (success) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}

@end
