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

#import "IdentityProviderHelper.h"
@import AWSLambda;

#define MIN_PASSWORD_LENGTH             6
#define MAX_AUTH_TIMEOUT_SEC            60
#define EXAMPLE_APP_NAME                @"MyFiziq-Example"

// For app to mimic a partner (which will have their own user auth / idp), this app uses a different idP than the MyFiziqSDK
// service.
#define MFTK_AWS_COGNITO_REGION         @"REPLACE ME"
#define MFTK_AWS_CLIENT_ID              @"REPLACE ME"
#define MFTK_AWS_USERPOOL_ID            @"REPLACE ME"
#define MFTK_AWS_FEDERATION_ID          @"REPLACE ME"
#define MFTK_AWS_ACC_ID                 @"REPLACE ME"
#define MFTK_APP_ID                     @"REPLACE ME"
#define MFTK_VENDOR                     @"REPLACE ME"
#define MFTK_ENV                        @"REPLACE ME"


@implementation IdentityProviderHelper

#pragma mark Property methods

- (AWSServiceConfiguration *)awsServiceConfiguration {
    if (!_awsServiceConfiguration) {
        _awsServiceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:[MFTK_AWS_COGNITO_REGION aws_regionTypeValue]
                                                               credentialsProvider:nil];
    }
    return _awsServiceConfiguration;
}

- (AWSCognitoIdentityUserPoolConfiguration *)awsUserPoolConfig {
    if (!_awsUserPoolConfig) {
        _awsUserPoolConfig = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:MFTK_AWS_CLIENT_ID
                                                                                  clientSecret:nil
                                                                                        poolId:MFTK_AWS_USERPOOL_ID];
    }
    return _awsUserPoolConfig;
}

- (AWSCognitoIdentityUserPool *)awsUserPool {
    if (!_awsUserPool) {
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:self.awsServiceConfiguration
                                                               userPoolConfiguration:self.awsUserPoolConfig
                                                                              forKey:EXAMPLE_APP_NAME];
        _awsUserPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:EXAMPLE_APP_NAME];
    }
    return _awsUserPool;
}

- (AWSCognitoIdentityUser *)currentUser {
    return [self.awsUserPool currentUser];
}

- (AWSLambdaInvoker *)lambda {
    return [AWSLambdaInvoker LambdaInvokerForKey:@"MyFiziqTurnkey"];
}

- (NSString *)awsUserPoolKey {
    return [NSString stringWithFormat:@"cognito-idp.%@.amazonaws.com/%@", MFTK_AWS_COGNITO_REGION, MFTK_AWS_USERPOOL_ID];
}

#pragma mark Methods

+ (instancetype)shared {
    static IdentityProviderHelper *idp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idp = [[IdentityProviderHelper alloc] init];
        AWSCognitoCredentialsProvider *awsCredProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:[MFTK_AWS_COGNITO_REGION aws_regionTypeValue] identityPoolId:MFTK_AWS_FEDERATION_ID identityProviderManager:idp];
        AWSServiceConfiguration *awsServiceConfig = [[AWSServiceConfiguration alloc] initWithRegion:[MFTK_AWS_COGNITO_REGION aws_regionTypeValue] credentialsProvider:awsCredProvider];
        [AWSLambdaInvoker registerLambdaInvokerWithConfiguration:awsServiceConfig forKey:@"MyFiziqTurnkey"];
    });
    return idp;
}

#pragma mark User authentication methods

/*
 NOTE: The following methods are for AWS Cognito User Pool construction and usage, which is used in this example for
 demonstration, but not required for the MyFiziqSDK. You can find more information on the AWS Cognito Mobile SDK from
 this site: http://docs.aws.amazon.com/cognito/latest/developerguide/tutorial-integrating-user-pools-ios.html .
 When a user is authenticated with the idP, the MyFiziqSDK User -logInWithEmail:completion: method must be called to
 authorize the user for the MyFiziq service.
 */

- (BOOL)userIsSignedIn {
    return (self.currentUser && self.currentUser.username && ![self.currentUser.username isEqualToString:@""] && self.currentUser.isSignedIn);
}

