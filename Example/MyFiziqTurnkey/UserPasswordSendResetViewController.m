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

#import "UserPasswordSendResetViewController.h"
#import "IdentityProviderHelper.h"
#import "UserPasswordResetViewController.h"

/*
 OPTIONAL: This view is the initial step for resetting a user password (eg: user forgot password). AWS Cognito User Pool
 service will send a reset code to the registered email/mobile to verify that the user is the actual user intending for
 password reset.
 */

@interface UserPasswordSendResetViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
// OPTIONAL: Helper class for authenticating a user.
@property (nonatomic, readonly) IdentityProviderHelper *idp;
@end

@implementation UserPasswordSendResetViewController

#pragma mark Property methods

- (IdentityProviderHelper *)idp {
    return [IdentityProviderHelper shared];
}

#pragma mark Methods

- (void)setUserEmail:(NSString *)email {
    self.emailField.text = email;
}

- (void)attemptPasswordReset {
    __block UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Invalid Entry";
    // NOTE: Validate email before attempting to submit reset code to the address. Dummy password string used so
    // validation function can just concentrate on the email input.
    kAuthValidation validation = [self.idp validateEmail:self.emailField.text
                                               passwordA:@"dummy_password"
                                               passwordB:@"dummy_password"];
    switch (validation) {
        case kAuthValidationNoEmail: {
            alert.message = @"Please enter an email address.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.emailField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            [self showViewController:alert sender:self];
            break;
        }
        case kAuthValidationInvalidEmail: {
            alert.message = @"Please enter a valid email address.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.emailField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            [self showViewController:alert sender:self];
            break;
        }
        default: {
            // NOTE: Attempt submit of reset code.
            alert.title = @"Submitting reset code...";
            [self showViewController:alert sender:self];
            [self.idp userPasswordResetRequestWithEmail:self.emailField.text completion:^(NSError *err) {
                // NOTE: Cannot garuntee completion block is on main thread. So submit block to main thread queue.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [alert dismissViewControllerAnimated:NO completion:^{
                        if (err) {
                            [self passwordResetRequestFailedWithError:err];
                        } else {
                            [self passwordResetRequestSuccess];
                        }
                    }];
                }];
            }];
            break;
        }
    }
}

/*
 OPTIONAL: Now that a password reset code has been delivered to the user's email or phone. Present the next screen to
 allow the user to enter the reset code challenge and set a new password.
 */
- (void)passwordResetRequestSuccess {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserPasswordResetViewController *vc = (UserPasswordResetViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"UserPasswordResetScreen"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        [vc setUserEmail:self.emailField.text];
        self.emailField.text = @"";
    }];
}

- (void)passwordResetRequestFailedWithError:(NSError *)error {
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Reset Failed";
    alert.message = @"Failed to send reset code to email. Please try again or contact support.";
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self.emailField becomeFirstResponder];
                                                     }];
    // NOTE: Modify message based on explicit AWS errors.
    if (error) {
        switch (error.code) {
            case AWSCognitoIdentityProviderErrorUserNotFound: {
                alert.message = @"User not found. Please register first.";
                break;
            }
            case -2: {
                alert.message = @"User with enter email not found.";
                break;
            }
            case -3: {
                alert.message = @"Service timed out. Please try again later.";
                break;
            }
            default: {
                break;
            }
        }
    }
    [alert addAction:okAction];
    [self showViewController:alert sender:self];
}

#pragma mark Button responders

- (IBAction)backButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        self.emailField.text = @"";
    }];
}

- (IBAction)submitResetButtonTap:(id)sender {
    [self.view endEditing:YES];
    __block UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Reset Password";
    alert.message = @"A reset code will be sent to your email. Do you want to continue?";
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:noAction];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self attemptPasswordReset];
                                                      }];
    [alert addAction:yesAction];
    [self showViewController:alert sender:self];
}

@end
