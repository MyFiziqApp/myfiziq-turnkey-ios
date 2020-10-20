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

#import "MYQTKBaseViewController.h"
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>

@protocol MYQTKSubViewHomeDelegate <NSObject>
- (void)didDeleteAvatarWithAttemptID:(NSString *)attemptID;
@end

// The `MYQTKSubViewHome` view controller is used to display avatar result selected from My Scans
@interface MYQTKSubViewHome : MYQTKBaseViewController
@property (weak, nonatomic) id <MYQTKSubViewHomeDelegate> delegate;
- (void)setSelectedAvatar:(MyFiziqAvatar *)avatar;
@end
