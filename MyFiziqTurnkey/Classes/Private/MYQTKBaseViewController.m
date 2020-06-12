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
            NSForegroundColorAttributeName:MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkWhiteColor"),
            NSFontAttributeName:MFZStyleVarFont(MyFiziqTurnkeyCommon, @"myqtkNavigationBarTitleFont")
        };
        NSDictionary *largeAttributes = @{
            NSForegroundColorAttributeName:MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkWhiteColor"),
            NSFontAttributeName:MFZStyleVarFont(MyFiziqTurnkeyCommon, @"myqtkNavigationBarLargeTitleFont")
        };
        if (@available(iOS 13, *)) {
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            [appearance configureWithOpaqueBackground];
            appearance.titleTextAttributes = titleAttributes;
            appearance.largeTitleTextAttributes = largeAttributes;
            appearance.backgroundColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavBarColor");
            self.navigationController.navigationBar.standardAppearance = appearance;
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        } else {
            self.navigationController.navigationBar.largeTitleTextAttributes = largeAttributes;
            self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
            self.navigationController.navigationBar.barTintColor = MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkNavBarColor");
        }
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CLOSE", @"close")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
        [buttonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:MFZStyleVarFont(MyFiziqTurnkeyCommon, @"myqtkNavigationBarButtonFont"),
                                            NSFontAttributeName, MFZStyleVarColor(MyFiziqTurnkeyCommon, @"myqtkHighlightColor"),
                                            NSForegroundColorAttributeName, nil]
                                  forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Stop memory leaking by only setting constraints once!
    if (!self.didSetupConstraints && [self respondsToSelector:@selector(commonSetContraints)]) {
        self.didSetupConstraints = YES;
        [self performSelector:@selector(commonSetContraints)];
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
