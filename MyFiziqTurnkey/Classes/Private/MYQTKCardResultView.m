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

#import "MYQTKCardResultView.h"
#import <MyFiziqSDKProfileView/MyFiziqAvatar+MyFiziqProfile.h>
#import "MYQTKCardResultCellView.h"

#define MYQTK_DISPLAY_MEASUREMENTS      @[@"chestCM",@"waistCM",@"hipsCM",@"thighCM",@"weightKG"]

@interface MYQTKCardResultView() <UITableViewDataSource, UITableViewDelegate>
// - State
@property (strong, nonatomic) NSArray<NSString *> *displayMeasurements;
// - UIViews behind the curtain
@property (strong, nonatomic) MyFiziqCommonMeshView *viewMesh;
// - Sub UIViews
@property (strong, nonatomic) UIView *viewCurtain;
@property (strong, nonatomic) UILabel *viewResultTitle;
@property (strong, nonatomic) UILabel *viewResultDate;
@property (strong, nonatomic) UITableView *viewResultMeasurements;
@property (strong, nonatomic) UIImageView *viewResultAvatar;
@property (strong, nonatomic) id<MyFiziqCommonSpinnerDelegate> viewResultAvatarLoading;
@end

@implementation MYQTKCardResultView

#pragma mark - Properties

- (NSArray<NSString *> *)displayMeasurements {
    if (!_displayMeasurements) {
        _displayMeasurements = MYQTK_DISPLAY_MEASUREMENTS;
    }
    return _displayMeasurements;
}

- (MyFiziqCommonMeshView *)viewMesh {
    if (!_viewMesh) {
        _viewMesh = MFZMeshView(MyFiziqTurnkeyCommon, nil);
        _viewMesh.styleOverridePrefix = @"mfztkMeshView";
    }
    return _viewMesh;
}

- (UIView *)viewCurtain {
    if (!_viewCurtain) {
        _viewCurtain = [[UIView alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewCurtain, @"myq-tk-card-result-view");
    }
    return _viewCurtain;
}

- (UILabel *)viewResultTitle {
    if (!_viewResultTitle) {
        _viewResultTitle = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewResultTitle, @"myq-tk-card-result-title");
        _viewResultTitle.text = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_RESULT_TITLE", @"3D BODY SCAN");
    }
    return _viewResultTitle;
}

- (UILabel *)viewResultDate {
    if (!_viewResultDate) {
        _viewResultDate = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewResultDate, @"myq-tk-card-result-date");
    }
    return _viewResultDate;
}

