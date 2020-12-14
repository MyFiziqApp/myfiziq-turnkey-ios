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

#import "MYQTKSubViewHome.h"
#import <MyFiziqSDKProfileView/MyFiziqProfileHomeView.h>
#import <PureLayout/PureLayout.h>
#import <MyFiziqSDKSupport/MyFiziqSupportSDK.h>
#import "MYQTKNavigationBarConstants.h"
#import "MyFiziqTurnkey.h"

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKSubViewHome () <MyFiziqProfileHomeViewDelegate>
@property (strong, nonatomic) MyFiziqCommonSpinnerView *myqSpinnerView;
@property (strong, nonatomic) MyFiziqProfileHomeView *myqHomeView;
@property (strong, nonatomic) MyFiziqAvatar *myqSelectedAvatar;
@property (strong, nonatomic) MYQTKNavigationBarConstants *navBarIconHelper;
@property (strong, nonatomic) UIButton *trashButton;
@property (strong, nonatomic) UIButton *supportButton;
@end

@implementation MYQTKSubViewHome

#pragma mark - View Elements

- (MyFiziqCommonSpinnerView *)myqSpinnerView {
    if (!_myqSpinnerView) {
        _myqSpinnerView = [[MyFiziqCommonSpinnerView alloc] init];
    }
    return _myqSpinnerView;
}

- (MyFiziqProfileHomeView *)myqHomeView {
    if (!_myqHomeView) {
        _myqHomeView = [[MyFiziqProfileHomeView alloc] init];
        _myqHomeView.delegate = self;
        _myqHomeView.measurementPreference = [[MyFiziqSDKCoreLite shared] user].measurementPreference;
    }
    return _myqHomeView;
}

- (UIButton *)trashButton {
    if (!_trashButton) {
        _trashButton = [[UIButton alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:MFZImage(MyFiziqTurnkeyCommon, @"mfz-icon-trash")];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_trashButton addSubview:imageView];
        [imageView autoPinEdgesToSuperviewEdges];
        [_trashButton addTarget:self action:@selector(didTapTrashButton:) forControlEvents:UIControlEventTouchUpInside];
        _trashButton.clipsToBounds = YES;
        _trashButton.hidden = YES;
    }
    return _trashButton;
}

- (UIButton *)supportButton {
    if (!_supportButton) {
        _supportButton = [[UIButton alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:MFZImage(MyFiziqTurnkeyCommon, @"mfz-app-feedback-icon")];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_supportButton addSubview:imageView];
        [imageView autoPinEdgesToSuperviewEdges];
        [_supportButton addTarget:self action:@selector(didTapSupportButton:) forControlEvents:UIControlEventTouchUpInside];
        _supportButton.clipsToBounds = YES;
        _supportButton.hidden = YES;
    }
    return _supportButton;
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated {
    if (self.navigationController) {
        // Make sure trash icon is sub-view, as may have been removed
        if (![self.navigationController.navigationBar.subviews containsObject:self.trashButton]) {
            [self.navigationController.navigationBar addSubview:self.trashButton];
            [self setTrashButtonConstraints];
        }
        if ([MyFiziqSDKCoreLite shared].supportDelegate) {
            if (![self.navigationController.navigationBar.subviews containsObject:self.supportButton]) {
                [self.navigationController.navigationBar addSubview:self.supportButton];
                [self setSupportButtonConstraints];
            }
        }
        self.trashButton.hidden = NO;
        self.supportButton.hidden = ![MyFiziqSDKCoreLite shared].supportDelegate;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.myqHomeView setWithAvatar:self.myqSelectedAvatar andUnitPreference:[[MyFiziqSDKCoreLite shared] user].measurementPreference];
    });
}

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-sub-home-view");
    [self.view addSubview:self.myqHomeView];
    [self.myqHomeView setWithDefaults];
    [self.view addSubview:self.myqSpinnerView];
    self.navBarIconHelper = [MYQTKNavigationBarConstants new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.trashButton removeFromSuperview];
    [self.supportButton removeFromSuperview];
}

#pragma mark - View Layouts

- (void)commonSetContraints {
    [self.myqHomeView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.myqHomeView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.myqHomeView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.myqHomeView autoPinEdgeToSuperviewSafeArea:ALEdgeTop];
    [self.myqSpinnerView autoPinEdgesToSuperviewEdges];
}

- (void)setTrashButtonConstraints {
    [self.trashButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:self.navBarIconHelper.imageRightMargin];
    [self.trashButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:self.navBarIconHelper.imageBottomMarginForLargeState];
    [self.trashButton autoSetDimension:ALDimensionHeight toSize:self.navBarIconHelper.imageSizeForLargeState];
    [self.trashButton autoSetDimension:ALDimensionWidth toSize:self.navBarIconHelper.imageSizeForLargeState];
}