/*
 NOTE: This method check if the data entered into the fields are valid. Return if user authentication can proceed.
 */
- (kAuthValidation)validateEmail:(NSString *)email passwordA:(NSString *)passA passwordB:(NSString *)passB {
    // NOTE: Validate email.
    if (!email || [email isEqualToString:@""]) {
        return kAuthValidationNoEmail;
    }
    NSError *error;
    [[SpotHeroEmailValidator validator] validateSyntaxOfEmailAddress:email withError:&error];
    if (error) {
        return kAuthValidationInvalidEmail;
    }
    // NOTE: Validate password.
    if (!passA || !passB || [passA isEqualToString:@""] || [passB isEqualToString:@""]) {
        return kAuthValidationNoPassword;
    }
    if (passA.length < MIN_PASSWORD_LENGTH) {
        return kAuthValidationPasswordTooShort;
    }
    if (![passA isEqualToString:passB]) {
        return kAuthValidationPasswordsNotEqual;
    }
    // NOTE: Inputs did not return as invalid, so return as valid.
    return kAuthValidationIsValid;
}

/*
 NOTE: Attempts to authenticate the user with the AWS Cognito User Pool idP service.
 */
- (void)userLoginWithEmail:(NSString *)email password:(NSString *)pass completion:(void (^)(NSError *err))completion {
    // NOTE: Make sure parameters are valid.
    kAuthValidation validation = [self validateEmail:email passwordA:pass passwordB:pass];
    if (validation != kAuthValidationIsValid) {
        NSLog(@"ERROR: Parameters are invalid for user login. Check with -validateEmail:passwordA:passwordB method first.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-4 userInfo:nil]);
        }
        return;
    }
    // NOTE: Attempt user authentication.
    AWSCognitoIdentityUser *user = [self.awsUserPool getUser:email];
    if (user) {
        __block BOOL didRespond = NO;
        AWSCancellationTokenSource *cancellationTokenSource = [AWSCancellationTokenSource cancellationTokenSource];
        [[user getSession:email password:pass validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull t) {
            if (t.error) {
                NSLog(@"ERROR: Failed to authenticate the user.");
                didRespond = YES;
                if (completion) {
                    completion(t.error);
                }
            } else {
                NSLog(@"Successfully authenticated the user. Start authorization with MyFiziq service.");
                if (completion) {
                    completion(nil);
                }
            }
            return nil;
        } cancellationToken:cancellationTokenSource.token];
        // NOTE: Incase the service does not timeout in a timely manner, the authentication attempt should be cancelled
        // after a certain timeout period has elapsed.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX_AUTH_TIMEOUT_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!didRespond && completion) {
                NSLog(@"ERROR: Authentication of user timed out.");
                completion([NSError errorWithDomain:@"com.myfiziq" code:-3 userInfo:nil]);
            }
        });
    } else {
        // NOTE: This example uses the NSError parameter to flag that the authentication failed.
        NSLog(@"ERROR: User not found.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-2 userInfo:nil]);
        }
    }
}

/*
 REQUIRED: If using the MyFiziq provided AWS Cognito User Pool service for the idP, you must announce user registration
 intention using the MyFiziq user class -registerWithEmail:completion: method first. The user will be given a default
 password which is the AWS Cognito User Pool client id. The default password should be changed to the desired password
 immediately.
 NOTE: The need to announce user registration to MyFiziq first when using the provided service is because the AWS
 Cognito User Pool is used internally as the backing user directory service. Any user registration methods with this
 User Pool service that don't follow this procedure will cause issues for that user.
 NOTE: This is only applicable if using the MyFiziq provided AWS Cognito User Pool service. Otherwise you can manage
 the user registration independently from MyFiziq, but you still need to announce that a new user has registered with
 the MyFiziq user -registerWithEmail:completion: method.
 */
