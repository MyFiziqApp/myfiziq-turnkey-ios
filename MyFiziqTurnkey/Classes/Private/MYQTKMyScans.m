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

#import "MYQTKMyScans.h"
#import <MyFiziqSDKCommon/MyFiziqCommonGalleryView.h>
#import <PureLayout/PureLayout.h>
#import "MYQTKNoAvatarsView.h"
#import "MYQTKSubViewHome.h"
#import "MYQTKNew.h"

// NOTE: Create the layout using PureLayout, not storyboards

// The Button and Label is for demonstration only.

@interface MYQTKMyScans () <MyFiziqCommonGalleryViewDelegate, MYQTKNoAvatarsViewDelegate>
@property (assign, nonatomic) BOOL hasCheckedForAvatars;
@property (assign, nonatomic) NSUInteger currentAvatarsCount;
@property (strong, nonatomic) MyFiziqCommonGalleryView *myqGalleryView;
@property (strong, nonatomic) MYQTKNoAvatarsView *myqNoAvatarsTrackView;
@end

@implementation MYQTKMyScans

#pragma mark - View Elements

- (MyFiziqCommonGalleryView *)myqGalleryView {
    if (!_myqGalleryView) {
        _myqGalleryView = [[MyFiziqCommonGalleryView alloc] initWithAvatars:@[]];
        _myqGalleryView.delegateGallery = self;
        _myqGalleryView.alwaysBounceVertical = YES;
        _myqGalleryView.hidden = YES;
    }
    return _myqGalleryView;
}

- (MYQTKNoAvatarsView *)myqNoAvatarsTrackView {
    if (!_myqNoAvatarsTrackView) {
        _myqNoAvatarsTrackView = [[MYQTKNoAvatarsView alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_GALLERY_TITLE_TEXT", @"You have no 3D body scans")
                                                                detailText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_GALLERY_DETAIL_TEXT", @"At least one body scan is needed to be displayed.")
                                                          shouldShowButton:YES];
        _myqNoAvatarsTrackView.delegate = self;
        _myqNoAvatarsTrackView.hidden = NO;
    }
    return _myqNoAvatarsTrackView;
}

#pragma mark - Lifecycle

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-myscans-view");
    self.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_TITLE_MY_SCANS", @"My Scans");
    [self.view addSubview:self.myqGalleryView];
    [self.view addSubview:self.myqNoAvatarsTrackView];
}

- (void)commonSetContraints {
    [self.myqGalleryView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.myqGalleryView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.myqGalleryView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.myqGalleryView autoPinEdgeToSuperviewSafeArea:ALEdgeTop];
    [self.myqNoAvatarsTrackView autoPinEdgesToSuperviewSafeArea];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAvatarsCount];
}

#pragma mark - Private Methods

- (void)checkAvatarsCount {
    NSUInteger count = [[[MyFiziqSDK shared].avatars all] count];
    self.myqGalleryView.hidden = count < 1;
    self.myqNoAvatarsTrackView.hidden = count > 0;
    if ((count < 1 && !self.hasCheckedForAvatars) || self.currentAvatarsCount != count) {
        self.currentAvatarsCount = count;
        [self didPullToRefreshwithCompletion:nil];
    }
    [self.myqGalleryView updateAvatars:[[MyFiziqSDK shared].avatars all]];
}

#pragma mark - Actions

- (IBAction)didTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gallery Delegates

- (void)didTapAvatar:(id<MyFiziqCommonAvatarDelegate> _Nonnull)avatar {
    MyFiziqAvatar *selectedAvatar = (MyFiziqAvatar *)avatar;
    if (!avatar.isCompleted) {
        return;
    }
    // If delegate is implemented means that another view/controller wishes to handle the selection.
    if (self.delegate) {
        if (![self.delegate respondsToSelector:@selector(didSelectAvatar:fromMyScansViewController:)]) {
            NSLog(@"The delegate method for %@ has not been implemented.", [self description]);
            return;
        }
        [self.delegate didSelectAvatar:selectedAvatar fromMyScansViewController:self];
        return;
    }
    MYQTKSubViewHome *homeVC = [[MYQTKSubViewHome alloc] init];
    [self.navigationController showViewController:homeVC sender:self];
    [homeVC setSelectedAvatar:selectedAvatar];
}

- (void)didPullToRefreshwithCompletion:(void (^ _Nullable)(NSArray<id<MyFiziqCommonAvatarDelegate>> * _Nullable result, NSError * _Nullable error))completion {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.hasCheckedForAvatars = YES;
        [[[MyFiziqSDK shared] avatars] requestAvatarsWithSuccess:^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self checkAvatarsCount];
                if (completion) {
                    completion(@[], nil);
                }
            }];
        } failure:^(NSError * _Nullable error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self checkAvatarsCount];
                if (completion) {
                    completion(@[], error);
                }
            }];
        }];
    }];
}

#pragma mark - No Avatars View Delegate

- (void)didTapNoAvatarsViewButtonFromView:(MYQTKNoAvatarsView * _Nonnull)noAvatarsView {
    MYQTKNew *newVC = [MYQTKNew new];
    [self.navigationController showViewController:newVC sender:self];
}

@end
