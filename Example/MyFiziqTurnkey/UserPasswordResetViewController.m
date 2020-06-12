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

#import "UserPasswordResetViewController.h"
#import "IdentityProviderHelper.h"

/*
 OPTIONAL: This view is the subsequent step for resetting a user password (eg: user forgot password). The expectation
 is for the user to enter the reset code received from AWS Cognito User Pool service (this can be styled and routed
 as company specific) along with a new password, to effectively reset the user's password and log them in to the
 service.
 */

@interface UserPasswordResetViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *resetCodeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordAField;
@property (weak, nonatomic) IBOutlet UITextField *passwordBField;
// OPTIONAL: Helper class for authenticating a user.
@property (nonatomic, readonly) IdentityProviderHelper *idp;
@end

@implementation UserPasswordResetViewController

#pragma mark Property methods

- (IdentityProviderHelper *)idp {
    return [IdentityProviderHelper shared];
}

#pragma mark Methods

- (void)setUserEmail:(NSString *)email {
    self.emailField.text = email;
}

/*
 OPTIONAL: Now that a password reset code has been delivered to the user's email or phone. Present the next screen to
 allow the user to enter the reset code challenge and set a new password.
 */
- (void)passwordResetSuccess {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = (UserPasswordResetViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"HomeScreen"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        self.emailField.text = @"";
        self.resetCodeField.text = @"";
        self.passwordAField.text = @"";
        self.passwordBField.text = @"";
    }];
    // TURNKEY EXAMPLE: User logged in (authenticated), so authorize the user to the MyFiziq service.
    [[IdentityProviderHelper shared] myfiziqTurnkeyAuth];
}

- (void)passwordResetFailedWithError:(NSError *)error {
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Reset Failed";
    alert.message = @"Failed to reset user password. Please try again or contact support.";
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self.resetCodeField becomeFirstResponder];
                                                     }];
    // NOTE: Modify message based on explicit AWS errors.
    if (error) {
        switch (error.code) {
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
        self.resetCodeField.text = @"";
        self.passwordAField.text = @"";
        self.passwordBField.text = @"";
    }];
}

- (IBAction)goButtonTap:(id)sender {
    [self.view endEditing:YES];
    __block UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Invalid Entry";
    // NOTE: Validate email before attempting to submit reset code to the address. Dummy password string used so
    // validation function can just concentrate on the email input.
    kAuthValidation validation = [self.idp validateEmail:self.emailField.text
                                               passwordA:self.passwordAField.text
                                               passwordB:self.passwordBField.text];
    // NOTE: Validate that reset code has been entered. Make new arbitrary value to the validation variable to flag this
    // scenario.
    if (!self.resetCodeField.text || [self.resetCodeField.text isEqualToString:@""]) {
        validation = 100;
    }
    switch (validation) {
        case 100: {
            alert.message = @"Please enter the reset code.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.resetCodeField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            [self showViewController:alert sender:self];
            break;
        }
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
        case kAuthValidationNoPassword: {
            alert.message = @"Please enter a password.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.passwordAField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            [self showViewController:alert sender:self];
            break;
        }
        case kAuthValidationPasswordTooShort: {
            alert.message = @"Please enter a valid password (must be 6 or more characters).";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.passwordAField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            [self showViewController:alert sender:self];
            break;
        }
        case kAuthValidationPasswordsNotEqual: {
            alert.message = @"Passwords don't match. Please re-enter the same password.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.passwordBField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            [self showViewController:alert sender:self];
            break;
        }
        default: {
            // NOTE: Attempt submit of password reset.
            alert.title = @"Setting new password...";
            [self showViewController:alert sender:self];
            [self.idp userPasswordResetConfirmWithEmail: self.emailField.text resetCode:self.resetCodeField.text newPassword:self.passwordAField.text completion:^(NSError *err) {
                // NOTE: Cannot garuntee completion block is on main thread. So submit block to main thread queue.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [alert dismissViewControllerAnimated:NO completion:^{
                        if (err) {
                            [self passwordResetFailedWithError:err];
                        } else {
                            [self passwordResetSuccess];
                        }
                    }];
                }];
            }];
            break;
        }
    }
}

@end

