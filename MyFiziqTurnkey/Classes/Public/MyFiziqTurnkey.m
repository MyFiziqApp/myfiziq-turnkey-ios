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
#import "MYQTKMyScans.h"
#import "MYQTKTrack.h"
#import "MYQTKNew.h"
#import "MYQTKTabBarController.h"

@interface MyFiziqTurnkey() <MyFiziqLoginDelegate>
@property (strong, nonatomic) void (^setupSuccess)(void);
@property (strong, nonatomic) void (^setupFailed)(NSError * err);
@property (strong, nonatomic) void (^authenticated)(BOOL isLoggedIn, NSError * err);
@property (strong, nonatomic) MYQTKTabBarController *tabBarController;
@end

@implementation MyFiziqTurnkey

#pragma mark - Properties

- (NSMutableSet *)turnkeyCardViews {
    if (!_turnkeyCardViews) {
        _turnkeyCardViews = [[NSMutableSet alloc] initWithCapacity:2];
    }
    return _turnkeyCardViews;
}

- (MYQTKTabBarController *)tabBarController {
    if (!_tabBarController) {
        _tabBarController = [[MYQTKTabBarController alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _tabBarController.tabBar, @"myqtk-tabbar-view");
    }
    return _tabBarController;
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

- (void)setResourceBundle:(NSBundle *)bundle {
    [[MyFiziqTurnkeyCommon shared] setResourceBundle:bundle];
}

- (void)setupWithConfig:(NSDictionary<NSString *, NSString *> *)conf success:(void (^)())success failure:(void (^)(NSError * _Nonnull err))failure reauthenticated:(void (^ _Nullable)(BOOL reauthenticated, NSError * _Nullable error))authenticated {
    // Call MyFiziq setup (via Login SDK helper).
    self.setupSuccess = success;
    self.setupFailed = failure;
    self.authenticated = authenticated;
    [MyFiziqLogin shared].myfiziqCredentials = conf;
    [MyFiziqLogin shared].loginDelegate = self;
    [[MyFiziqLogin shared] reloadMyFiziqSDK];
}

- (void)userCustomAuthenticateForId:(NSString *)partnerUserId withClaims:(NSArray<NSString *> *)claims withSalt:(NSString *)iv completion:(void (^)(NSError * _Nullable))completion {
    // Check that the MyFiziq service has been setup.
    if ([MyFiziqSDKCoreLite shared].statusConnection != MFZSdkConnectionStatusReady) {
        MFZLog(MFZLogLevelError, @"Called custom auth before MyFiziq setup called/completed successfully.");
        NSLog(@"MYQTK-ERR: Called custom auth before MyFiziq setup called/completed successfully.");
    }
    [[MyFiziqLogin shared] userCustomAuthenticateForId:partnerUserId withClaims:claims withSalt:iv completion:^(NSError * _Nullable err) {
        if (err) {
            MFZLog(MFZLogLevelError, @"Failed user authorization: %@", err);
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
        if (force || [MyFiziqSDKCoreLite shared].statusConnection != MFZSdkConnectionStatusReady) {
            for (MyFiziqTurnkeyView *card in self.turnkeyCardViews) {
                [card showLoading];
            }
        }
        // Check that the MyFiziq service has been setup.
        if ([MyFiziqSDKCoreLite shared].statusConnection != MFZSdkConnectionStatusReady) {
            MFZLog(MFZLogLevelError, @"Called refresh before MyFiziq setup called/completed successfully.");
            NSLog(@"MYQTK-ERR: Called refresh before MyFiziq setup called/completed successfully.");
            return;
        }
        // Sync with service if user is auth'd
        if ([MyFiziqSDKCoreLite shared].user.isLoggedIn) {
            [[MyFiziqSDKCoreLite shared].avatars requestAvatarsWithSuccess:^{
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

- (void)myfiziqUserLoggedIn:(BOOL)isLoggedIn withError:(NSError * _Nullable)error {
    if (self.authenticated) {
        self.authenticated(isLoggedIn, error);
    }
    if (!isLoggedIn) {
        return;
    }
    [self setTabControllers];
}

- (void)myfiziqSetupFailedWithError:(NSError *)error {
    MFZLog(MFZLogLevelError, @"Failed to initialize MyFiziq service");
    if (self.setupFailed) {
        self.setupFailed(error);
    }
    [self refresh:YES];
}

- (void)myfiziqSetupSuccessful {
    MFZLog(MFZLogLevelInfo, @"Successfully initialized MyFiziq service");
    if (self.setupSuccess) {
        self.setupSuccess();
    }
}

#pragma mark - User Intrinsics

- (void)setUserGender:(MFZGender)gender {
    if (![MyFiziqSDKCoreLite shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set gender value.");
        return;
    }
    [MyFiziqSDKCoreLite shared].user.gender = gender;
    // Need to ensure user info is updated while in active session.
    [self updateUserDetails];
}

- (void)setUserWeight:(float)weight forType:(MFZMeasurement)unit {
    if (![MyFiziqSDKCoreLite shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set weight value.");
        return;
    }
    if (unit == MFZMeasurementMetric) {
        [MyFiziqSDKCoreLite shared].user.weightInKg = weight;
        return;
    } else {
        // Need to convert lbs to kgs
        NSMeasurement<NSUnitMass *> *pounds = [[NSMeasurement alloc] initWithDoubleValue:weight unit:NSUnitMass.poundsMass];
        [MyFiziqSDKCoreLite shared].user.weightInKg = [pounds measurementByConvertingToUnit:NSUnitMass.kilograms].doubleValue;
    }
    // Need to ensure user info is updated while in active session.
    [self updateUserDetails];
}

- (void)setUserHeight:(float)height forType:(MFZMeasurement)unit {
    if (![MyFiziqSDKCoreLite shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set height value.");
        return;
    }
    if (unit == MFZMeasurementMetric) {
        [MyFiziqSDKCoreLite shared].user.heightInCm = height;
        return;
    } else {
        // Need to convert inches to cms
        NSMeasurement<NSUnitLength *> *inches = [[NSMeasurement alloc] initWithDoubleValue:height unit:NSUnitLength.inches];
        [MyFiziqSDKCoreLite shared].user.heightInCm = [inches measurementByConvertingToUnit:NSUnitLength.centimeters].doubleValue;
    }
    // Need to ensure user info is updated while in active session.
    [self updateUserDetails];
}

- (void)setUserUseMetric:(BOOL)metric {
    if (![MyFiziqSDKCoreLite shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot set prefered unit type.");
        return;
    }
    [MyFiziqSDKCoreLite shared].user.measurementPreference = metric ? MFZMeasurementMetric : MFZMeasurementImperial;
    // Need to ensure user info is updated while in active session.
    [self updateUserDetails];
}

- (void)updateUserDetails {
    [[MyFiziqSDKCoreLite shared].user updateDetailsWithCompletion:^(NSError * _Nullable err) {
        MFZMeasurement pref = [MyFiziqSDKCoreLite shared].user.measurementPreference;
        MFZLog(MFZLogLevelInfo, @"Updated user details.");
    }];
}

#pragma mark - Platform Card View Requirements

- (void)setTabControllers {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        int availableInterfaceStyle = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkSupportedUserInterfaceStyle") intValue];
        [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:@"MyFiziqDarkModeActive"];
        if ((availableInterfaceStyle == 0 && [[UIScreen mainScreen] traitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) || availableInterfaceStyle == 2) {
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"MyFiziqDarkModeActive"];
        }
        NSArray *viewControllersArray = @[[[MYQTKMyScans alloc] init], [[MYQTKNew alloc] init], [[MYQTKTrack alloc] init]];
        NSMutableArray *viewControllerNavigationArray = [[NSMutableArray alloc] init];
        NSArray *vcTabBarImageArray = @[
            MFZImage(MyFiziqTurnkeyCommon, @"icon-home"),
            MFZImage(MyFiziqTurnkeyCommon, @"icon-new"),
            MFZImage(MyFiziqTurnkeyCommon, @"icon-track")
        ];
        NSArray *titleArray = @[MFZString(MyFiziqTurnkeyCommon, @"MFZ_SDK_TAB_HOME", @""), MFZString(MyFiziqTurnkeyCommon, @"MFZ_SDK_TAB_NEW", @""), MFZString(MyFiziqTurnkeyCommon, @"MFZ_SDK_TAB_TRACK", @"")];
        for (int i = 0; i < [vcTabBarImageArray count]; i++) {
            UIViewController *viewController = [viewControllersArray objectAtIndex:i];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewControllersArray[i]];
            [viewControllerNavigationArray addObject:navigationController];
            viewController.tabBarItem.image = vcTabBarImageArray[i];
            viewController.tabBarItem.title = titleArray[i];
        }
        self.tabBarController.viewControllers = viewControllerNavigationArray;
    }];
}

- (void)showMyScans:(BOOL)showTabBar {
    [MYQTKBaseView actionShowAll:showTabBar];
}

- (void)showTrack:(BOOL)showTabBar {
    [MYQTKBaseView actionShowTrack:showTabBar];
}

- (void)showNew:(BOOL)showTabBar {
    [MYQTKBaseView actionShowNew:showTabBar];
}

- (NSDictionary<NSString *, NSNumber *> *)getLatestResultForType:(MFZMeasurement)type {
    if (![MyFiziqSDKCoreLite shared].user.isLoggedIn) {
        MFZLog(MFZLogLevelError, @"User not logged in, cannot return latest result.");
        return nil;
    }
    MyFiziqAvatar *latest = [MyFiziqSDKCoreLite shared].avatars.all.firstObject;
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
    if ([MyFiziqSDKCoreLite shared].statusConnection != MFZSdkConnectionStatusReady) {
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
