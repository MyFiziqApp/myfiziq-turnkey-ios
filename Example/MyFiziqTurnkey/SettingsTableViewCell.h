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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MyFiziqTurnKeyExampleAtrributeIdentifier) {
    MyFiziqTurnKeyExampleAtrributeIdentifierGender,
    MyFiziqTurnKeyExampleAtrributeIdentifierWeight,
    MyFiziqTurnKeyExampleAtrributeIdentifierHeight,
    MyFiziqTurnKeyExampleAtrributeIdentifierDOB
};

@interface SettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *attributeTitleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentControl;
@property (weak, nonatomic) IBOutlet UITextField *attributeTextField;

- (void)setIdentifier: (MyFiziqTurnKeyExampleAtrributeIdentifier)identifier;
- (void)reloadCellWithInputView:(id)inputView;
- (void)updateDisplayMeasurement:(NSString *)displayString;

@end