- (UITableView *)viewResultMeasurements {
    if (!_viewResultMeasurements) {
        _viewResultMeasurements = [[UITableView alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewResultMeasurements, @"myq-tk-card-result-table");
        _viewResultMeasurements.dataSource = self;
        _viewResultMeasurements.delegate = self;
        _viewResultMeasurements.scrollEnabled = false;
        [_viewResultMeasurements setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_viewResultMeasurements registerClass:[MYQTKCardResultCellView class] forCellReuseIdentifier:[MYQTKCardResultCellView cellIdentifier]];
    }
    return _viewResultMeasurements;
}

- (UIImageView *)viewResultAvatar {
    if (!_viewResultAvatar) {
        _viewResultAvatar = [[UIImageView alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _viewResultAvatar, @"myq-tk-card-result-image-view");
    }
    return _viewResultAvatar;
}

#pragma mark - Init Methods

- (void)commonInit {
    [super commonInit];
    MFZStyleView(MyFiziqTurnkeyCommon, self, @"myq-tk-card-result-view");
    // Container: Has measurements
    [self addSubview:self.viewMesh];
    [self addSubview:self.viewCurtain];
    [self addSubview:self.viewResultTitle];
    [self addSubview:self.viewResultDate];
    [self addSubview:self.viewResultAvatar];
    [self addSubview:self.viewResultMeasurements];
}

- (void)doUpdateConstraints {
    [super doUpdateConstraints];
    // Mesh render behind the curtain
    [(SCNView *)self.viewMesh autoPinEdgesToSuperviewMarginsWithInsets:UIEdgeInsetsMake(10.0, 80.0, 10.0, 80.0)];
    // Curtain
    [self.viewCurtain autoPinEdgesToSuperviewMarginsWithInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    // Result: Title
    [self.viewResultTitle autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTitleHeight") doubleValue]];
    [self.viewResultTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTitleTopPadding") doubleValue]];
    [self.viewResultTitle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTitleLeftPadding") doubleValue]];
    [self.viewResultTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTitleRightPadding") doubleValue]];
    // Result: Date
    [self.viewResultDate autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultDateHeight") doubleValue]];
    [self.viewResultDate autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.viewResultTitle withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultDateTopPadding") doubleValue]];
    [self.viewResultDate autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultDateLeftPadding") doubleValue]];
    [self.viewResultDate autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultDateRightPadding") doubleValue]];
    // Result: Avatar
    [self.viewResultAvatar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultAvatarRightPadding") doubleValue]];
    [self.viewResultAvatar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.viewResultDate withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultAvatarTopPadding") doubleValue]];
    [self.viewResultAvatar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultAvatarBottomPadding") doubleValue]];
    [self.viewResultAvatar autoSetDimension:ALDimensionWidth toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultAvatarWidth") doubleValue]];
    // Result: Measurements
    double measurementCellHeight = [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTableCellHeight") doubleValue];
    [self.viewResultMeasurements autoSetDimension:ALDimensionHeight toSize:(measurementCellHeight * self.displayMeasurements.count)];
    [self.viewResultMeasurements autoSetDimension:ALDimensionWidth toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTableWidth") doubleValue]];
    [self.viewResultMeasurements autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.viewResultDate withOffset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTableTopPadding") doubleValue]];
    [self.viewResultMeasurements autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTableLeftPadding") doubleValue]];
    // Avatar will initially be loading
    self.viewResultAvatarLoading = MFZSpinner(MyFiziqTurnkeyCommon, self.viewResultAvatar);
    [self.viewResultAvatarLoading show];
}

#pragma mark - Update Methods

- (void)refresh {
    MyFiziqAvatar *avatar = [MyFiziqSDKCoreLite shared].avatars.all.firstObject;
    if (avatar && avatar.hasThumbnail && avatar.thumbnailImage) {
        UIImage *avatarImage = avatar.thumbnailImage;
        self.viewResultAvatar.image = avatarImage;
        [self.viewResultAvatarLoading hide];
    } else {
        // Render avatar in the background to get thumbnail image
        if (avatar && avatar != self.viewMesh.avatar) {
            [self.viewMesh setAvatar:avatar];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refresh];
            });
        } else if (avatar) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refresh];
            });
        }
        self.viewResultAvatar.image = nil;
        [self.viewResultAvatarLoading show];
    }
    [self updateLabelsWithLatest:avatar];
    [self setNeedsDisplay];
}

- (void)updateLabelsWithLatest:(MyFiziqAvatar *)avatar {
    if (!avatar) {
        return;
    }
    self.viewResultDate.text = [avatar formattedDate];
    [self.viewResultMeasurements reloadData];
}

#pragma mark - Measurements Table Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayMeasurements.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkCardResultTableCellHeight") floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MYQTKCardResultCellView *cell = (MYQTKCardResultCellView *)[tableView dequeueReusableCellWithIdentifier:[MYQTKCardResultCellView cellIdentifier]];
    if (cell == nil) {
        cell = [[MYQTKCardResultCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MYQTKCardResultCellView cellIdentifier]];
    }
    MyFiziqAvatar *latestAvatar = [MyFiziqSDKCoreLite shared].avatars.all.firstObject;
    if (!latestAvatar) {
        return cell;
    }
    NSString *key = [self.displayMeasurements objectAtIndex:indexPath.row];
    NSNumber *value = latestAvatar.measurements[self.displayMeasurements[indexPath.row]];
    MFZAvatarAttribute attrKey = [self convertAttributeKeyToEnum:key];
    cell.measurementLabel.text = [self convertEnumToString:attrKey];
    cell.measurementValue.text = [self getTextForValue:[value doubleValue] forAttribute:attrKey];
    [cell setNeedsUpdateConstraints];
    [cell setNeedsLayout];
    [cell setNeedsDisplay];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MFZStyleApply(MyFiziqTurnkeyCommon, cell);
}

#pragma mark - Helpers

- (MFZAvatarAttribute)convertAttributeKeyToEnum:(NSString *)key {
    if (!key) {
        return MFZAvatarAttributeUnknown;
    } else if ([key caseInsensitiveCompare:@"chestCM"] == NSOrderedSame) {
        return MFZAvatarAttributeChest;
    } else if ([key caseInsensitiveCompare:@"hipsCM"] == NSOrderedSame) {
        return MFZAvatarAttributeHips;
    } else if ([key caseInsensitiveCompare:@"thighCM"] == NSOrderedSame) {
        return MFZAvatarAttributeThigh;
    } else if ([key caseInsensitiveCompare:@"waistCM"] == NSOrderedSame) {
        return MFZAvatarAttributeWaist;
    } else if ([key caseInsensitiveCompare:@"weightKG"] == NSOrderedSame) {
        return MFZAvatarAttributeWeight;
    } else if ([key caseInsensitiveCompare:@"heightCM"] == NSOrderedSame) {
        return MFZAvatarAttributeHeight;
    }
    return MFZAvatarAttributeUnknown;
}

- (NSString *)getTextForValue:(double)value forAttribute:(MFZAvatarAttribute)attr {
    MFZMeasurement type = [MyFiziqSDKCoreLite shared].user.measurementPreference;
    if (attr == MFZAvatarAttributeWeight) {
        return [self massOutputForKg:value withType:type];
    }
    if (attr == MFZAvatarAttributeTotalBodyFat) {
        return [NSString stringWithFormat:@"%.1f%%", value];
    }
    return [self lengthOutputForCm:value forAttribute:attr withType:type];
}

- (NSString *)massOutputForKg:(double)kg withType:(MFZMeasurement)type {
    NSMeasurement<NSUnitMass *> *mass = [[NSMeasurement alloc] initWithDoubleValue:kg unit:NSUnitMass.kilograms];
    if (type == MFZMeasurementMetric) {
        NSString *tStr = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_KG", @"kg");
        double showKg = nearbyint(kg * 10.0) / 10.0;
        return [NSString stringWithFormat:@"%.1f %@", showKg, tStr];
    } else {
        return [NSString stringWithFormat:@"%.1f", [mass measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue];
    }
}

- (NSString *)lengthOutputForCm:(double)cm forAttribute:(MFZAvatarAttribute)attr withType:(MFZMeasurement)type {
    NSMeasurement<NSUnitLength *> *len = [[NSMeasurement alloc] initWithDoubleValue:cm unit:NSUnitLength.centimeters];
    if (type == MFZMeasurementMetric) {
        NSString *tStr = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_CM", @"cm");
        double showCm = nearbyint(cm * 10.0) / 10.0;
        return [NSString stringWithFormat:@"%.1f %@", showCm, tStr];
    } else {
        NSString *inStr = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_IN", @"\"");
        NSString *ftStr = MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_FT", @"'");
        if (attr == MFZAvatarAttributeHeight) {
            double valueFeetDbl = [self convertValue:cm measurement:MFZAvatarAttributeHeight forMeasurementType:type];
            NSInteger valueFeetInt = (NSInteger) valueFeetDbl;
            NSInteger valueInchesInt = (NSInteger) [self convertValue:cm measurement:MFZAvatarAttributeUnknown forMeasurementType:type];
            NSInteger valueInchesComponentInt = valueInchesInt - (valueFeetInt * 12);
            return [NSString stringWithFormat:@"%ld%@%ld%@", valueFeetInt, ftStr, valueInchesComponentInt, inStr];
        } else {
            double inches = [len measurementByConvertingToUnit:NSUnitLength.inches].doubleValue;
            return [NSString stringWithFormat:@"%.1f%@", inches, inStr];
        }
    }
}

- (double)convertValue:(double)value measurement:(MFZAvatarAttribute)measurementAttribute forMeasurementType:(MFZMeasurement)measurementPreference {
    // No conversion for metric
    if (measurementPreference == MFZMeasurementMetric || measurementAttribute == MFZAvatarAttributeTotalBodyFat) {
        return value;
    }
    // Convert to Imperial equal
    switch (measurementAttribute) {
        case MFZAvatarAttributeWeight: {
            NSMeasurement<NSUnitMass *> *weightKilograms = [[NSMeasurement alloc] initWithDoubleValue:value unit:NSUnitMass.kilograms];
            return [weightKilograms measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue;
        }
        case MFZAvatarAttributeHeight: {
            NSMeasurement<NSUnitLength *> *valueCentimeters = [[NSMeasurement alloc] initWithDoubleValue:value unit:NSUnitLength.centimeters];
            return [valueCentimeters measurementByConvertingToUnit:NSUnitLength.feet].doubleValue;
        }
        default: {
            NSMeasurement<NSUnitLength *> *valueCentimeters = [[NSMeasurement alloc] initWithDoubleValue:value unit:NSUnitLength.centimeters];
            return [valueCentimeters measurementByConvertingToUnit:NSUnitLength.inches].doubleValue;
        }
    }
}

- (NSString *)convertEnumToString:(MFZAvatarAttribute)key {
    switch (key) {
        case MFZAvatarAttributeChest: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_chest", @"Chest");
            break;
        }
        case MFZAvatarAttributeWaist: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_waist", @"Waist");
            break;
        }
        case MFZAvatarAttributeHips: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_hips", @"Hips");
            break;
        }
        case MFZAvatarAttributeThigh: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_thigh", @"Thighs");
            break;
        }
        case MFZAvatarAttributeWeight: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_weight", @"Weight");
            break;
        }
        case MFZAvatarAttributeHeight: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_height", @"Height");
            break;
        }
        case MFZAvatarAttributeTotalBodyFat: {
            return MFZString(MyFiziqTurnkeyCommon, @"MYQTK_CARD_ATTR_tbf", @"TBF");
        }
    }
    return @"";
}

@end
