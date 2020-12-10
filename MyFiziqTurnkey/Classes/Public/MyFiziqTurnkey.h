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

#import <Foundation/Foundation.h>
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>
#import <MyFiziqSDKLoginView/MyFiziqLogin.h>
#import "MyFiziqTurnkeyCommon.h"
#import "MyFiziqTurnkeyView.h"

/** Protocol acting as datasource for the sdk to respond to scans access . */
@protocol MyFiziqTurnkeyDatasourceDelegate<NSObject>
@required
/** Boolean signifying if scans are allowed to view or not.
    @return Boolean signifying if scans are allowed to view or not.
 */
- (BOOL)newScansAllowed;
@end

/** Handles 'boilerplate' MyFiziq initialization tasks for turnkey solution. */
@interface MyFiziqTurnkey : NSObject
/** Optional setting of JSON compliant additonal data to be appended to the next scan. Useful for cross-reference tracking of the result if needed. */
@property (strong, nonatomic) NSDictionary * _Nullable miscData;
/** This property will list all MyFiziq Turnkey Card Views. Usually there will be just one card view for the app.
    The card view will automatically register itself to this set, so app code to do this will not be needed. The use of this set
    is to allow automatic refresh of user measurement state.
 */
@property (strong, nonatomic) NSMutableSet * _Nonnull turnkeyCardViews;
/** Reference to the `MyFiziqTurnkeyDatasourceDelegate` datasource. */
@property (weak, nonatomic) id<MyFiziqTurnkeyDatasourceDelegate> _Nullable datasource;
/** Tab bar controller for turn key view.
 */
@property (readonly, nonatomic) UITabBarController * _Nullable tabBarController;
/** Singleton interface.
    @return Singleton instance value of the class object.
 */
+ (instancetype _Nullable)shared;
/** Set the resource bundle for cutom styling. App will need all SDK style overrides in a single file.
    @param bundle Instance of the resource bundle containing style overrides (CSS, images, etc...).
 */
- (void)setResourceBundle:(NSBundle * _Nonnull)bundle;
/** Configure `MyFiziq` with the associated App key (recieved from registering App with MyFiziq). This will automatically
    handle user re-authentication so no further setup code is needed.
    @param conf The connection configuration, should contain `MFZSdkSetupKey` ("Key"), `MFZSdkSetupSecret` ("Secret"),
    and `MFZSdkSetupEnvironment` ("Env"), as recieved during App registration with MyFiziq service team.
    @param success The callback code block that will be invoked asynchronously if and when the `MyFiziq` service is setup
    successfully.
    @param failure The callback code block that will be invoked asynchronously if and when the `MyFiziq` service setup has
    @param authenticated The callback that returns whether the user session was successfully authenticated or whether it failed with an error. An error does not always mean failure to reauthenticate so be aware of this.
 */
- (void)setupWithConfig:(NSDictionary * _Nonnull)conf
                success:(void (^ _Nullable)())success
                failure:(void (^ _Nullable)(NSError * _Nonnull error))failure
        reauthenticated:(void (^ _Nullable)(BOOL reauthenticated, NSError * _Nullable error))authenticated;
/** Custom user authentication is for integration to environments that don't provide an AWS Cognito compatible idP such
    as Open ID Connect, SAML, or OAuth. This basically authorises a user using a set of user claims, by either logging
    in the user (if already exists), or registering the user first and then logging the user in. A user logout call will be
    done first if the current user logged in doesn't match the intended user, so that the intended user will be logged in 
    when this method completes, regardless of current state. Effectively, this method is re-enterant and can be called
    multiple times without issue, provided that the parameters are correct and this method is called after successful setup.
    @note This is NOT a reccommended solution, but provides an alternative where an integration has some non-standards
    based user auth implementation.
    @param partnerUserId The partner user id (not the same as MyFiziq user id).
    @param claims An array of claims unique to the user and will not change (e.g. registration date). Likewise, the order
    must not change. Therefore, don't include the email, as the user could change this.
    @param iv The initiation vector (or salt) for signing the user. In the hex format "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee".
    @param completion Block that is called once the user has been authorized with the MyFiziq service.
 */