- (void)setSupportButtonConstraints {
    if (!self.trashButton.superview) {
        MFZLog(MFZLogLevelWarn, @"Trash Button has not been added to the view. Cannot install constraints to support button.");
        return;
    }
    [self.supportButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.trashButton withOffset:-6.0];
    [self.supportButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:self.navBarIconHelper.imageBottomMarginForLargeState];
    [self.supportButton autoSetDimension:ALDimensionHeight toSize:self.navBarIconHelper.imageSizeForLargeState];
    [self.supportButton autoSetDimension:ALDimensionWidth toSize:self.navBarIconHelper.imageSizeForLargeState];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - Actions

- (IBAction)didTapTrashButton:(id)sender {
    NSLog(@"Tapped trash button.");
    id<MyFiziqCommonAlertDelegate> alertView = MFZAlert(MyFiziqTurnkeyCommon,
                                                        MFZString(MyFiziqTurnkeyCommon, @"MYQTK_DELETE_AVATAR_ALERT_TITLE", @"Delete Measurement"),
                                                        MFZString(MyFiziqTurnkeyCommon, @"MYQTK_DELETE_AVATAR_ALERT_MESSAGE", @"Do you wish to delete this measurement?\n\nThis cannot be undone."));
    MyFiziqCommonAlertAction *deleteAction = [[MyFiziqCommonAlertAction alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_ALERT_CONTINUE", @"Continue") style:MFZAlertActionStyleHighlighted block:^{
        [self displayLoadingViewVisible:YES];
        [self deleteSelectedAvatar];
    }];
    MyFiziqCommonAlertAction *cancelAction = [[MyFiziqCommonAlertAction alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_ALERT_CANCEL", @"Cancel") style:MFZAlertActionStyleNormal];
    [alertView addAction:deleteAction];
    [alertView addAction:cancelAction];
    [alertView showWithOverlay:YES];
}

- (IBAction)didTapSupportButton:(id)sender {
    MyFiziqSupportSDK *supportSDK;
    MyFiziqSupportSDKViewController *supportVC;
    if ([MyFiziqSDKCoreLite shared].supportDelegate) {
        MyFiziqSupportSDK *supDel = [MyFiziqSDKCoreLite shared].supportDelegate;
        supportVC = [[MyFiziqSupportSDKViewController alloc] initWithViewType:MyFiziqSupportSDKViewTypeQuery];
        supportVC.delegate = supDel.supportVC.delegate;
        supportSDK = supDel;
        supportSDK.supportVC = supportVC;
    }
    if (!supportSDK || !supportVC || !supportVC.delegate || ![supportVC.delegate respondsToSelector:@selector(didSelectOptionSubmitSupportRequest:)]) {
        id<MyFiziqCommonAlertDelegate> alertView = MFZAlert(MyFiziqTurnkeyCommon,
                                                            @"Support not Available",
                                                            @"Support has not been implemented. Contact the developer via their website for more information.");
        MyFiziqCommonAlertAction *cancelAction = [[MyFiziqCommonAlertAction alloc] initWithTitle:@"OK" style:MFZAlertActionStyleNormal];
        [alertView addAction:cancelAction];
        [alertView showWithOverlay:YES];
        return;
    }
    supportSDK.supportVC.navigationItem.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_SUPPORT_TITLE_RESULTS_QUERY", @"Results Query");
    [supportSDK showSupportForResults:@[self.myqSelectedAvatar.attemptId] fromViewController:self];
}

#pragma mark - Private Methods

- (void)displayLoadingViewVisible:(BOOL)visible {
    if (visible) {
        [self.myqSpinnerView show];
        return;
    }
    [self.myqSpinnerView hide];
}

- (void)deleteSelectedAvatar {
    [[[MyFiziqSDKCoreLite shared] avatars] deleteAvatars:@[self.myqSelectedAvatar] success:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self displayLoadingViewVisible:NO];
            if (!self.delegate) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            if (![self.delegate respondsToSelector:@selector(didDeleteAvatarWithAttemptID:)]) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            [self.delegate didDeleteAvatarWithAttemptID:self.myqSelectedAvatar.attemptId];
        }];
        [[MyFiziqTurnkey shared] refresh:YES];
    } failure:^(NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self displayLoadingViewVisible:NO];
            if (error) {
                [self displayFailedToDeleteAlert:error];
            }
        }];
    }];
}

- (void)displayFailedToDeleteAlert:(NSError *)error {
    NSString *alertBody = [NSString stringWithFormat:@"%@%@.", MFZString(MyFiziqTurnkeyCommon, @"MYQTK_ALERT_DELETE_AVATARS_ERROR", @"Could not delete measurement:\n\n"), error.localizedDescription];
    id<MyFiziqCommonAlertDelegate> alertView = MFZAlert(MyFiziqTurnkeyCommon,
                                                        MFZString(MyFiziqTurnkeyCommon, @"MYQTK_ALERT_ERROR_TITLE", @"Error"),
                                                        alertBody);
    MyFiziqCommonAlertAction *cancelAction = [[MyFiziqCommonAlertAction alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_ALERT_OK", @"OK") style:MFZAlertActionStyleNormal];
    [alertView addAction:cancelAction];
    [alertView showWithOverlay:NO];
}

#pragma mark - Public Methods

- (void)setSelectedAvatar:(MyFiziqAvatar *)avatar {
    self.myqSelectedAvatar = avatar;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
    NSString *newDate = [dateFormatter stringFromDate:avatar.completedDate];
    self.title = newDate;
}

#pragma mark - Scroll View Delegate

- (void)profileViewDidScroll:(UIScrollView *)scrollView {
    if (!self.navigationController) {
        return;
    }
    if (CGRectEqualToRect(CGRectZero, self.navigationController.navigationBar.frame)) {
        return;
    }
    [self.navBarIconHelper resizeNavBarItem:self.trashButton forNavBarHeight:self.navigationController.navigationBar.frame.size.height];
    [self.navBarIconHelper resizeNavBarItem:self.supportButton forNavBarHeight:self.navigationController.navigationBar.frame.size.height];
}

@end
