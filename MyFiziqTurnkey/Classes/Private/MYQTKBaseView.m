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

#import "MYQTKBaseView.h"
#import "MYQTKMyScans.h"
#import "MYQTKTrack.h"
#import "MYQTKNew.h"
#import "MyFiziqTurnkey.h"

@interface MYQTKBaseView()
// - State
@property (assign, nonatomic) BOOL didSetupConstraints;
@end

@implementation MYQTKBaseView

#pragma mark - Init Methods

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
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)updateConstraints {
    [super updateConstraints];
    // Stop memory leaking by only setting constraints once!
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self doUpdateConstraints];
    }
    if ([self respondsToSelector:@selector(refresh)]) {
        [self performSelector:@selector(refresh)];
    }
}

- (void)doUpdateConstraints {
}

- (void)layoutSubviews {
    [super layoutSubviews];
    MFZStyleApply(MyFiziqTurnkeyCommon, self);
    if ([self respondsToSelector:@selector(refresh)]) {
        [self performSelector:@selector(refresh)];
    }
}

#pragma clang diagnostic pop

#pragma mark - Helper Methods

+ (void)goToVC:(UIViewController *)vc {
    if (![MyFiziqSDKCoreLite shared].user.isLoggedIn) {
        return;
    }
    [self presentMyFiziqTurnkeyViewController:vc];
}

+ (void)presentMyFiziqTurnkeyViewController:(UITabBarController *)tabBarController {
    UIViewController *activeViewController = [[MyFiziqTurnkeyCommon shared] topMostViewController];
    // Modal present the MyScans view controller
    if (!tabBarController) {
        return;
    }
    tabBarController.modalPresentationStyle = UIModalPresentationFullScreen;
    [activeViewController presentViewController:tabBarController animated:YES completion:nil];
}

#pragma mark - Actions

+ (void)actionShowAll:(BOOL)showTabBar {
    UITabBarController *tabBarController = [MyFiziqTurnkey shared].tabBarController;
    tabBarController.selectedIndex = 0;
    [tabBarController.tabBar setHidden:!showTabBar];
    [MYQTKBaseView presentMyFiziqTurnkeyViewController:tabBarController];
}

+ (void)actionShowNew:(BOOL)showTabBar {
    UITabBarController *tabBarController = [MyFiziqTurnkey shared].tabBarController;
    tabBarController.selectedIndex = 1;
    [tabBarController.tabBar setHidden:!showTabBar];
    [MYQTKBaseView presentMyFiziqTurnkeyViewController:tabBarController];
}

+ (void)actionShowTrack:(BOOL)showTabBar {
    UITabBarController *tabBarController = [MyFiziqTurnkey shared].tabBarController;
    tabBarController.selectedIndex = 2;
    [tabBarController.tabBar setHidden:!showTabBar];
    [MYQTKBaseView presentMyFiziqTurnkeyViewController:tabBarController];
}

@end