- (void)userCustomAuthenticateForId:(NSString * _Nonnull)partnerUserId
                         withClaims:(NSArray<NSString *> * _Nullable)claims
                           withSalt:(NSString * _Nonnull)iv
                         completion:(void (^ _Nullable)(NSError * _Nullable))completion;
/** When user logout/unauthenticate occurs, this method should be called to un-authorize the user from the MyFiziq service.
    It is not completely neccessary, but saves logout processing when user auth is subsequently called.
    @param completion Block that is called once the user has been un-authorized from the MyFiziq service.
 */
- (void)userUnauthenticateWithCompletion:(void (^ _Nullable)(NSError * _Nullable))completion;
/** Call this to refresh MyFiziq, which will sync with server to retrieve all latest results for the user.
    @param force If true, all card views will show a spinner until refresh has completed.
 */
- (void)refresh:(BOOL)force;
/** App can set the user gender prior to initiating a new scan. If not set, MyFiziq will use the last used value the
    user entered.
    @param gender The user's physical sex/gender (male/female).
 */
- (void)setUserGender:(MFZGender)gender;
/** App can set the user weight prior to initiating a new scan. If not set, MyFiziq will use the last used value the
    user entered.
    @param weight The user's latest weight value.
    @param unit The measurement scale used (metric = kilograms, imperial = pounds/lbs).
 */
- (void)setUserWeight:(float)weight forType:(MFZMeasurement)unit;
/** App can set the user height prior to initiating a new scan. If not set, MyFiziq will use the last used value the
    user entered.
    @param height The user's latest height value.
    @param unit The measurement scale used (metric = centimeters, imperial = inches).
 */
- (void)setUserHeight:(float)height forType:(MFZMeasurement)unit;
/** App can set the whether the prefered measurement unit is metric (if true), or imperial (if false) prior to initiating
    a new scan. If not set, MyFiziq will use the last used value the user entered.
    @param metric If true, the unit preference will be in metric, other imperial will be used.
 */
- (void)setUserUseMetric:(BOOL)metric;
// The following are all to ease creation of platform specific card view.
/** Show the My Scans screen, for use by platform cardview implementation.
    @param showTabBar show or hide tab bar.
 */
- (void)showMyScans:(BOOL)showTabBar;
/** Show the Track screen, for use by platform cardview implementation.
    @param showTabBar show or hide tab bar.
 */
- (void)showTrack:(BOOL)showTabBar;
/** Show the New Scan screen, for use by platform cardview implementation.
    @param showTabBar show or hide tab bar.
 */
- (void)showNew:(BOOL)showTabBar;
/** Return a simple key-value dictionary/map of result measurements, converted into measurement type, for use by
    platform cardview implementation.
    @param type The measurement unit preference (i.e. metric or imperial).
    @return Dictionary of measurements values as type double, converted to unit type as specified in the `type` parameter.
    Keys:
    - 'gender' : female = 0.0, male = 1.0
    - 'height' : metric = cms, imperial = inches
    - 'weight' : metric = cms, imperial = inches
    - 'chest' : metric = cms, imperial = inches
    - 'waist' : metric = cms, imperial = inches
    - 'hips' : metric = cms, imperial = inches
    - 'thigh' : metric = cms, imperial = inches
    - 'date' : unix epoch time (seconds since 1/1/1970 UTC)
 */
- (NSDictionary<NSString *, NSNumber *> * _Nullable)getLatestResultForType:(MFZMeasurement)type;
/** Send billing event to the MyFiziq service. This will largely depending on what is contractually agreed and only for
    specific custom scenarios.
    @param eventId A positive integer value to indicate the event identifier (contact MyFiziq to get value).
    @param data Optional JSON compliant data to attach to the billing event. Only for tracking purposes and limited in size allowance.
 */
- (void)sendBillingEventId:(NSUInteger)eventId miscData:(NSDictionary * _Nullable)data;
@end
