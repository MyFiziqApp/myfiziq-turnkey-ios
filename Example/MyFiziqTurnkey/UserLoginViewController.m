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

#import "UserLoginViewController.h"
#import "IdentityProviderHelper.h"
#import "UserRegisterViewController.h"
#import "UserPasswordSendResetViewController.h"

/*
 OPTIONAL: This is an example implementation of utilizing the AWS Cognito UserPool service for user login. A complete
 example can be viewed in the AWS documentation or the sample app:
 https://github.com/awslabs/aws-sdk-ios-samples/tree/master/CognitoYourUserPools-Sample
 
 WARNING: It is not recommended that this example implementation be used for production, as it does not facilitate all
 scenarios/challenges that AWS Cognito User Pool service can produce.
 */

@interface UserLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
// OPTIONAL: Helper class for authenticating a user.
@property (nonatomic, readonly) IdentityProviderHelper *idp;
@end

@implementation UserLoginViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL isDarkMode = [[UIScreen mainScreen] traitCollection].userInterfaceStyle == UIUserInterfaceStyleDark;
    UIColor *textColor = isDarkMode ? [UIColor whiteColor] : [UIColor blackColor];
    UIColor *bgColor = isDarkMode ? [UIColor blackColor] : [UIColor whiteColor];
    self.emailField.textColor = textColor;
    self.passwordField.textColor = textColor;
    self.emailField.backgroundColor = bgColor;
    self.passwordField.backgroundColor = bgColor;
}

#pragma mark Property methods

- (IdentityProviderHelper *)idp {
    return [IdentityProviderHelper shared];
}

#pragma mark Methods

- (void)loginSuccess {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeScreen"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        self.emailField.text = @"";
        self.passwordField.text = @"";
    }];
    // TURNKEY EXAMPLE: User logged in (authenticated), so authorize the user to the MyFiziq service.
    [[IdentityProviderHelper shared] myfiziqTurnkeyAuth];
}

- (void)loginFailedWithError:(NSError *)error {
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Authentication Failed";
    alert.message = @"Failed to authenticate. Please try again.";
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
                alert.message = @"Incorrect password.";
                break;
            }
            case -2:
            case AWSCognitoIdentityProviderErrorUserNotFound: {
                alert.message = @"User not found. Please register first.";
                break;
            }
            case -3: {
                alert.message = @"Authentication timed out. Please try again later.";
                break;
            }
            case AWSCognitoIdentityProviderErrorPasswordResetRequired: {
                alert.message = @"A password reset is required for this user. A reset code will be sent to the entered email address.";
                okAction = [UIAlertAction actionWithTitle:@"RESET PASSWORD"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      [self forgotPasswordButtonTap:self];
                                                  }];
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

- (void)showPasswordReset {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserPasswordSendResetViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPasswordResetSendScreen"];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        [vc setUserEmail:self.emailField.text];
        self.passwordField.text = @"";
    }];
}

#pragma mark Button responders

- (IBAction)goButtonTap:(id)sender {
    [self.view endEditing:YES];
    __block UIAlertController *alert = [[UIAlertController alloc] init];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake((self.view.bounds.size.width / 2) + self.view.bounds.origin.x, (self.view.bounds.size.height / 2) + self.view.bounds.origin.y, 0, 0);
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.title = @"Invalid Entry";
    // NOTE: Validate input before attempting to authenticate the user.
    kAuthValidation validation = [self.idp validateEmail:self.emailField.text
                                               passwordA:self.passwordField.text
                                               passwordB:self.passwordField.text];
    switch (validation) {
        case kAuthValidationNoEmail: {
            alert.message = @"Please enter an email address.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.emailField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
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
            break;
        }
        case kAuthValidationNoPassword: {
            alert.message = @"Please enter a password.";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.passwordField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            break;
        }
        case kAuthValidationPasswordTooShort: {
            alert.message = @"Please enter a valid password (must be 6 or more characters).";
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self.passwordField becomeFirstResponder];
                                                             }];
            [alert addAction:okAction];
            break;
        }
        default: {
            // NOTE: kAuthValidationPasswordsNotEqual should not be possible, so capture in default along with
            // kAuthValidationIsValid. Attempt user authentication.
            alert.title = @"Authenticating...";
            [self.idp userLoginWithEmail:self.emailField.text password:self.passwordField.text completion:^(NSError *err) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // NOTE: AWS return cannot be guaranteed to be on main queue. So handle result on operation block.
                    [alert dismissViewControllerAnimated:NO completion:^{
                        if (err) {
                            [self loginFailedWithError:err];
                        } else {
                            [self loginSuccess];
                        }
                    }];
                }];
            }];
            break;
        }
    }
    [self showViewController:alert sender:self];
}

/*
 NOTE: This will show the password reset view, which requires the user to enter a reset code sent from AWS Cognito to
 the user's email.
 */
- (IBAction)forgotPasswordButtonTap:(id)sender {
    [self showPasswordReset];
}

- (IBAction)newUserButtonTap:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserRegisterViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserRegisterScreen"];
    [self presentViewController:vc animated:YES completion:^{
        [vc setUserEmail:self.emailField.text];
        self.passwordField.text = @"";
    }];
}

@end

