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

#import "UserRegisterViewController.h"
#import "IdentityProviderHelper.h"

/*
 OPTIONAL: This view allows the user to register a new account.
 WARNING: This example does not verify the user or depend on multi factor authentication (MFA), but it is recommended
 that some verification is made to avoid possible bot registration from occurring.
 */

@interface UserRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordAField;
@property (weak, nonatomic) IBOutlet UITextField *passwordBField;
// OPTIONAL: Helper class for authenticating a user.
@property (nonatomic, readonly) IdentityProviderHelper *idp;
@end

@implementation UserRegisterViewController

#pragma mark Property methods

- (IdentityProviderHelper *)idp {
    return [IdentityProviderHelper shared];
}

#pragma mark Methods

- (void)setUserEmail:(NSString *)email {
    self.emailField.text = email;
}

- (void)registrationSuccess {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeScreen"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        self.emailField.text = @"";
        self.passwordAField.text = @"";
        self.passwordBField.text = @"";
    }];
    // TURNKEY EXAMPLE: User logged in (authenticated), so authorize the user to the MyFiziq service.
    [[IdentityProviderHelper shared] myfiziqTurnkeyAuth];
}

- (void)registrationFailedWithError:(NSError *)error {
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Registration Failed";
    alert.message = @"Failed to register new user. Please try again or contact support.";
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self.emailField becomeFirstResponder];
                                                     }];
    // NOTE: Modify message based on explicit AWS errors.
    if (error) {
        switch (error.code) {
            case AWSCognitoIdentityProviderErrorInvalidPassword:
            case AWSCognitoIdentityProviderErrorNotAuthorized: {
                alert.message = @"Password not acceptable.";
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
    // NOTE: Validate input before attempting to registering the user.
    kAuthValidation validation = [self.idp validateEmail:self.emailField.text
                                               passwordA:self.passwordAField.text
                                               passwordB:self.passwordBField.text];
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
            // NOTE: Attempt user registration.
            alert.title = @"Registering user...";
            [self showViewController:alert sender:self];
            [self.idp userRegistrationWithEmail:self.emailField.text password:self.passwordAField.text completion:^(NSError *err) {
                // NOTE: Cannot guarantee completion block is on main thread. So submit block to main thread queue.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [alert dismissViewControllerAnimated:NO completion:^{
                        if (err) {
                            [self registrationFailedWithError:err];
                        } else {
                            [self registrationSuccess];
                        }
                    }];
                }];
            }];
            break;
        }
    }
}

@end

