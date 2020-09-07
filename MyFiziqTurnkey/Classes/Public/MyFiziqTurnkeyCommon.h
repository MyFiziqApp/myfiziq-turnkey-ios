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

#import <MyFiziqSDKCommon/MyFiziqCommon.h>
#import <MyFiziqSDKCommon/MyFiziqCommonButton.h>

/** Turnkey common implementation, for handling styles and resources. */
@interface MyFiziqTurnkeyCommon : MyFiziqCommon <MyFiziqCommonProtocol>
/** Singleton interface.
    @return Singleton instance value of the class object.
 */
+ (instancetype _Nullable)shared;
/** Set the resource bundle for cutom styling. App will need all SDK style overrides in a single file.
    @param bundle Instance of the resource bundle containing style overrides (CSS, images, etc...).
 */
- (void)setResourceBundle:(NSBundle *)bundle;
@end
