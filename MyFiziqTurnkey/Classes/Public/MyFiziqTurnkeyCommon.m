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

#import "MyFiziqTurnkeyCommon.h"
#import <MyFaCSS/InterfaCSS.h>
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>
#import <MyFiziqSDKCommon/MyFiziqCommonBundle.h>
#import <MyFiziqSDKInputView/MyFiziqInputView.h>
#import <MyFiziqSDKLoginView/MyFiziqLoginCommon.h>
#import <MyFiziqSDKOnboardingView/MyFiziqOnboardingCommon.h>
#import <MyFiziqSDKProfileView/MyFiziqProfileCommon.h>
#import <MyFiziqSDKSupport/MyFiziqSupportSDKCommon.h>
#import <MyFiziqSDKTrackingView/MyFiziqTrackSDKCommon.h>

// Turnkey style layer is behind App default ordering, and above default SDK style ordering (for CSS cascading load ordering).
#define MYQTK_STYLE_Z_ORDER             50

@interface MyFiziqTurnkeyCommon()
@property (nonatomic, strong) NSBundle *internalBundle;
@end

@implementation MyFiziqTurnkeyCommon

#pragma mark - Properties

- (NSBundle *)internalBundle {
    if (!_internalBundle) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:self.classForCoder];
        NSURL *frameworkBundleUrl = [frameworkBundle URLForResource:@"MyFiziqTurnkeyResources" withExtension:@"bundle"];
        if (!frameworkBundleUrl) {
            return nil;
        }
        _internalBundle = [NSBundle bundleWithURL:frameworkBundleUrl];
    }
    return _internalBundle;
}

#pragma mark - Methods

+ (instancetype)shared {
    static MyFiziqTurnkeyCommon *mfzCommon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mfzCommon = [[MyFiziqTurnkeyCommon alloc] init];
        // Call all SDKs to make sure they are all loaded.
        [MyFiziqCommonBundle shared].common = mfzCommon;
        [MyFiziqSDKCommon shared].common = mfzCommon;
        [MyFiziqInputCommon shared].common = mfzCommon;
        [MyFiziqLoginCommon shared].common = mfzCommon;
        [MyFiziqOnboardingCommon shared].common = mfzCommon;
        [MyFiziqProfileCommon shared].common = mfzCommon;
        [MyFiziqSupportSDKCommon shared].common = mfzCommon;
        [MyFiziqTrackSDKCommon shared].common = mfzCommon;
        [[MyFiziqCommon shared] insert:mfzCommon withOrder:MYQTK_STYLE_Z_ORDER];
    });
    return mfzCommon;
}

- (void)setResourceBundle:(NSBundle *)bundle {
    if (!bundle) {
        return;
    }
    self.internalBundle = bundle;
}

- (NSBundle *)sdkBundle {
    return self.internalBundle;
}

- (NSString *)sdkCssName {
    return @"myfiziq-turnkey";
}

- (NSString *)sdkStringsTable {
    return @"myfiziq-turnkey";
}

- (NSInteger)zIndex {
    return 0;
}

// New Common

- (NSString *)stringsTable {
    return [self sdkStringsTable];
}

- (NSDictionary<NSNumber *,NSString *> *)css {
    return @{
        @(MFZStyleBaseZ + MFZStyleSDKStyleVariablesZ): @"myfiziq-turnkey-style-variables",
        @(MFZStyleBaseZ + MFZStyleSDKLayoutZ): @"myfiziq-turnkey-layouts",
        @(MFZStyleBaseZ + MFZStyleSDKClassesZ): @"myfiziq-turnkey-classes"
    };
}

- (NSBundle *)bundle {
    return [self sdkBundle];
}

@end
