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

#import "MyFiziqTurnkey.h"
#import <MyFiziqSDKBilling/MyFiziqBilling.h>
#import <MyFaCSS/InterfaCSS.h>
#import "MyFiziqTurnkeyCommon.h"
#import "MYQTKBaseView.h"

@interface MyFiziqTurnkey() <MyFiziqLoginDelegate>
@property (weak, nonatomic) void (^setupSuccess)(void);
@property (weak, nonatomic) void (^setupFailed)(NSError * err);
@end

@implementation MyFiziqTurnkey

#pragma mark - Properties

- (NSMutableSet *)turnkeyCardViews {
    if (!_turnkeyCardViews) {
        _turnkeyCardViews = [[NSMutableSet alloc] initWithCapacity:2];
    }
    return _turnkeyCardViews;
}

#pragma mark - Methods

+ (instancetype)shared {
    static MyFiziqTurnkey *mfz = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mfz = [[MyFiziqTurnkey alloc] init];
    });
    return mfz;
}

- (void)setCSSFile:(NSURL *)cssFilepath {
    [[MyFiziqTurnkeyCommon shared] setCSSFile:cssFilepath];
}

- (void)setupWithConfig:(NSDictionary<NSString *, NSString *> *)conf success:(void (^)())success failure:(void (^)(NSError * _Nonnull err))failure {
    // Call MyFiziq setup (via Login SDK helper).
    self.setupSuccess = success;
    self.setupFailed = failure;
    [MyFiziqLogin shared].myfiziqCredentials = conf;
    [MyFiziqLogin shared].loginDelegate = self;
    [[MyFiziqLogin shared] reloadMyFiziqSDK];
}

- (void)userCustomAuthenticateForId:(NSString *)partnerUserId withClaims:(NSArray<NSString *> *)claims withSalt:(NSString *)iv completion:(void (^)(NSError * _Nullable))completion {
    // Check that the MyFiziq service has been setup.
    if ([MyFiziqSDK shared].statusConnection != MFZSdkConnectionStatusReady) {
        MFZLog(MFZLogLevelError, @"Called custom auth before MyFiziq setup called/completed successfully.");
        NSLog(@"MYQTK-ERR: Called custom auth before MyFiziq setup called/completed successfully.");
    }
    [[MyFiziqLogin shared] userCustomAuthenticateForId:partnerUserId withClaims:claims withSalt:iv completion:^(NSError * _Nullable err) {
        if (err) {
            MFZLog(MFZLogLevelError, @"Failed user authorization");
            NSLog(@"MYQTK-ERR: Failed user authorization.");
        } else {
            MFZLog(MFZLogLevelInfo, @"Successfully authorized user");
            NSLog(@"MYQTK-NFO: Successfully authorized user.");
        }
        if (completion) {
            completion(err);
        }
        [self refresh:YES];
    }];
}

- (void)userUnauthenticateWithCompletion:(void (^)(NSError * _Nullable))completion {
    [[MyFiziqLogin shared] userLogoutWithCompletion:^(NSError * _Nullable err) {
        if (err) {
            MFZLog(MFZLogLevelError, @"Failed user un-authorization");
            NSLog(@"MYQTK-ERR: Failed user un-authorization.");
        } else {
            MFZLog(MFZLogLevelInfo, @"Successfully un-authorized user");
            NSLog(@"MYQTK-NFO: Successfully un-authorized user.");
        }
        if (completion) {
            completion(err);
        }
        [self refresh:YES];
    }];
}

- (void)refreshCardViews {
    for (MyFiziqTurnkeyView *card in self.turnkeyCardViews) {
        [card refresh];
    }
}

- (void)refresh:(BOOL)force {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Force implies that all card views show spinner until refresh has completed.
        // Also show spinner where user is not auth'd (or indirectly, service not setup yet).
        if (force || [MyFiziqSDK shared].statusConnection != MFZSdkConnectionStatusReady) {
            for (MyFiziqTurnkeyView *card in self.turnkeyCardViews) {
                [card showLoading];
            }
        }
        // Check that the MyFiziq service has been setup.
        if ([MyFiziqSDK shared].statusConnection != MFZSdkConnectionStatusReady) {
            MFZLog(MFZLogLevelError, @"Called refresh before MyFiziq setup called/completed successfully.");
            NSLog(@"MYQTK-ERR: Called refresh before MyFiziq setup called/completed successfully.");
            return;
        }
        // Sync with service if user is auth'd
        if ([MyFiziqSDK shared].user.isLoggedIn) {
            [[MyFiziqSDK shared].avatars requestAvatarsWithSuccess:^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    MFZLog(MFZLogLevelInfo, @"Called refresh with MYQ service sucessfully.");
                    [self refreshCardViews];
                }];
            } failure:^(NSError * _Nullable error) {
                MFZLog(MFZLogLevelError, @"Failed refresh with MYQ service for the user. Won't update cards.");
            }];
        }
    }];
}

#pragma mark - MyFiziqSDKLogin Delegate methods

- (void)myfiziqIsReadyAndUserLoggedIn:(BOOL)isLoggedIn {
    MFZLog(MFZLogLevelInfo, @"Successfully initialized MyFiziq service");
    if (self.setupSuccess) {
        self.setupSuccess();
    }
}

- (void)myfiziqSetupFailedWithError:(NSError *)error {
    MFZLog(MFZLogLevelError, @"Failed to initialize MyFiziq service");
    if (self.setupFailed) {
        self.setupFailed(error);
    }
    [self refresh:YES];
}

#pragma mark - User Intrinsics

