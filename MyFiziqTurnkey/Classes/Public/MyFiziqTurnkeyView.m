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

#import "MyFiziqTurnkeyView.h"
#import "MYQTKBaseView.h"
#import "MyFiziqTurnkeyCommon.h"
#import "MyFiziqTurnkey.h"
#import "MYQTKCardNoneView.h"
#import "MYQTKCardResultView.h"
#import "MYQTKCardButtonsBar.h"

@interface MyFiziqTurnkeyViewBase : MYQTKBaseView
// Sub UIViews
@property (strong, nonatomic) id<MyFiziqCommonSpinnerDelegate> viewSpinner;
@property (strong, nonatomic) MYQTKCardNoneView *viewNone;
@property (strong, nonatomic) MYQTKCardResultView *viewResult;
@property (strong, nonatomic) MYQTKCardButtonsBar *viewButtons;
@end

@implementation MyFiziqTurnkeyViewBase

#pragma mark - Properties

- (id<MyFiziqCommonSpinnerDelegate>)viewSpinner {
    if (!_viewSpinner) {
        _viewSpinner = MFZSpinner(MyFiziqTurnkeyCommon, self);
    }
    return _viewSpinner;
}

- (MYQTKCardNoneView *)viewNone {
    if (!_viewNone) {
        _viewNone = [[MYQTKCardNoneView alloc] init];
        _viewNone.hidden = YES;
    }
    return _viewNone;
}

- (MYQTKCardResultView *)viewResult {
    if (!_viewResult) {
        _viewResult = [[MYQTKCardResultView alloc] init];
        _viewResult.hidden = YES;
    }
    return _viewResult;
}

- (MYQTKCardButtonsBar *)viewButtons {
    if (!_viewButtons) {
        _viewButtons = [[MYQTKCardButtonsBar alloc] init];
        _viewButtons.hidden = YES;
    }
    return _viewButtons;
}

#pragma mark - Init Methods

- (void)commonInit {
    [super commonInit];
    // Add views
    MFZStyleView(MyFiziqTurnkeyCommon, self, @"myq-tk-card-view");
    [self addSubview:self.viewNone];
    [self addSubview:self.viewResult];
    [self addSubview:self.viewButtons];
}

- (void)doUpdateConstraints {
    [super doUpdateConstraints];
    // Container: No measurements
    [self.viewNone autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.viewNone autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.viewNone autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.viewNone autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardContainerBottomInset") doubleValue]];
    // Container: Has measurements
    [self.viewResult autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.viewResult autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.viewResult autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.viewResult autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardContainerBottomInset") doubleValue]];
    // Container: Buttons Bar
    [self.viewButtons autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonsBarLeftPadding") doubleValue]];
    [self.viewButtons autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonsBarRightPadding") doubleValue]];
    [self.viewButtons autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonsBarHeight") doubleValue]];
    [self.viewButtons autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonsBarBottomPadding") doubleValue]];
    // Register self to turnkey singleton to allow automatic refresh.
    [self.viewSpinner show];
    [[MyFiziqTurnkey shared].turnkeyCardViews addObject:self];
}

#pragma mark - Public Methods

- (void)refresh {
    if (![MyFiziqSDK shared].user.isLoggedIn) {
        self.viewNone.hidden = YES;
        self.viewResult.hidden = YES;
        [self.viewSpinner show];
        MFZLog(MFZLogLevelWarn, @"No user logged in yet. Will keep spinner active until user has authorized.");
        return;
    }
    // NOTE: It is the responsibility of MyFiziqTurnKey:refresh to sync with the server first.
    // Stop the spinner.
    [self.viewSpinner hide];
    self.viewButtons.hidden = NO;
    // If no results for the user, show the No Measurements view.
    if ([MyFiziqSDK shared].avatars.all.count == 0) {
        self.viewNone.hidden = NO;
        self.viewResult.hidden = YES;
    } else {
        [self.viewResult refresh];
        self.viewNone.hidden = YES;
        self.viewResult.hidden = NO;
    }
}

- (void)showLoading {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Hide container views
        self.viewResult.hidden = YES;
        self.viewNone.hidden = YES;
        self.viewButtons.hidden = YES;
        [self.viewSpinner show];
    }];
}

@end

@interface MyFiziqTurnkeyView()
@property (assign, nonatomic) BOOL didSetupConstraints;
@property (strong, nonatomic) MyFiziqTurnkeyViewBase *base;
@end

@implementation MyFiziqTurnkeyView

- (MyFiziqTurnkeyViewBase *)base {
    if (!_base) {
        _base = [[MyFiziqTurnkeyViewBase alloc] init];
    }
    return _base;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initForAutoLayout {
    self = [super initForAutoLayout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.base];
}

- (void)updateConstraints {
    [super updateConstraints];
    // Stop memory leaking by only setting constraints once!
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self.base autoPinEdgesToSuperviewEdges];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    MFZStyleApply(MyFiziqTurnkeyCommon, self);
}

- (void)showLoading {
    [self.base showLoading];
}

- (void)refresh {
    [self.base refresh];
}

@end