- (void)userRegistrationWithEmail:(NSString *)email password:(NSString *)pass completion:(void (^)(NSError *))completion {
    // NOTE: Make sure parameters are valid.
    kAuthValidation validation = [self validateEmail:email passwordA:pass passwordB:pass];
    if (validation != kAuthValidationIsValid) {
        NSLog(@"ERROR: Parameters are invalid for user registration. Check with -validateEmail:passwordA:passwordB method first.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-4 userInfo:nil]);
        }
        return;
    }
    // NOTE: Announce user registration intention to the MyFiziq service.
    __block BOOL didRespond = NO;
    AWSCancellationTokenSource *cancellationTokenSource = [AWSCancellationTokenSource cancellationTokenSource];
    // Register the user
    [self userRegisterEmail:email completionBlock:^(id obj, NSError *err) {
        if (err) {
        }
        NSDictionary *response = (NSDictionary *)obj;
        NSString *status = [response objectForKey:@"status"];
//        NSString *uid = [response objectForKey:@"uid"];
//        NSString *clashid = [response objectForKey:@"clashid"];
        if (!status) {
             NSLog(@"Failed new user registration intention for Boilerplate.");
            if (completion) {
                completion([NSError errorWithDomain:@"com.myfiziq.tk" code:-100 userInfo:nil]);
                return;
            }
        }
        NSLog(@"Successfully announced new user registration intention for Boilerplate.");
        // Set password
        [self userLoginWithEmail:email password:MFTK_AWS_CLIENT_ID completion:^(NSError *loginErr) {
            if (!loginErr) {
                // NOTE: With user logged in, we change the password to the desired password.
                [[self.currentUser changePassword:MFTK_AWS_CLIENT_ID proposedPassword:pass] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserChangePasswordResponse *> * _Nonnull t) {
                    if (!t.error) {
                        NSLog(@"Successfully registered new user and logged in.");
                    }
                    didRespond = YES;
                    if (completion) {
                        completion(t.error);
                    }
                    return nil;
                } cancellationToken:cancellationTokenSource.token];
            } else if (completion) {
                NSLog(@"ERROR: Failed to login as new registered user.");
                didRespond = YES;
                completion(loginErr);
            }
        }];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX_AUTH_TIMEOUT_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!didRespond && completion) {
            NSLog(@"ERROR: Authentication of user timed out.");
            completion([NSError errorWithDomain:@"com.myfiziq" code:-3 userInfo:nil]);
        }
    });
}

- (void)userRegisterEmail:(NSString *)email completionBlock:(void (^)(id obj, NSError *err))completionBlock {
    if (!self.lambda) {
        if (completionBlock) {
            completionBlock(nil, nil);
        }
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{ @"aid":MFTK_APP_ID }];
    if (email) {
        [parameters setObject:email forKey:@"email"];
    }
    [self innerRegister:parameters completionBlock:completionBlock];
}

- (void)innerRegister:(NSMutableDictionary *)params completionBlock:(void (^)(id obj, NSError *err))completionBlock {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
    NSString *pbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *lambdaName = [NSString stringWithFormat:@"arn:aws:lambda:%@:%@:function:%@-%@-userregister", MFTK_AWS_COGNITO_REGION, MFTK_AWS_ACC_ID, MFTK_VENDOR, MFTK_ENV];
    [[self.lambda invokeFunction:lambdaName JSONObject:@{ @"body":pbody }] continueWithSuccessBlock:^id _Nullable (AWSTask * _Nonnull t) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                if (t.error || !t.result || ![(NSNumber *) t.result[@"statusCode"] isEqualToNumber:@200] || [(NSString *) t.result[@"body"] isEqualToString:@""]) {
                    completionBlock(nil, [NSError errorWithDomain:@"com.myfiziq.tk" code:-200 userInfo:nil]);
                } else {
                    completionBlock([self parseResponse:t.result[@"body"]], nil);
                }
            }
        });
        return nil;
    }];
}

