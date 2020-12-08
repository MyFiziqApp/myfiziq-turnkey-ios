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

#import "MYQTKCardButtonsBar.h"
#import "MYQTKMyScans.h"
#import "MYQTKTrack.h"
#import "MYQTKNew.h"

#define MYQTK_BUTTON_MYSCANS_ID         @"MYQTK_BUTTON_MYSCANS_ID"
#define MYQTK_BUTTON_TRACK_ID           @"MYQTK_BUTTON_TRACK_ID"
#define MYQTK_BUTTON_NEW_ID             @"MYQTK_BUTTON_NEW_ID"

@interface MYQTKCardButtonsBar()
// - Sub UIViews
@property (strong, nonatomic) MyFiziqCommonButton *viewButtonMyScans;
@property (strong, nonatomic) MyFiziqCommonButton *viewButtonTrack;
@property (strong, nonatomic) MyFiziqCommonButton *viewButtonNew;
@end

@implementation MYQTKCardButtonsBar

#pragma mark - Properties

- (MyFiziqCommonButton *)viewButtonMyScans {
    if (!_viewButtonMyScans) {
        _viewButtonMyScans = [[MyFiziqCommonButton alloc] initWithButtonLabelId:MYQTK_BUTTON_MYSCANS_ID forButtonType:MyFiziqCommonButtonTypeEnumWarning];
        [_viewButtonMyScans setTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_BUTTON_MYSCANS", @"MY SCANS") forState:UIControlStateNormal];
        [_viewButtonMyScans addTarget:self action:@selector(tappedShowAllButtonFromSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewButtonMyScans;
}

- (MyFiziqCommonButton *)viewButtonTrack {
    if (!_viewButtonTrack) {
        _viewButtonTrack = [[MyFiziqCommonButton alloc] initWithButtonLabelId:MYQTK_BUTTON_TRACK_ID forButtonType:MyFiziqCommonButtonTypeEnumWarning];
        [_viewButtonTrack setTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_BUTTON_TRACK", @"TRACK") forState:UIControlStateNormal];
        [_viewButtonTrack addTarget:self action:@selector(tappedTrackButtonFromSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewButtonTrack;
}

- (MyFiziqCommonButton *)viewButtonNew {
    if (!_viewButtonNew) {
        _viewButtonNew = [[MyFiziqCommonButton alloc] initWithButtonLabelId:MYQTK_BUTTON_NEW_ID forButtonType:MyFiziqCommonButtonTypeEnumWarning];
        [_viewButtonNew setTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_BUTTON_NEW", @"NEW") forState:UIControlStateNormal];
        [_viewButtonNew addTarget:self action:@selector(tappedNewButtonFromSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewButtonNew;
}

#pragma mark - Init Methods

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self, @"myq-tk-card-buttons-container");
    // Container: Buttons Bar
    [self addSubview:self.viewButtonMyScans];
    [self addSubview:self.viewButtonNew];
    [self addSubview:self.viewButtonTrack];
}

- (void)doUpdateConstraints {
    // Button: My Scans
    [self.viewButtonMyScans autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonMyScansHeight") doubleValue]];
    // Button: Track
    [self.viewButtonTrack autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonTrackHeight") doubleValue]];
    // Button: New
    [self.viewButtonNew autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonNewHeight") doubleValue]];
    NSArray<UIView *> *buttons = @[self.viewButtonMyScans, self.viewButtonNew, self.viewButtonTrack];
    [buttons autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeBottom withFixedSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardButtonWidth") doubleValue]];
}

#pragma mark - Button Handlers

- (void)tappedShowAllButtonFromSender:(id _Nullable)sender {
    [MYQTKBaseView actionShowAll:YES];
}

- (void)tappedTrackButtonFromSender:(id _Nullable)sender {
    [MYQTKBaseView actionShowTrack:YES];
}

- (void)tappedNewButtonFromSender:(id _Nullable)sender {
    [MYQTKBaseView actionShowNew:YES];
}

@end
