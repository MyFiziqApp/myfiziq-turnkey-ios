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

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import <MyFiziqSDKCoreLite/MyFiziqSDKCoreLite.h>
#import <MyFiziqSDKCommon/MyFiziqCommonMath.h>

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSMutableArray *titlesArray;
@property (strong, nonatomic) UIDatePicker *dobPicker;
@property (strong, nonatomic) UIPickerView *weightPicker, *heightPicker;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSArray<NSString *> *metricWeightKg;
@property (strong, nonatomic) NSArray<NSString *> *metricWeightHundredGrams;
@property (strong, nonatomic) NSArray<NSString *> *imperialWeightPounds;
@property (strong, nonatomic) NSArray<NSString *> *imperialWeightOunces;
@property (strong, nonatomic) NSArray<NSString *> *metricHeightCm;
@property (strong, nonatomic) NSArray<NSString *> *imperialHeightFeet;
@property (strong, nonatomic) NSArray<NSString *> *imperialHeightInches;
@property (assign, nonatomic) double weightInKg;
@property (assign, nonatomic) double heightInCm;
@property (assign, nonatomic) MFZMeasurement selectedWeightUnit;
@property (assign, nonatomic) MFZMeasurement selectedHeightUnit;
@end

@implementation SettingsViewController

#pragma mark - Properties

- (UIDatePicker *)dobPicker {
    if(!_dobPicker) {
        _dobPicker = [[UIDatePicker alloc] init];
        _dobPicker.datePickerMode = UIDatePickerModeDate;
        [_dobPicker addTarget:self action:@selector(didSelectDate:) forControlEvents:UIControlEventValueChanged];
    }
    return _dobPicker;
}

- (UIPickerView *)weightPicker {
    if (!_weightPicker) {
        _weightPicker = [[UIPickerView alloc] init];
        _weightPicker.dataSource = self;
        _weightPicker.delegate = self;
    }
    return _weightPicker;
}

- (UIPickerView *)heightPicker {
    if (!_heightPicker) {
        _heightPicker = [[UIPickerView alloc] init];
        _heightPicker.dataSource = self;
        _heightPicker.delegate = self;
    }
    return _heightPicker;
}