- (id)parseResponse:(id)response {
    if (!response || ![(NSObject *) response isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSData *data = [(NSString *) response dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if (!err) {
        return result;
    }
    return nil;
}

/*
 OPTIONAL: AWS Cognito User Pool service will handle the generation and send of the registered user's password reset code.
 */
- (void)userPasswordResetRequestWithEmail:(NSString *)email completion:(void (^)(NSError *))completion {
    // NOTE: Make sure parameters are valid.
    kAuthValidation validation = [self validateEmail:email passwordA:@"dummy_password" passwordB:@"dummy_password"];
    if (validation != kAuthValidationIsValid) {
        NSLog(@"ERROR: Parameters are invalid for user password reset. Check with -validateEmail:passwordA:passwordB method first.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-4 userInfo:nil]);
        }
        return;
    }
    // NOTE: Attempt user authentication.
    AWSCognitoIdentityUser *user = [self.awsUserPool getUser:email];
    if (user) {
        __block BOOL didRespond = NO;
        AWSCancellationTokenSource *cancellationTokenSource = [AWSCancellationTokenSource cancellationTokenSource];
        [[user forgotPassword] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserForgotPasswordResponse *> * _Nonnull t) {
            if (t.error) {
                NSLog(@"ERROR: Failed to send reset password code to the user.");
                if (completion) {
                    completion(t.error);
                }
            } else {
                NSLog(@"Successfully sent reset password code to the user.");
                if (completion) {
                    completion(nil);
                }
            }
            didRespond = YES;
            return nil;
        } cancellationToken:cancellationTokenSource.token];
        // NOTE: Incase the service does not timeout in a timely manner, the authentication attempt should be cancelled
        // after a certain timeout period has elapsed.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX_AUTH_TIMEOUT_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!didRespond && completion) {
                NSLog(@"ERROR: Submit of password reset code timed out.");
                completion([NSError errorWithDomain:@"com.myfiziq" code:-3 userInfo:nil]);
            }
        });
    } else {
        // NOTE: This example uses the NSError parameter to flag that the authentication failed.
        NSLog(@"ERROR: User not found.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-2 userInfo:nil]);
        }
    }
}

/*
 OPTIONAL: To reset the user password, the user must answer
 */
- (void)userPasswordResetConfirmWithEmail:(NSString *)email resetCode:(NSString *)code newPassword:(NSString *)pass completion:(void (^)(NSError *))completion {
    // NOTE: Make sure parameters are valid.
    kAuthValidation validation = [self validateEmail:email passwordA:pass passwordB:pass];
    if (validation != kAuthValidationIsValid || !code || [code isEqualToString:@""]) {
        NSLog(@"ERROR: Parameters are invalid for user password reset. Check with -validateEmail:passwordA:passwordB method first.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-4 userInfo:nil]);
        }
        return;
    }
    // NOTE: Attempt user password reset.
    AWSCognitoIdentityUser *user = [self.awsUserPool getUser:email];
    if (user) {
        __block BOOL didRespond = NO;
        AWSCancellationTokenSource *cancellationTokenSource = [AWSCancellationTokenSource cancellationTokenSource];
        [[user confirmForgotPassword:code password:pass] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmForgotPasswordResponse *> * _Nonnull t) {
            if (t.error) {
                NSLog(@"ERROR: Failed to reset user password.");
                didRespond = YES;
                if (completion) {
                    completion(t.error);
                }
            } else {
                NSLog(@"Successfully reset user password.");
                // NOTE: Login the new user using the new password.
                [self userLoginWithEmail:email password:pass completion:^(NSError *loginErr) {
                    didRespond = YES;
                    if (completion) {
                        completion(nil);
                    }
                }];
            }
            return nil;
        } cancellationToken:cancellationTokenSource.token];
        // NOTE: Incase the service does not timeout in a timely manner, the authentication attempt should be cancelled
        // after a certain timeout period has elapsed.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX_AUTH_TIMEOUT_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!didRespond && completion) {
                NSLog(@"ERROR: Password reset timed out.");
                completion([NSError errorWithDomain:@"com.myfiziq" code:-3 userInfo:nil]);
            }
        });
    } else {
        // NOTE: This example uses the NSError parameter to flag that the authentication failed.
        NSLog(@"ERROR: User not found.");
        if (completion) {
            completion([NSError errorWithDomain:@"com.myfiziq" code:-2 userInfo:nil]);
        }
    }
}

- (AWSTask *)userReauthenticate {
    if ([self userIsSignedIn]) {
        return [self.currentUser getSession];
    } else {
        // NOTE: Error to signify that there is no existing user session.
        return [AWSTask taskWithError:[NSError errorWithDomain:@"com.myfiziq" code:-1 userInfo:nil]];
    }
}