- (void)setUserGender:(MFZGender)gender {
    if (![MyFiziqSDK shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set gender value.");
        return;
    }
    [MyFiziqSDK shared].user.gender = gender;
}

- (void)setUserWeight:(float)weight forType:(MFZMeasurement)unit {
    if (![MyFiziqSDK shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set weight value.");
        return;
    }
    if (unit == MFZMeasurementMetric) {
        [MyFiziqSDK shared].user.weightInKg = weight;
        return;
    }
    // Need to convert lbs to kgs
    NSMeasurement<NSUnitMass *> *pounds = [[NSMeasurement alloc] initWithDoubleValue:weight unit:NSUnitMass.poundsMass];
    [MyFiziqSDK shared].user.weightInKg = [pounds measurementByConvertingToUnit:NSUnitMass.kilograms].doubleValue;
}

- (void)setUserHeight:(float)height forType:(MFZMeasurement)unit {
    if (![MyFiziqSDK shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set height value.");
        return;
    }
    if (unit == MFZMeasurementMetric) {
        [MyFiziqSDK shared].user.heightInCm = height;
        return;
    }
    // Need to convert inches to cms
    NSMeasurement<NSUnitLength *> *inches = [[NSMeasurement alloc] initWithDoubleValue:height unit:NSUnitLength.inches];
    [MyFiziqSDK shared].user.heightInCm = [inches measurementByConvertingToUnit:NSUnitLength.centimeters].doubleValue;
}

- (void)setUserUseMetric:(BOOL)metric {
    if (![MyFiziqSDK shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set prefered unit type.");
        return;
    }
    [MyFiziqSDK shared].user.measurementPreference = metric ? MFZMeasurementMetric : MFZMeasurementImperial;
}

#pragma mark - Platform Card View Requirements

- (void)showMyScans {
    [MYQTKBaseView actionShowAll];
}

- (void)showTrack {
    [MYQTKBaseView actionShowTrack];
}

- (void)showNew {
    [MYQTKBaseView actionShowNew];
}

- (NSDictionary<NSString *, NSNumber *> *)getLatestResultForType:(MFZMeasurement)type {
    if (![MyFiziqSDK shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot return latest result.");
        return nil;
    }
    MyFiziqAvatar *latest = [MyFiziqSDK shared].avatars.all.firstObject;
    if (!latest || !latest.measurements) {
        MFZLog(MFZLogLevelInfo, @"User has no results yet, returning nil.");
        return nil;
    }
    NSMutableDictionary <NSString *, NSNumber *> *result = latest.measurements;
    NSMutableDictionary<NSString *, NSNumber *> *values = [[NSMutableDictionary<NSString *, NSNumber *> alloc] initWithCapacity:10];
    [values setValue:@(latest.gender == MFZGenderFemale ? 0.0 : 1.0) forKey:@"gender"];
    [values setValue:[self convertValue:result[@"heightCM"] forType:type isLengthType:YES] forKey:@"height"];
    [values setValue:[self convertValue:result[@"weightKG"] forType:type isLengthType:NO] forKey:@"weight"];
    [values setValue:[self convertValue:result[@"chestCM"] forType:type isLengthType:YES] forKey:@"chest"];
    [values setValue:[self convertValue:result[@"waistCM"] forType:type isLengthType:YES] forKey:@"waist"];
    [values setValue:[self convertValue:result[@"hipsCM"] forType:type isLengthType:YES] forKey:@"hips"];
    [values setValue:[self convertValue:result[@"thighCM"] forType:type isLengthType:YES] forKey:@"thigh"];
    [values setValue:@([latest.date timeIntervalSince1970]) forKey:@"date"];
    return values;
}

- (NSNumber *)convertValue:(NSNumber *)valueMetric forType:(MFZMeasurement)type isLengthType:(BOOL)length {
    if (!valueMetric) {
        return @(0.0);
    }
    if (type == MFZMeasurementMetric) {
        return valueMetric;
    }
    if (length) {
        NSMeasurement<NSUnitLength *> *cms = [[NSMeasurement alloc] initWithDoubleValue:[valueMetric doubleValue] unit:NSUnitLength.centimeters];
        return @([cms measurementByConvertingToUnit:NSUnitLength.inches].doubleValue);
    }
    NSMeasurement<NSUnitMass *> *kgs = [[NSMeasurement alloc] initWithDoubleValue:[valueMetric doubleValue] unit:NSUnitMass.kilograms];
    return @([kgs measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue);
}

- (void)sendBillingEventId:(NSUInteger)eventId miscData:(NSDictionary *)data {
    // Checks
    if ([MyFiziqSDK shared].statusConnection != MFZSdkConnectionStatusReady) {
        MFZLog(MFZLogLevelError, @"MyFiziq service not yet initialized, billing cannot be sent yet.");
        return;
    }
    if (eventId <= 110) {
        MFZLog(MFZLogLevelError, @"Billing Event ID passed is a reserved ID, event not sent");
        return;
    }
    if (data) {
        // Check data is JSONifyable
        @try {
            NSError *err;
            [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&err];
            if (err) {
                MFZLog(MFZLogLevelError, @"Billing misc data could not be serialized to JSON format, billing event not sent.");
                return;
            }
        } @catch (NSException *exception) {
            MFZLog(MFZLogLevelError, @"Billing misc data could not be serialized to JSON format, billing event not sent.");
            return;
        }
    }
    // Send the event
    [[MyFiziqBilling shared] logBillingEventId:eventId eventSource:MFZBillingSourceApp eventMisc:data];
}

@end