- (NSArray<NSString *> *)metricWeightKg {
    if (!_metricWeightKg) {
        int minWeight = 16.0;
        int maxWeight = 299.0;
        NSMutableArray *weightsKg = [[NSMutableArray alloc] initWithCapacity:(maxWeight - minWeight)];
        for (NSUInteger i = minWeight; i <= maxWeight; i++) {
            [weightsKg addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        _metricWeightKg = (NSArray *)weightsKg;
    }
    return _metricWeightKg;
}

- (NSArray<NSString *> *)metricWeightHundredGrams {
    if (!_metricWeightHundredGrams) {
        NSMutableArray *weightsGrams = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSUInteger i = 0; i <= 9; i++) {
            [weightsGrams addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        _metricWeightHundredGrams = (NSArray *)weightsGrams;
    }
    return _metricWeightHundredGrams;
}

- (NSArray<NSString *> *)imperialWeightPounds {
    if (!_imperialWeightPounds) {
        int minWeight = 36.0;
        int maxWeight = 659.0;
        NSMutableArray *weightsLb = [[NSMutableArray alloc] initWithCapacity:(maxWeight - minWeight)];
        for (NSUInteger i = minWeight; i <= maxWeight; i++) {
            [weightsLb addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        _imperialWeightPounds = (NSArray *)weightsLb;
    }
    return _imperialWeightPounds;
}

- (NSArray<NSString *> *)imperialWeightOunces {
    if (!_imperialWeightOunces) {
        NSMutableArray *weightsOunces = [[NSMutableArray alloc] initWithCapacity:16];
        for (NSUInteger i = 0; i <= 15; i++) {
            [weightsOunces addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        _imperialWeightOunces = (NSArray *)weightsOunces;
    }
    return _imperialWeightOunces;
}

// Contain centimeters between 50 and 255
- (NSArray<NSString *> *)metricHeightCm {
    if (!_metricHeightCm) {
        int heightMin = 50;
        int heightMax = 255;
        NSMutableArray *heightsCm = [[NSMutableArray alloc] initWithCapacity:(heightMax - heightMin)];
        for (NSUInteger i = heightMin; i <= heightMax; i++) {
            [heightsCm addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        _metricHeightCm = (NSArray *)heightsCm;
    }
    return _metricHeightCm;
}

// Contain feet between 1 and 8
- (NSArray<NSString *> *)imperialHeightFeet {
    if (!_imperialHeightFeet) {
        int heightMin = 1;
        int heightMax = 8;
        NSMutableArray *feet = [[NSMutableArray alloc] initWithCapacity:(heightMax - heightMin)];
        for (NSUInteger i = heightMin; i <= heightMax; i++) {
            [feet addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        _imperialHeightFeet = (NSArray *)feet;
    }
    return _imperialHeightFeet;
}

// Contain inches between 0 and 12
- (NSArray<NSString *> *)imperialHeightInches {
    if (!_imperialHeightInches) {
        NSMutableArray *inches = [[NSMutableArray alloc] initWithCapacity:26];
        for (double i = 0; i < 12.0; i += 0.5) {
            [inches addObject:[NSString stringWithFormat:@"%.1f", i]];
        }
        _imperialHeightInches = (NSArray *)inches;
    }
    return _imperialHeightInches;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weightInKg = [MyFiziqSDKCoreLite shared].user.weightInKg;
    self.heightInCm = [MyFiziqSDKCoreLite shared].user.heightInCm;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
}

#pragma mark - Private

- (double)weightInPounds {
    NSMeasurement<NSUnitMass *> *mass = [[NSMeasurement alloc] initWithDoubleValue:self.weightInKg unit:NSUnitMass.kilograms];
    return [mass measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue;
}

- (double)heightInFeet {
    NSMeasurement<NSUnitLength *> *len = [[NSMeasurement alloc] initWithDoubleValue:self.heightInCm unit:NSUnitLength.centimeters];
    return [len measurementByConvertingToUnit:NSUnitLength.feet].doubleValue;
}

- (NSError *)validateInput {
    SettingsTableViewCell *weightCell = (SettingsTableViewCell*)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    SettingsTableViewCell *heightCell = (SettingsTableViewCell*)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if ([heightCell.attributeTextField.text isEqualToString:@""]) {
        return [NSError errorWithDomain:@"com.myfiziq" code:-20 userInfo:nil];
    } else if ([weightCell.attributeTextField.text isEqualToString:@""]) {
        return [NSError errorWithDomain:@"com.myfiziq" code:-21 userInfo:nil];
    }
    // NOTE: Check entered parameters are within acceptable values.
    CGFloat heightCm = self.heightInCm;
    if (heightCm < MFZ_HEIGHT_CM_MIN || heightCm > MFZ_HEIGHT_CM_MAX) {
        [NSError errorWithDomain:@"com.myfiziq" code:-25 userInfo:nil];
    }
    CGFloat weightKg = self.weightInKg;
    if (weightKg < MFZ_WEIGHT_KG_MIN || weightKg > MFZ_WEIGHT_KG_MAX) {
        [NSError errorWithDomain:@"com.myfiziq" code:-26 userInfo:nil];
    }
    // NOTE: Calculate BMI.
    CGFloat heightM = heightCm / 100.0f; // CM to M
    if (heightM == 0.0f) {
        return [NSError errorWithDomain:@"com.myfiziq" code:-22 userInfo:nil];
    } else if (weightKg == 0.0f) {
        return [NSError errorWithDomain:@"com.myfiziq" code:-23 userInfo:nil];
    }
    CGFloat bmi = weightKg / (heightM * heightM);
    // NOTE: Check BMI is between 8 and 80.
    if (bmi < 8 || bmi > 80) {
        return [NSError errorWithDomain:@"com.myfiziq" code:-24 userInfo:nil];
    }
    // NOTE: No validation errors, so return nil.
    return nil;
}

- (NSString *)setPickerDateDefaultViewValues {
    // Min date based on value in CSS
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *minDate = [dateFormatter dateFromString:@"01/01/1900"];
    int youngestAge = 4;
    // Youngest date determined from CSS for younest age in years
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-youngestAge];
    NSDate *youngestDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    // Apple are confusing on this - Min Date = furtherest back, max date = most recent
    [self.dobPicker setMinimumDate:minDate];
    [self.dobPicker setMaximumDate:youngestDate];
    NSString *displayValue;
    NSDate *selectedDate;
    if ([MyFiziqSDKCoreLite shared].user.birthdate) {
        [self.dobPicker setDate:[MyFiziqSDKCoreLite.shared.user birthdate]];
        displayValue = [dateFormatter stringFromDate:[MyFiziqSDKCoreLite.shared.user birthdate]];
        selectedDate = [MyFiziqSDKCoreLite.shared.user birthdate];
    } else {
        int defaultAge = 25;
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:-defaultAge];
        NSDate *defaultAgeDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        [self.dobPicker setDate:defaultAgeDate];
        selectedDate = defaultAgeDate;
        displayValue = [dateFormatter stringFromDate:defaultAgeDate];
    }
    self.selectedDate = selectedDate;
    [self updateDateValueInField:displayValue];
    return displayValue;
}

- (NSString *)setPickerWeightDefaultViewValues {
    NSString *displayValue;
    int row;
    NSLog(@"measurementPreference %lu", (unsigned long)[MyFiziqSDKCoreLite shared].user.measurementPreference);
    self.selectedWeightUnit = [MyFiziqSDKCoreLite shared].user.measurementPreference;
    if ([MyFiziqSDKCoreLite shared].user.measurementPreference == MFZMeasurementMetric) {
        displayValue = [NSString stringWithFormat:@"%.1f kg", [MyFiziqSDKCoreLite shared].user.weightInKg];
        row = 0;
    } else {
        NSMeasurement<NSUnitMass *> *weightKilograms = [[NSMeasurement alloc] initWithDoubleValue:[MyFiziqSDKCoreLite shared].user.weightInKg unit:NSUnitMass.kilograms];
        displayValue = [NSString stringWithFormat:@"%.1f lbs", [weightKilograms measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue];
        row = 1;
    }
    [self.weightPicker selectRow:row inComponent:0 animated:YES];
    [self pickerView:self.weightPicker didSelectRow:row inComponent:0];
    return displayValue;
}

- (NSString *)setPickerHeightDefaultViewValues {
    NSString *displayValue;
    int row;
    self.selectedHeightUnit = [MyFiziqSDKCoreLite shared].user.measurementPreference;
    if ([MyFiziqSDKCoreLite shared].user.measurementPreference == MFZMeasurementMetric) {
        displayValue = [NSString stringWithFormat:@"%.0f cm", [MyFiziqSDKCoreLite shared].user.heightInCm];
        row = 0;
    } else {
        NSMeasurement<NSUnitMass *> *heightCm = [[NSMeasurement alloc] initWithDoubleValue:[MyFiziqSDKCoreLite shared].user.heightInCm unit:NSUnitLength.centimeters];
        NSInteger heightInFeet = (NSInteger)[heightCm measurementByConvertingToUnit:NSUnitLength.feet].doubleValue;
        NSInteger heightInInches = [heightCm measurementByConvertingToUnit:NSUnitLength.inches].doubleValue;
        float valueInchesComponentInt = heightInInches - (heightInFeet * 12);
        displayValue = [NSString stringWithFormat:@"%i' %.1f\"", (int)heightInFeet, valueInchesComponentInt];
        row = 1;
    }
    [self.heightPicker selectRow:row inComponent:0 animated:YES];
    [self pickerView:self.heightPicker didSelectRow:row inComponent:0];
    return displayValue;
}

// Method for scrolling to correct position on open of the text input.
- (void)setScrollForComponent:(NSInteger)component withIndexPositionForString:(NSString *)measurementString inArray:(NSArray<NSString *> *)measurements inPicker:(UIPickerView *)pickerView {
    NSUInteger indexOfArrayValue = [measurements indexOfObject:measurementString];
    if (indexOfArrayValue == NSNotFound) {
        indexOfArrayValue = 0;
    }
    [pickerView selectRow:(NSInteger)indexOfArrayValue inComponent:component animated:YES];
}

- (void)refreshWeightPickerValue {
    // Pre converted measurements
    double weightInKg = 16.0;
    NSString *displayValue;
    // Rows in component
    MFZMeasurement preferredUnit = [self.weightPicker selectedRowInComponent:0] == 1 ? MFZMeasurementImperial : MFZMeasurementMetric;
    NSInteger rowForComponent1 = [self.weightPicker selectedRowInComponent:1];
    NSInteger rowForComponent2 = [self.weightPicker selectedRowInComponent:2];
    // Weight is currently in kg
    if (preferredUnit == MFZMeasurementMetric) {
        weightInKg = [self.metricWeightKg[rowForComponent1] doubleValue];
        double grams = [self.metricWeightHundredGrams[rowForComponent2] doubleValue] / 10;
        weightInKg += grams;
        displayValue = [NSString stringWithFormat:@"%.1f kg", weightInKg];
    } else if (preferredUnit == MFZMeasurementImperial) {
        double ounces = [self.imperialWeightOunces[rowForComponent2] doubleValue];
        NSMeasurement<NSUnitMass *> *massOz = [[NSMeasurement alloc] initWithDoubleValue:ounces unit:NSUnitMass.ounces];
        double pounds = [self.imperialWeightPounds[rowForComponent1] doubleValue];
        pounds = pounds + [massOz measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue;
        NSMeasurement<NSUnitMass *> *mass = [[NSMeasurement alloc] initWithDoubleValue:pounds unit:NSUnitMass.poundsMass];
        weightInKg = [mass measurementByConvertingToUnit:NSUnitMass.kilograms].doubleValue;
        displayValue = [NSString stringWithFormat:@"%.1f lbs", pounds];
    }
    self.weightInKg = weightInKg;
    [self updateWeightValueInField:displayValue];
}

- (void)refreshHeightPickerValue {
    // Pre converted measurements
    double heightInCms = 0.0;
    double partInches = 0.0;
    NSString *displayValue;
    // Rows in component
    MFZMeasurement preferredUnit = [self.heightPicker selectedRowInComponent:0] == 1 ? MFZMeasurementImperial : MFZMeasurementMetric;
    NSInteger rowForComponent1 = [self.heightPicker selectedRowInComponent:1];
    NSInteger rowForComponent2 = 0;
    // Height is currently in cms
    if (preferredUnit == MFZMeasurementMetric) {
        heightInCms = [self.metricHeightCm[rowForComponent1] doubleValue];
        displayValue = [NSString stringWithFormat:@"%.0f cm", heightInCms];
    } else {
        int heightMin = 1;
        int heightMax = 8;
        rowForComponent2 = [self.heightPicker selectedRowInComponent:2];
        // If the feet option is 8 we need to ensure that the maximum inches is 4
        if ([self.heightPicker selectedRowInComponent:1] == (heightMax - heightMin) && rowForComponent2 > 8) {
            rowForComponent2 = 8;
        }
        partInches = [self.imperialHeightInches[rowForComponent2] doubleValue];
        double feet = [self.imperialHeightFeet[rowForComponent1] doubleValue];
        double inches = (feet * 12.0) + partInches;
        NSMeasurement<NSUnitLength *> *len = [[NSMeasurement alloc] initWithDoubleValue:inches unit:NSUnitLength.inches];
        heightInCms = [len measurementByConvertingToUnit:NSUnitLength.centimeters].doubleValue;
        displayValue = [NSString stringWithFormat:@"%.0f' %.1f\"", feet, partInches];
    }
    self.heightInCm = heightInCms;
    [self updateHeightValueInField:displayValue];
}

- (void)updateWeightValueInField:(NSString *)displayString {
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell updateDisplayMeasurement:displayString];
}

- (void)updateHeightValueInField:(NSString *)displayString {
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell updateDisplayMeasurement:displayString];
}

- (void)updateDateValueInField:(NSString *)displayString {
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [cell updateDisplayMeasurement:displayString];
}

- (void)didSelectDate:(UIDatePicker *)datePicker {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    self.selectedDate = datePicker.date;
    [self updateDateValueInField:[dateFormatter stringFromDate:datePicker.date]];
}

- (void)didTapView:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}

#pragma mark - IBActions

- (IBAction)backButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonTap:(id)sender {
    [self.view endEditing:YES];
    SettingsTableViewCell *weightCell = (SettingsTableViewCell*)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    SettingsTableViewCell *heightCell = (SettingsTableViewCell*)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    SettingsTableViewCell *genderCell = (SettingsTableViewCell*)[self.settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    __block UIAlertController *alert = [[UIAlertController alloc] init];
    alert.title = @"Invalid Entry";
    // NOTE: Validate input before attempting to start the avatar creation process.
    NSError *errValidation = [self validateInput];
    if (errValidation) {
        switch (errValidation.code) {
            case -20: {
                alert.message = @"Please enter your height.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    [weightCell.attributeTextField becomeFirstResponder];
                }];
                [alert addAction:okAction];
                break;
            }
            case -21: {
                alert.message = @"Please enter your weight.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    [heightCell.attributeTextField becomeFirstResponder];
                }];
                [alert addAction:okAction];
                break;
            }
            case -25:
            case -22: {
                alert.message = @"Height value not accepted. Please enter your height in CM between 50 and 255 CM.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    [heightCell.attributeTextField becomeFirstResponder];
                }];
                [alert addAction:okAction];
                break;
            }
            case -26:
            case -23: {
                alert.message = @"Weight value not accepted. Please enter your weight in KG between 16 and 300 KG.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    [weightCell.attributeTextField becomeFirstResponder];
                }];
                [alert addAction:okAction];
                break;
            }
            case -24: {
                alert.message = @"Weight and height ratio is not accepted. Please make sure you have entered into the correct field.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    [heightCell.attributeTextField becomeFirstResponder];
                }];
                [alert addAction:okAction];
                break;
            }
            default: {
                alert.message = @"Please check height and weight have been entered.";
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                [alert addAction:okAction];
                break;
            }
        }
        [self showViewController:alert sender:self];
    } else {
        // REQUIRED: Before initiating the avatar creation process, the user height and weight must first be updated.
        [MyFiziqSDKCoreLite shared].user.heightInCm = self.heightInCm;
        [MyFiziqSDKCoreLite shared].user.weightInKg = self.weightInKg;
        [MyFiziqSDKCoreLite shared].user.gender = genderCell.genderSegmentControl.selectedSegmentIndex == 0 ? MFZGenderMale : MFZGenderFemale;
        [MyFiziqSDKCoreLite shared].user.birthdate = self.selectedDate;
    }
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SettingsTableViewCell *settingsCell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    [settingsCell setIdentifier:(MyFiziqTurnKeyExampleAtrributeIdentifier)indexPath.row];
    if (indexPath.row == 0) {
        [settingsCell reloadCellWithInputView:nil];
    } else if (indexPath.row == 1) {
        [settingsCell reloadCellWithInputView:self.weightPicker];
        [settingsCell updateDisplayMeasurement:[self setPickerWeightDefaultViewValues]];
    } else if(indexPath.row == 2) {
        [settingsCell reloadCellWithInputView:self.heightPicker];
        [settingsCell updateDisplayMeasurement:[self setPickerHeightDefaultViewValues]];
    } else {
        [settingsCell reloadCellWithInputView:self.dobPicker];
        [settingsCell updateDisplayMeasurement:[self setPickerDateDefaultViewValues]];
    }
    settingsCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return settingsCell;
}

