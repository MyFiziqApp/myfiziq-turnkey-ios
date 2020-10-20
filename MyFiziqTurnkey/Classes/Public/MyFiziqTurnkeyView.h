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

#import <UIKit/UIKit.h>
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>

/** Represents a 'snapshot' view displaying latest measurement result in compact UI. Acts as the 'gateway' to the MyFiziq offering. */
@interface MyFiziqTurnkeyView : UIView
/** Call this method to refresh the card view. This will not sync with the MyFiziq service (call `MyFiziqTurnkey-refresh:` to do this),
 but rather, make sure the latest result is shown. Calling this method will stop and hide the activity view if user authorized and refresh was successful.
 */
- (void)refresh;
/** Call this method to show activity view, to block the user for interaction until some blocking task completes. Be sure to call `MyFiziqTurnkey-refresh:`
    or `MyFiziqTurnkeyView-refresh` to stop and hide the activity view.
 */
- (void)showLoading;
@end

