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

#import "MYQTKNoAvatarsView.h"
#import "MyFiziqTurnkeyCommon.h"
#import <PureLayout/PureLayout.h>

@interface MYQTKNoAvatarsView()
@property (assign, nonatomic) BOOL didSetConstraints;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIButton *actionButton;
@end

@implementation MYQTKNoAvatarsView

#pragma mark - View Elements

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _titleLabel, @"myq-tk-no-avatars-title");
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _detailLabel, @"myq-tk-no-avatars-detail");
    }
    return _detailLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _actionButton, @"myq-tk-no-avatar-button");
        [_actionButton setTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ACTION_BUTTON_TITLE", @"Start") forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(didTapActionButton:) forControlEvents:UIControlEventTouchUpInside];
        _actionButton.layer.shadowColor = [MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkButtonDropShadowColor") CGColor];
        CGFloat shadowHeight = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkButtonDropShadowHeight") floatValue];
        CGFloat shadowWidth = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkButtonDropShadowWidth") floatValue];
        CGFloat shadowRadius = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkButtonDropShadowRadius") floatValue];
        CGFloat shadowOpacity = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkButtonDropShadowOpacity") floatValue];
        _actionButton.layer.shadowOffset = CGSizeMake(shadowWidth, shadowHeight);
        _actionButton.layer.shadowRadius = shadowRadius;
        _actionButton.layer.shadowOpacity = shadowOpacity;
    }
    return _actionButton;
}

#pragma mark - View Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *_Nonnull)titleText detailText:(NSString *_Nonnull)detailText shouldShowButton:(BOOL)show {
    self = [self init];
    if (self) {
        [self setTitleLabelText:titleText];
        [self setDetailLabelText:detailText];
        self.actionButton.hidden = !show;
        [self.titleLabel sizeToFit];
        [self.detailLabel sizeToFit];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *_Nonnull)titleText detailText:(NSString *_Nonnull)detailText buttonText:(NSString *_Nonnull)buttonTitle shouldShowButton:(BOOL)show {
    self = [self initWithTitle:titleText detailText:detailText shouldShowButton:show];
    if (self) {
        [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
    return self;
}

- (void)commonInit {
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.actionButton];
    [self setTitleLabelText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_GALLERY_TITLE_TEXT", @"You have no 3D body scans")];
    [self setDetailLabelText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_GALLERY_DETAIL_TEXT", @"At least one body scan is needed to be displayed.")];
    self.actionButton.hidden = NO;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    if (!self.didSetConstraints) {
        self.didSetConstraints = YES;
        // Title
        [self.titleLabel autoPinEdgeToSuperviewMargin:ALEdgeLeft];
        [self.titleLabel autoPinEdgeToSuperviewMargin:ALEdgeRight];
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkOneAvatarTitleInset") floatValue]];
        // Description
        [self.detailLabel autoPinEdgeToSuperviewMargin:ALEdgeLeft];
        [self.detailLabel autoPinEdgeToSuperviewMargin:ALEdgeRight];
        [self.detailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkOneAvatarDescriptionTopOffset") floatValue]];
        [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
            [self.titleLabel autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkOneAvatarTitleHeight") floatValue]];
            [self.detailLabel autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkOneAvatarDescriptionHeight") floatValue]];
        }];
        // Button
        [self.actionButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.actionButton autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkOneAvatarButtonHeight") floatValue]];
        [self.actionButton autoSetDimension:ALDimensionWidth toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkOneAvatarButtonWidth") floatValue]];
        [self.actionButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.detailLabel withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkSdkOneAvatarButtonTopOffset") floatValue]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    MFZStyleApply(MyFiziqTurnkeyCommon, self);
}

#pragma mark - Private Methods

- (void)setTextForLabel:(UILabel *)selectedLabel withText:(NSString *)text {
    selectedLabel.text = text;
}

#pragma mark - Actions

- (IBAction)didTapActionButton:(id)sender {
    if (!self.delegate) {
        MFZLog(MFZLogLevelWarn, @"To receive events from [%@] please implement the delegate method.", [self description]);
        return;
    }
    if (![self.delegate respondsToSelector:@selector(didTapNoAvatarsViewButtonFromView:)]) {
        MFZLog(MFZLogLevelWarn, @"To receive events from [%@] please implement the delegate method.", [self description]);
        return;
    }
    [self.delegate didTapNoAvatarsViewButtonFromView:self];
}

#pragma mark - Public Methods

- (void)setTitleLabelText:(NSString *_Nullable)titleText {
    [self setTextForLabel:self.titleLabel withText:titleText];
}

- (void)setDetailLabelText:(NSString *_Nullable)detailText {
    [self setTextForLabel:self.detailLabel withText:detailText];
}

@end



