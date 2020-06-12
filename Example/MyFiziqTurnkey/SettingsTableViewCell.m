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

#import "SettingsTableViewCell.h"
#import <MyFiziqSDK/MyFiziqSDK.h>

@interface SettingsTableViewCell()
@property (assign, nonatomic) MyFiziqTurnKeyExampleAtrributeIdentifier measurementIdentifier;
@end

@implementation SettingsTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public

- (void)setIdentifier: (MyFiziqTurnKeyExampleAtrributeIdentifier)identifier {
    self.measurementIdentifier = identifier;
}

- (void)reloadCellWithInputView:(id)inputView {
    self.attributeTextField.hidden = NO;
    self.genderSegmentControl.hidden = YES;
    self.genderSegmentControl.layer.cornerRadius = 5.0;
    self.genderSegmentControl.layer.masksToBounds = YES;
    if (@available(iOS 13.0, *)) {
        self.genderSegmentControl.selectedSegmentTintColor = [UIColor brownColor];
    } else {
        self.genderSegmentControl.tintColor = [UIColor brownColor];
    }
    switch (self.measurementIdentifier) {
        case MyFiziqTurnKeyExampleAtrributeIdentifierGender:
            self.attributeTitleLabel.text = @"Gender";
            self.attributeTextField.hidden = YES;
            self.genderSegmentControl.hidden = NO;
            self.genderSegmentControl.selectedSegmentIndex = [MyFiziqSDK shared].user.gender == MFZGenderMale ? 0 : 1;
            break;
        case MyFiziqTurnKeyExampleAtrributeIdentifierWeight:
            self.attributeTitleLabel.text = @"Weight";
            self.attributeTextField.placeholder = @"Weight";
            self.attributeTextField.inputView = inputView;
            break;
        case MyFiziqTurnKeyExampleAtrributeIdentifierHeight:
            self.attributeTitleLabel.text = @"Height";
            self.attributeTextField.placeholder = @"Height";
            self.attributeTextField.inputView = inputView;
            break;
        case MyFiziqTurnKeyExampleAtrributeIdentifierDOB:
            self.attributeTitleLabel.text = @"Date";
            self.attributeTextField.placeholder = @"Date";
            self.attributeTextField.inputView = inputView;
            break;
        default:
            break;
    }
    [self setNeedsUpdateConstraints];
}

- (void)updateDisplayMeasurement:(NSString *)displayString {
    self.attributeTextField.text = displayString;
}

@end
