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

#define EXAMPLE_MFZ_KEY     "eyJ1cmwiOiJodHRwczovL215cS1hcHAtZGV2LmF2YXRhci5teWZpemlxLmNvbSIsImFpZCI6IjA4NTM4Y2NiIiwidmlkIjoiNzI4MmNlZjIiLCJjaWQiOiIyMmNrMmQ3ZGM5NjFqMWw1YzFvcDEzZHM3ZyJ9"
#define EXAMPLE_MFZ_SECRET  "Ztwt+KjTJ4CiYDg5XaE16A=="
#define EXAMPLE_MFZ_ENV     "dev"

@implementation AppDelegate

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // TURNKEY EXAMPLE: Initialize MyFiziq service ASAP, best when App Starts. This will also attempt to automatically
    // login prior user session.
    NSDictionary<NSString *, NSString *> *credentials = @{
        MFZSdkSetupKey:@EXAMPLE_MFZ_KEY,
        MFZSdkSetupSecret:@EXAMPLE_MFZ_SECRET,
        MFZSdkSetupEnvironment:@EXAMPLE_MFZ_ENV
    };
    [[MyFiziqTurnkey shared] setupWithConfig:credentials success:^{
        NSLog(@"MyFiziq SDK setup completed successfully.");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"MyFiziq SDK setup failed with error: %@.", error);
    } reauthenticated:^(BOOL reauthenticated, NSError * _Nonnull error) {
        if (!reauthenticated) {
            // Present the login view.
            NSLog(@"User was not reauthenticated. Error may have occured: %@", error);
            return;
        }
        if (reauthenticated && [IdentityProviderHelper shared].userIsSignedIn) {
            // TURNKEY EXAMPLE: User logged in (authenticated), so authorize the user to the MyFiziq service.
            [[IdentityProviderHelper shared] myfiziqTurnkeyAuth];
        }
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end

