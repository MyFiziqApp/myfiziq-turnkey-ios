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

#import "MYQTKCardNoneView.h"
#import "MYQTKNew.h"

#define MYQTK_NONE_NEW_BUTTON_ID        @"MYQTK_NONE_NEW_BUTTON_ID"

@interface MYQTKCardNoneView()
// - Sub UIViews
@property (strong, nonatomic) UILabel *viewNoneTitle;
@property (strong, nonatomic) UILabel *viewNoneBody;
@property (strong, nonatomic) MyFiziqCommonButton *viewNoneNewScanButton;
@property (strong, nonatomic) UIImageView *viewNoneAvatar;
@end

@implementation MYQTKCardNoneView

#pragma mark - Properties

- (UILabel *)viewNoneTitle {
    if (!_viewNoneTitle) {
        _viewNoneTitle = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewNoneTitle, @"myq-tk-card-none-title");
        _viewNoneTitle.text = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_NONE_TITLE", @"3D BODY SCAN");
    }
    return _viewNoneTitle;
}

- (UILabel *)viewNoneBody {
    if (!_viewNoneBody) {
        _viewNoneBody = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewNoneBody, @"myq-tk-card-none-body");
        _viewNoneBody.text = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_NONE_BODY", @"Get your body\nmeasurements using your\nsmart phone.");
    }
    return _viewNoneBody;
}

- (MyFiziqCommonButton *)viewNoneNewScanButton {
    if (!_viewNoneNewScanButton) {
        _viewNoneNewScanButton = [[MyFiziqCommonButton alloc] initWithButtonLabelId:MYQTK_NONE_NEW_BUTTON_ID forButtonType:MyFiziqCommonButtonTypeEnumNeutral];
        [_viewNoneNewScanButton setTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_NONE_NEW_BUTTON", @"NEW SCAN") forState:UIControlStateNormal];
        [_viewNoneNewScanButton addTarget:self action:@selector(tappedLetsDoThisButtonFromSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewNoneNewScanButton;
}

- (UIImageView *)viewNoneAvatar {
    if (!_viewNoneAvatar) {
        _viewNoneAvatar = [[UIImageView alloc] initWithImage:MFZImage(MyFiziqTurnkeyCommon, @"myqtk-avatar-male")];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewNoneAvatar, @"myq-tk-card-no-result-image-view");
    }
    return _viewNoneAvatar;
}

#pragma mark - Init Methods

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self, @"myq-tk-card-none-view");
    // Container: No measurements
    [self addSubview:self.viewNoneTitle];
    [self addSubview:self.viewNoneBody];
    [self addSubview:self.viewNoneNewScanButton];
    [self addSubview:self.viewNoneAvatar];
}

- (void)doUpdateConstraints {
    // None: Title
    [self.viewNoneTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneTitleTopPadding") doubleValue]];
    [self.viewNoneTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneTitleLeftPadding") doubleValue]];
    [self.viewNoneTitle autoSetDimension:ALDimensionWidth toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneTitleWidth") doubleValue]];
    [self.viewNoneTitle autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneTitleHeight") doubleValue]];
    // None: Body
    [self.viewNoneBody autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.viewNoneTitle withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneBodyTopPadding") doubleValue]];
    [self.viewNoneBody autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.viewNoneTitle];
    [self.viewNoneBody autoSetDimension:ALDimensionWidth toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneBodyWidth") doubleValue]];
    [self.viewNoneBody autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneBodyHeight") doubleValue]];
    // None: New Scan Button
    [self.viewNoneNewScanButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.viewNoneBody withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneNewButtonTopPadding") doubleValue]];
    [self.viewNoneNewScanButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.viewNoneBody];
    [self.viewNoneNewScanButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.viewNoneBody];
    [self.viewNoneNewScanButton autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneNewButtonHeight") doubleValue]];
    // None: Avatar
    [self.viewNoneAvatar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneAvatarRightPadding") doubleValue]];
    [self.viewNoneAvatar autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.viewNoneTitle];
    [self.viewNoneAvatar autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.viewNoneNewScanButton];
    [self.viewNoneAvatar autoSetDimension:ALDimensionWidth toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardNoneAvatarWidth") doubleValue]];
}

#pragma mark - Button Handlers

- (void)tappedLetsDoThisButtonFromSender:(id _Nullable)sender {
    UIViewController *vc = [[MYQTKNew alloc] init];
    [MYQTKBaseView goToVC:vc];
}

@end