#pragma mark - UIPickerView Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.weightPicker) {
        return 3;
    } else {
        if (self.selectedHeightUnit == MFZMeasurementMetric) {
            return 2;
        }
        return 3;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.weightPicker) {
        if (component == 0) {
            return 2;
        } else if (component == 1 && self.selectedWeightUnit == MFZMeasurementMetric) {
            return self.metricWeightKg.count;
        } else if (component == 2 && self.selectedWeightUnit == MFZMeasurementMetric) {
            return self.metricWeightHundredGrams.count;
        } else if (component == 1 && self.selectedWeightUnit == MFZMeasurementImperial) {
            return self.imperialWeightPounds.count;
        } else if (component == 2 && self.selectedWeightUnit == MFZMeasurementImperial) {
            return self.imperialWeightOunces.count;
        }
    } else {
        if (component == 0) {
            return 2;
        } else if (component == 1 && self.selectedHeightUnit == MFZMeasurementMetric) {
            return self.metricHeightCm.count;
        } else if (component == 1 && self.selectedHeightUnit == MFZMeasurementImperial) {
            return self.imperialHeightFeet.count;
        } else if (component == 2 && self.selectedHeightUnit == MFZMeasurementImperial) {
            return self.imperialHeightInches.count;
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.weightPicker) {
        if (component == 0 && row == 0) {
            return @"kg";
        } else if (component == 0 && row == 1) {
            return @"lb";
        } else if (component == 1 && self.selectedWeightUnit == MFZMeasurementMetric) {
            return [NSString stringWithFormat:@"%@", self.metricWeightKg[row]];
        } else if (component == 2 && self.selectedWeightUnit == MFZMeasurementMetric) {
            return [NSString stringWithFormat:@".%@", self.metricWeightHundredGrams[row]];
        } else if (component == 1 && self.selectedWeightUnit == MFZMeasurementImperial) {
            return [NSString stringWithFormat:@"%@", self.imperialWeightPounds[row]];
        } else if (component == 2 && self.selectedWeightUnit == MFZMeasurementImperial) {
            return [NSString stringWithFormat:@".%@ oz", self.imperialWeightOunces[row]];
        }
    }
    if (component == 0 && row == 0) {
        return @"cm";
    } else if (component == 0 && row == 1) {
        return @"ft,in";
    } else if (component == 1 && self.selectedHeightUnit == MFZMeasurementMetric) {
        return [NSString stringWithFormat:@"%@", self.metricHeightCm[row]];
    } else if (component == 1 && self.selectedHeightUnit == MFZMeasurementImperial) {
        return [NSString stringWithFormat:@"%@'", self.imperialHeightFeet[row]];
    } else if (component == 2 && self.selectedHeightUnit == MFZMeasurementImperial) {
        return [NSString stringWithFormat:@"%@\"", self.imperialHeightInches[row]];
    }
    return @"";
}

