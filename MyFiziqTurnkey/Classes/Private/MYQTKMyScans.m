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
#import <MyFiziqSDKCommon/MyFiziqCommonGalleryCardView.h>
#import <PureLayout/PureLayout.h>
#import "MYQTKNoAvatarsView.h"
#import "MYQTKSubViewHome.h"
#import "MYQTKNew.h"
#import "MyFiziqTurnkey.h"

// NOTE: Create the layout using PureLayout, not storyboards

// The Button and Label is for demonstration only.

@interface MYQTKMyScans () <MyFiziqCommonGalleryViewDelegate, MYQTKNoAvatarsViewDelegate>
@property (assign, nonatomic) BOOL hasCheckedForAvatars;
@property (assign, nonatomic) NSUInteger currentAvatarsCount;
@property (strong, nonatomic) MyFiziqCommonGalleryCardView *myqCardGalleryView;
@property (strong, nonatomic) MYQTKNoAvatarsView *myqNoAvatarsTrackView;
@property (nonatomic, strong) NSTimer *pollingTimer;
@end

@implementation MYQTKMyScans

#pragma mark - View Elements

- (MyFiziqCommonGalleryCardView *)myqCardGalleryView {
    if (!_myqCardGalleryView) {
        _myqCardGalleryView = [[MyFiziqCommonGalleryCardView alloc] init];
        _myqCardGalleryView.delegateGallery = self;
    }
    return _myqCardGalleryView;
}

- (MYQTKNoAvatarsView *)myqNoAvatarsTrackView {
    if (!_myqNoAvatarsTrackView) {
        BOOL showNewButton = [MyFiziqTurnkey shared].datasource ? [[MyFiziqTurnkey shared].datasource newScansAllowed] : NO;
        if (showNewButton) {
            _myqNoAvatarsTrackView = [[MYQTKNoAvatarsView alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_GALLERY_TITLE_TEXT", @"No Body Scans")
                                                                    detailText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_GALLERY_DETAIL_TEXT", @"At least one body scan is needed to be displayed.")
                                                              shouldShowButton:YES];
        } else {
            _myqNoAvatarsTrackView = [[MYQTKNoAvatarsView alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ONLY_GALLERY_TITLE", @"No Body Scans")
                                                                    detailText:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_NO_AVATARS_VIEW_ONLY_GALLERY_DETAIL", @"Renew your subscription\nto take a Body Scan.")
                                                              shouldShowButton:NO];
        }
        
        _myqNoAvatarsTrackView.delegate = self;
        _myqNoAvatarsTrackView.hidden = NO;
    }
    return _myqNoAvatarsTrackView;
}

#pragma mark - Lifecycle

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-myscans-view");
    self.navigationItem.title = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_TITLE_MY_SCANS", @"My Scans");
    [self.view addSubview:self.myqCardGalleryView];
    [self.view addSubview:self.myqNoAvatarsTrackView];
}

- (void)commonSetContraints {
    [self.myqCardGalleryView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.myqCardGalleryView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.myqCardGalleryView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.myqCardGalleryView autoPinEdgeToSuperviewSafeArea:ALEdgeTop];
    [self.myqNoAvatarsTrackView autoPinEdgesToSuperviewSafeArea];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAvatarsCount];
    // Poll for new results
    if (!self.pollingTimer) {
        NSTimeInterval pollDelay = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkMyScansRefreshPollWaitTimeSeconds") doubleValue];
        self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:pollDelay repeats:YES block:^(NSTimer * _Nonnull timer) {
            // NOTE: Poll the server for state changes.
            [self didPullCardViewGalleryRefreshwithCompletion:nil];
        }];
    }
    // Subscribe to result update events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRequested:)
                                                 name:MFZCommonGalleryCardRequestRefresh
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // Stop polling
    if (self.pollingTimer) {
        [self.pollingTimer invalidate];
        self.pollingTimer = nil;
    }
    // Un-subscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)checkAvatarsCount {
    NSUInteger count = [[[MyFiziqSDKCoreLite shared].avatars all] count];
    self.myqCardGalleryView.hidden = count < 1;
    self.myqNoAvatarsTrackView.hidden = count > 0;
    if ((count < 1 && !self.hasCheckedForAvatars) || self.currentAvatarsCount != count) {
        self.currentAvatarsCount = count;
        [self didPullCardViewGalleryRefreshwithCompletion:nil];
    }
    [self.myqCardGalleryView updateAvatarModels:[[MyFiziqSDKCoreLite shared].avatars all] measurementPreference:[MyFiziqSDKCoreLite shared].user.measurementPreference];
}

- (void)refreshRequested:(NSNotification *)notification {
    MFZLog(MFZLogLevelInfo, @"Scan results updated externally, refreshing view...");
    // NOTE: Cannot garuntee success will occur on main thread. So issue to main thread queue.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // NOTE: Poll the server for state changes.
        [self didPullCardViewGalleryRefreshwithCompletion:nil];
    });
}

#pragma mark - Actions

- (IBAction)didTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - No Avatars View Delegate

- (void)didTapNoAvatarsViewButtonFromView:(MYQTKNoAvatarsView * _Nonnull)noAvatarsView {
    MYQTKNew *newVC = [MYQTKNew new];
    [self.navigationController showViewController:newVC sender:self];
}

#pragma mark -  MyFiziqCommonGalleryCardViewDelegate

- (void)didPullCardViewGalleryRefreshwithCompletion:(void (^ _Nullable)(NSArray<id<MyFiziqCommonAvatarDelegate>> * _Nullable result, NSError * _Nullable error))completion {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.hasCheckedForAvatars = YES;
        [[[MyFiziqSDKCoreLite shared] avatars] requestAvatarsWithSuccess:^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self checkAvatarsCount];
                if (completion) {
                    completion([[[MyFiziqSDKCoreLite shared] avatars] all], nil);
                }
            }];
        } failure:^(NSError * _Nullable error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self checkAvatarsCount];
                if (completion) {
                    completion([[[MyFiziqSDKCoreLite shared] avatars] all], nil);
                }
            }];
        }];
    }];
}

- (void)didSelectCardViewAvatar:(id<MyFiziqCommonAvatarDelegate> _Nonnull)avatar {
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
 

@end
