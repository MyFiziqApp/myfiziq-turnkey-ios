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

#import "MYQTKBaseViewController.h"

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKBaseViewController ()
@property (assign, nonatomic) BOOL didSetupConstraints;
@end

@implementation MYQTKBaseViewController

#pragma mark - Init Methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.view.subviews.count == 0 && [self respondsToSelector:@selector(commonInit)]) {
        [self performSelector:@selector(commonInit)];
    }
    if (self.navigationController) {
        NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName:MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavigationBarTitleColor"),
            NSFontAttributeName:MFZStyleVarFont(MyFiziqTurnkeyCommon, @"myqtkNavigationBarTitleFont")
        };
        NSDictionary *largeAttributes = @{
            NSForegroundColorAttributeName:MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavigationBarTitleColor"),
            NSFontAttributeName:MFZStyleVarFont(MyFiziqTurnkeyCommon, @"myqtkNavigationBarLargeTitleFont")
        };
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.titleTextAttributes = titleAttributes;
        appearance.largeTitleTextAttributes = largeAttributes;
        appearance.backgroundColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavigationBarBackgroundColor");
        appearance.shadowColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavigationBarSeparatorColor");
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.barTintColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavigationBarBackgroundColor");
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        UIBarButtonItem *buttonItem;
        BOOL useCustomImage = [MFZStyleVarBool(MyFiziqTurnkeyCommon, @"myqtkUseCustomeBackImage") boolValue];
        BOOL useDefaultChevron = [MFZStyleVarBool(MyFiziqTurnkeyCommon, @"myqtkUseDefaultNavigationBackChevron") boolValue];
        if (useCustomImage) {
            UIImage *customImage = MFZImage(MyFiziqTurnkeyCommon, @"mfztk-back-button-image");
            buttonItem = [[UIBarButtonItem alloc] initWithImage:customImage
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(backButtonAction:)];
        } else if (useDefaultChevron) {
            buttonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage systemImageNamed:@"chevron.left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(backButtonAction:)];
            buttonItem.tintColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"mfzCommonSDKColorFeature");
        } else {
            buttonItem = [[UIBarButtonItem alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CLOSE", @"Close")
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(backButtonAction:)];
            [buttonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:MFZStyleVarFont(MyFiziqTurnkeyCommon, @"myqtkNavigationBarButtonFont"),
                                                NSFontAttributeName, MFZStyleVarColor(MyFiziqTurnkeyCommon, @"mfzCommonSDKColorFeature"),
                                                NSForegroundColorAttributeName, nil]
                                      forState:UIControlStateNormal];
        }
        self.navigationItem.leftBarButtonItem = buttonItem;
        // TAB BAR STYLING
        UITabBarAppearance *tabAppearance = [[UITabBarAppearance alloc] init];
        tabAppearance.backgroundColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkTabBarBackgroundColor");
        tabAppearance.shadowColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavigationBarSeparatorColor");
        [self.tabBarController.tabBar setStandardAppearance:tabAppearance];
        self.tabBarController.tabBar.translucent = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Stop memory leaking by only setting constraints once!
    if (!self.didSetupConstraints && [self respondsToSelector:@selector(commonSetContraints)]) {
        self.didSetupConstraints = YES;
        [self performSelector:@selector(commonSetContraints)];
    }
    [self setUserInterfaceStyle];
}

- (void)setUserInterfaceStyle {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"MyFiziqDarkModeActive"] boolValue]) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    MFZStyleApply(MyFiziqTurnkeyCommon, self.view);
}

- (IBAction)backButtonAction:(id)sender {
    if (self.navigationController && [self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma clang diagnostic pop

@end
