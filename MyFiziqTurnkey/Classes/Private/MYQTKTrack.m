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

#import "MYQTKTrack.h"
#import <MyFiziqSDKTrackingView/MyFiziqTrackSDKTrackingView.h>
#import <PureLayout/PureLayout.h>
#import "MYQTKNoAvatarsView.h"
#import "MYQTKMyScans.h"
#import "MYQTKSubViewHome.h"
#import "MYQTKNavigationBarConstants.h"
#import "MYQTKNew.h"
#import "MyFiziqTurnkey.h"

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKTrack () <MYQTKNoAvatarsViewDelegate, MyFiziqTrackSDKTrackingViewDelegate, MYQTKMyScansDelegate, MYQTKSubViewHomeDelegate>
@property (strong, nonatomic) MYQTKNoAvatarsView *myqNoAvatarsTrackView;
@property (strong, nonatomic) MyFiziqTrackSDKTrackingView *trackingView;
@property (readonly, nonatomic) MyFiziqSDKCoreLite *myfiziq;
@property (strong, nonatomic) MYQTKNavigationBarConstants *navBarIconHelper;
@property (strong, nonatomic) UIButton *optionsButton;
@end

@implementation MYQTKTrack

#pragma mark - Properties

- (MyFiziqSDKCoreLite *)myfiziq {
    return [MyFiziqSDKCoreLite shared];
}

- (MyFiziqTrackSDKTrackingView *)trackingView {
    if (!_trackingView) {
      _trackingView = [[MyFiziqTrackSDKTrackingView alloc] init];
      _trackingView.delegate = self;
      _trackingView.hidden = YES;
    }
    return _trackingView;
}

- (MYQTKNoAvatarsView *)myqNoAvatarsTrackView {
    if (!_myqNoAvatarsTrackView) {
        BOOL showNewButton = [MyFiziqTurnkey shared].datasource ? [[MyFiziqTurnkey shared].datasource newScansAllowed] : NO;
        if (showNewButton) {
            _myqNoAvatarsTrackView = [[MYQTKNoAvatarsView alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_TRACK_TITLE_TEXT", @"Measure. Track. Transform.")
                                                                    detailText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_TRACK_DETAIL_TEXT", @"You need at least two measurements\nto use the Track feature.")
                                                              shouldShowButton:YES];
        } else {
            _myqNoAvatarsTrackView = [[MYQTKNoAvatarsView alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ONLY_TRACK_TITLE", @"Measure. Track. Transform.")
                                                                    detailText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ONLY_TRACK_DETAIL", @"You need at least two measurements\nto use the Track feature.")
                                                              shouldShowButton:NO];
        }
        
        _myqNoAvatarsTrackView.delegate = self;
        _myqNoAvatarsTrackView.hidden = NO;
    }
    return _myqNoAvatarsTrackView;
}

- (UIButton *)optionsButton {
    if(!_optionsButton) {
       _optionsButton = [[UIButton alloc]init];
       [_optionsButton setImage:MFZImage(MyFiziqTurnkeyCommon, @"mfz-icon-switch") forState: UIControlStateNormal];
       [_optionsButton addTarget:self action:@selector(didTapOptionsButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _optionsButton;
}

#pragma mark - Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.myfiziq.avatars.all count] > 1) {
        self.myqNoAvatarsTrackView.hidden = YES;
        self.trackingView.hidden = NO;
        [self.trackingView setTrackViewMeasurementType:[MyFiziqSDKCoreLite shared].user.measurementPreference];
        [self.trackingView setTrackAvatars:self.myfiziq.avatars.all];
        self.optionsButton.hidden = NO;
    } else {
        self.myqNoAvatarsTrackView.hidden = NO;
        self.trackingView.hidden = YES;
        self.optionsButton.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.optionsButton.hidden = YES;
}

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-track-view");
    //Make sure the scrollable view is added on top of heirarchy in order to shrink large title of nav bar on scroll.
    [self.view addSubview:self.trackingView];
    [self.view addSubview:self.myqNoAvatarsTrackView];
    self.navigationItem.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_TITLE_TRACK", @"TRACK");
    self.navBarIconHelper = [MYQTKNavigationBarConstants new];
    if (self.navigationController) {
        [self.navigationController.navigationBar addSubview:self.optionsButton];
    }
}

- (void)commonSetContraints {
    [self.myqNoAvatarsTrackView autoPinEdgesToSuperviewSafeArea];
    [self.trackingView autoPinEdgesToSuperviewSafeArea];
    if (self.navigationController) {
        [self.optionsButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:self.navBarIconHelper.imageRightMargin];
        [self.optionsButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:self.navBarIconHelper.imageBottomMarginForLargeState];
        [self.optionsButton autoSetDimension:ALDimensionHeight toSize:self.navBarIconHelper.imageSizeForLargeState];
        [self.optionsButton autoSetDimension:ALDimensionWidth toSize:self.navBarIconHelper.imageSizeForLargeState];
    }
}

- (void)didTapOptionsButton: (UIButton *)sender {
    [self.trackingView toggleAvatarOptions];
}

#pragma mark - No Avatars View Delegate

- (void)didTapNoAvatarsViewButtonFromView:(MYQTKNoAvatarsView *_Nonnull)noAvatarsView {
    MYQTKNew *newVC = [MYQTKNew new];
    [self.navigationController showViewController:newVC sender:self];
}

#pragma mark - MyFiziqTrackSDKTrackingViewDelegate

- (void)didSelectToViewAvatar:(MyFiziqAvatar *_Nonnull)selectedAvatar fromTrackingViewController:(MyFiziqTrackSDKTrackingView *_Nonnull)trackViewController {
    MYQTKSubViewHome *homeVC = [[MYQTKSubViewHome alloc] init];
    homeVC.delegate = self;
    [self.navigationController showViewController:homeVC sender:self];
    [homeVC setSelectedAvatar:selectedAvatar];
    [self.trackingView toggleAvatarOptions];
}

- (void)didSelectToChangeCurrentAvatar:(MyFiziqAvatar *_Nonnull)currentAvatar
                   withAllValidAvatars:(NSArray <MyFiziqAvatar *> *_Nonnull)avatars
            fromTrackingViewController:(MyFiziqTrackSDKTrackingView *_Nonnull)trackViewController {
    MYQTKMyScans *scansView = [[MYQTKMyScans alloc] init];
    scansView.delegate = self;
    [self.navigationController showViewController:scansView sender:self];
    [self.trackingView toggleAvatarOptions];
}

- (void)trackViewDidScroll:(UIScrollView * _Nonnull)scrollView {
    if (!self.navigationController) {
        return;
    }
    if (CGRectEqualToRect(CGRectZero, self.navigationController.navigationBar.frame)) {
        return;
    }
    [self.navBarIconHelper resizeNavBarItem:self.optionsButton forNavBarHeight:self.navigationController.navigationBar.frame.size.height];
}

#pragma mark - MYQTKMyScansDelegate

- (void)didSelectAvatar:(MyFiziqAvatar *)avatar fromMyScansViewController:(MYQTKMyScans *)scansVC {
    [scansVC.navigationController popViewControllerAnimated:YES];
    [self.trackingView setAvatarWithSelectedAvatar:avatar forMeasurementType:self.myfiziq.user.measurementPreference];
}

#pragma mark - MYQTKSubViewHome

- (void)didDeleteAvatarWithAttemptID:(NSString *)attemptID {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