#pragma mark - UIPickerView Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.weightPicker) {
        if (component == 0) {
            if (row == 0) {
                self.selectedWeightUnit = MFZMeasurementMetric;
                [pickerView reloadAllComponents];
                [self setScrollForComponent:1 withIndexPositionForString:[NSString stringWithFormat:@"%.0f", self.weightInKg] inArray:self.metricWeightKg inPicker:pickerView];
                [self setScrollForComponent:2 withIndexPositionForString:[NSString stringWithFormat:@"%0.1f", self.weightInKg] inArray:self.metricWeightHundredGrams inPicker:pickerView];
            } else  {
                self.selectedWeightUnit = MFZMeasurementImperial;
                [pickerView reloadAllComponents];
                double weightLB = [self weightInPounds];
                [self setScrollForComponent:1 withIndexPositionForString:[NSString stringWithFormat:@"%.0f", floor(weightLB)] inArray:self.imperialWeightPounds inPicker:pickerView];
                // Convert to component part
                NSDictionary<NSString *, NSNumber *> *weights = [MyFiziqCommonMath componentValue:self.weightInKg forType:MyFiziqCommonMeasurementTypeWeight forMeasurementType:MFZMeasurementImperial];
                // Create the oz key
                NSUInteger oz = 0;
                if (weights[@"ozInt"] != nil) {
                    oz = weights[@"ozInt"].unsignedIntegerValue;
                }
                NSString *ozKey = [NSString stringWithFormat:@"%ld", oz];
                [self setScrollForComponent:2 withIndexPositionForString:ozKey inArray:self.imperialWeightOunces inPicker:pickerView];
            }
        }
        if (row >= 0) {
            [self refreshWeightPickerValue];
        }
    } else {
        if (component == 0) {
            if (row == 0) {
                self.selectedHeightUnit = MFZMeasurementMetric;
                [pickerView reloadAllComponents];
                [self setScrollForComponent:1 withIndexPositionForString:[NSString stringWithFormat:@"%.0f", self.heightInCm] inArray:self.metricHeightCm inPicker:pickerView];
            } else {
                self.selectedHeightUnit = MFZMeasurementImperial;
                [pickerView reloadAllComponents];
                double heightFt = [self heightInFeet];
                [self setScrollForComponent:1 withIndexPositionForString:[NSString stringWithFormat:@"%.0f", floor(heightFt)] inArray:self.imperialHeightFeet inPicker:pickerView];
                // Round to nearest 0.5
                NSDictionary<NSString *, NSNumber *> *heights = [MyFiziqCommonMath componentValue:self.heightInCm forType:MyFiziqCommonMeasurementTypeHeight forMeasurementType:MFZMeasurementImperial];
                double conversionToInches = 0.0;
                if ([heights objectForKey:@"inchesDouble"] != nil) {
                    conversionToInches = [heights objectForKey:@"inchesDouble"].doubleValue;
                }
                float rounded = roundf(conversionToInches * 2.0f) / 2.0f;
                // Create the inch key
                NSString *inchKey = [NSString stringWithFormat:@"%.1f", rounded];
                // Scroll to value
                [self setScrollForComponent:2 withIndexPositionForString:inchKey inArray:self.imperialHeightInches inPicker:pickerView];
            }
        }
        if (row >= 0) {
            [self refreshHeightPickerValue];
        }
    }
}

@end
