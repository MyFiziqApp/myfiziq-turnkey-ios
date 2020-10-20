//
//  MyFiziq-Boilerplate
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

#import "HomeViewController.h"
@import AWSCore;
#import "IdentityProviderHelper.h"
#import "UserLoginViewController.h"
#import "SettingsViewController.h"
// TURNKEY EXAMPLE: Add import of Turnkey module to add Turnkey card view
@import MyFiziqTurnkey;

/*
 OPTIONAL: This "home" view provides a simple implementation of viewing the MyFiziq avatar results, avatar management,
 and to initiate the new avatar creation process.
 */

#define AVATAR_REFRESH_INTERVAL         10.0
#define NOTIFICATION_AVATAR_REFRESH     @"kNotificationAvatarRefresh"

@interface HomeViewController ()
// OPTIONAL: Helper class for user logout.
@property (nonatomic, readonly) IdentityProviderHelper *idp;
// OPTIONAL: The avatar state should be periodically be re-synced to inform the user when a new avatar has been created
// TURNKEY EXAMPLE: In this example, using storyboard to add the Turnkey view - otherwise programmatic add is equally acceptable.
@property (weak, nonatomic) IBOutlet MyFiziqTurnkeyView *myfiziqTurnkeyView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSegmentControl;
@end


@implementation HomeViewController

#pragma mark Property methods

// OPTIONAL: These properties are just for convenience to help keep the code tidy.

- (IdentityProviderHelper *)idp {
    return [IdentityProviderHelper shared];
}

#pragma mark View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unitSegmentControl.layer.cornerRadius = 5.0;
    self.unitSegmentControl.layer.masksToBounds = YES;
    if (@available(iOS 13.0, *)) {
        self.unitSegmentControl.selectedSegmentTintColor = [UIColor brownColor];
    } else {
        self.unitSegmentControl.tintColor = [UIColor brownColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"MeasurementPreference"] == nil) {
        [MyFiziqSDKCoreLite shared].user.measurementPreference = MFZMeasurementMetric;
        self.unitSegmentControl.selectedSegmentIndex = 0;
        [self saveMeasurementToUserDefaults];
    } else {
        int measurementPreference = [[[NSUserDefaults standardUserDefaults] valueForKey:@"MeasurementPreference"] intValue];
        [MyFiziqSDKCoreLite shared].user.measurementPreference = measurementPreference == 0 ? MFZMeasurementMetric : MFZMeasurementImperial;
        self.unitSegmentControl.selectedSegmentIndex = measurementPreference;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark Methods

- (void)userLogout {
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Logging out...";
    [self showViewController:alert sender:self];
    // NOTE: Log out the user session.
    [self.idp userLogoutWithCompletion:^(NSError *err) {
        if (!err || err.code == 2) {
            NSLog(@"User signed out. Dismissing to Login Screen.");
            [alert dismissViewControllerAnimated:NO completion:^{
                // NOTE: Dismiss to the login view controller if it is the parent view controller.
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            // TURNKEY EXAMPLE: Un-authorize the user from the MyFiziq service.
            [[MyFiziqTurnkey shared] userUnauthenticateWithCompletion:nil];
        } else {
            NSLog(@"ERROR: Failed user log out.");
            [alert dismissViewControllerAnimated:NO completion:^{
                alert.title = @"Error";
                alert.message = @"Failed to logout at this time. Please contact support.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                [alert addAction:okAction];
                [self showViewController:alert sender:self];
            }];
        }
    }];
}

#pragma mark Button and notification responders

- (IBAction)userLogoutTap:(id)sender {
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Logout";
    alert.message = @"Are you sure you wish to logout?";
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:noAction];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self userLogout];
                                                      }];
    [alert addAction:yesAction];
    [self showViewController:alert sender:self];
}

- (IBAction)didSelectUnit:(id)sender {
    if (self.unitSegmentControl.selectedSegmentIndex == 0) {
        [MyFiziqSDKCoreLite shared].user.measurementPreference = MFZMeasurementMetric;
    } else {
        [MyFiziqSDKCoreLite shared].user.measurementPreference = MFZMeasurementImperial;
    }
    [self saveMeasurementToUserDefaults];
}

- (IBAction)didSelectSettings:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController *settingsVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    settingsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsVC animated:true completion:nil];
}

- (void)saveMeasurementToUserDefaults {
    [[NSUserDefaults standardUserDefaults] setValue:[MyFiziqSDKCoreLite shared].user.measurementPreference == MFZMeasurementImperial ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0] forKey:@"MeasurementPreference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.myfiziqTurnkeyView refresh];
}

@end