- (void)userLogoutWithCompletion:(void (^)(NSError *))completion {
    // NOTE: Check if there is a user to logout.
    if (self.userIsSignedIn) {
        // NOTE: Logout of idP should follow.
        [self.currentUser signOutAndClearLastKnownUser];
        if (completion) {
            completion(nil);
        }
    } else if (completion) {
        // NOTE: To signify that there were no user session to logout of.
        completion([NSError errorWithDomain:@"com.myfiziq" code:2 userInfo:nil]);
    }
}

- (void)userSetAWSCognitoLoginTokens:(AWSTaskCompletionSource<NSDictionary *> *)tokens {
    [[self.currentUser getSession] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull t) {
        if (t.error) {
            // NOTE: User session is likely to have expired, so complete with nil to indicate that a user needs to
            // re-authenticate to use the service.
            [tokens trySetResult:nil];
        } else {
            // NOTE: User session and tokens are valid, so complete per the AWSIdentityProviderManager protocol spec
            // using the MyFiziqSDK convenience properties (if using the MyFiziqSDK provided User Pool).
            [tokens trySetResult:@{self.awsUserPoolKey : t.result.idToken.tokenString}];
        }
        return nil;
    }];
}

#pragma mark - Delgate methods

- (AWSTask<NSDictionary *> *)logins {
    // NOTE: As there could possibly be multiple login options for the user, it is suggested that an async task monitors
    // all the idP services used.
    __block AWSTaskCompletionSource<NSDictionary *> *authTokens = [[AWSTaskCompletionSource<NSDictionary *> alloc] init];
    // NOTE: The following example shows how to access the MyFiziqSDK Cognito UserPool and the associated convenience
    // properties.
    if ([self userIsSignedIn]) {
        // NOTE: As the authenticated user access token might have expired (but the refresh token is still valid), you
        // should refresh tokens (this depends on the idP service being used).
        [self userSetAWSCognitoLoginTokens:authTokens];
    } else {
        [authTokens trySetResult:nil];
    }
    // NOTE: Return for a completion of any valid user authentication that completed.
    return [AWSTask taskForCompletionOfAnyTask:@[authTokens.task]];
}

#pragma mark - Turnkey methods

// TURNKEY EXAMPLE: To auto login/register backing MyFiziq user, this method saves repeating code for determining user claims
- (void)myfiziqTurnkeyAuth {
    // Check MyFiziq setup is complete.
    if ([MyFiziqSDKCoreLite shared].statusConnection != MFZSdkConnectionStatusReady) {
        NSLog(@"ERROR: MyFiziq SDK setup not complete prior to calling 'myfiziqTurnkeyAuth'. User will not be logged in.");
        return;
    }
    [self.currentUser.getDetails continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull t) {
        // APP Only for example: Get user attribute 'sub' to use as a user claim for security hardening. This could instead be, user joined date, etc...
        NSArray *claims = nil;
        if (!t.error && t.result && t.result.userAttributes) {
            for (AWSCognitoIdentityProviderAttributeType *claim in t.result.userAttributes) {
                if ([claim.name isEqualToString:@"sub"]) {
                    claims = @[claim.value];
                    break;
                }
            }
        }
        
        // TURNKEY EXAMPLE: Wherever the App completes user login, MyFiziq needs the backing user login to occur (effectively
        // grant user authorization). This uses the Login SDK helper that creates (or re-auth) the backing Coginto user
        // account, so you don't have to be concerned with managing user registration, password changes, or any other special
        // user management tasks.
        // As this example is using Cognito, we use the `getDetails` method to get user claims (attributes unique to the user,
        // but cannot be modified); however use what app-specific methods to retrieve user details. Using claims is optional
        // but it is highly reccommended to thwart attacks. However, to save repeating code, this example foregos using claims
        // with the recommended solution commented out for reference.
        
        // Call custom auth.
        [[MyFiziqTurnkey shared] userCustomAuthenticateForId:self.currentUser.username
                                                  withClaims:claims
                                                    withSalt:EXAMPLE_MFTK_SALT
                                                  completion:nil];
            
        return nil;
    }];
}

@end

