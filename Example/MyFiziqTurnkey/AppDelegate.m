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

#import "AppDelegate.h"
#import "IdentityProviderHelper.h"
// TURNKEY EXAMPLE: Import MyFiziq Turnkey to initialize the MyFiziq service on app start up.
@import MyFiziqTurnkey;

#define EXAMPLE_MFZ_KEY     @"REPLACE ME"
#define EXAMPLE_MFZ_SECRET  @"REPLACE ME"
#define EXAMPLE_MFZ_ENV     @"REPLACE ME"

@implementation AppDelegate

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // TURNKEY EXAMPLE: Initialize MyFiziq service ASAP, best when App Starts. This will also attempt to automatically
    // login prior user session.
    NSDictionary<NSString *, NSString *> *credentials = @{
        MFZSdkSetupKey:EXAMPLE_MFZ_KEY,
        MFZSdkSetupSecret:EXAMPLE_MFZ_SECRET,
        MFZSdkSetupEnvironment:EXAMPLE_MFZ_ENV
    };
    [[MyFiziqTurnkey shared] setupWithConfig:credentials success:^{
        if ([IdentityProviderHelper shared].userIsSignedIn) {
            // TURNKEY EXAMPLE: User logged in (authenticated), so authorize the user to the MyFiziq service.
            [[IdentityProviderHelper shared] myfiziqTurnkeyAuth];
        }
    } failure:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end

