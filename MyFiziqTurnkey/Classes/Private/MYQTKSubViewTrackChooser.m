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

#import "MYQTKSubViewTrackChooser.h"

// NOTE: Create the layout using PureLayout, not storyboards

@interface MYQTKSubViewTrackChooser ()
@property (strong, nonatomic) UILabel *viewExample;
@property (strong, nonatomic) UIButton *buttonBack;
@end

@implementation MYQTKSubViewTrackChooser

#pragma mark - Properties

- (UILabel *)viewExample {
  if (!_viewExample) {
    _viewExample = [[UILabel alloc] init];
    MFZStyleView(MyFiziqTurnkeyCommon, _viewExample, @"myq-tk-track-sub-chooser-label");
  }
  return _viewExample;
}

- (UIButton *)buttonBack {
  if (!_buttonBack) {
    _buttonBack = [[UIButton alloc] init];
    MFZStyleView(MyFiziqTurnkeyCommon, _buttonBack, @"myq-tk-track-back-button");
    [_buttonBack addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _buttonBack;
}

#pragma mark - Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)commonInit {
  MFZStyleView(MyFiziqTurnkeyCommon, self.view, @"myq-tk-sub-track-chooser-view");
  [self.view addSubview:self.viewExample];
  [self.view addSubview:self.buttonBack];
}

- (void)commonSetContraints {
  [self.viewExample autoPinEdgesToSuperviewEdges];
  [self.buttonBack autoPinEdgeToSuperviewMargin:ALEdgeTop];
  [self.buttonBack autoPinEdgeToSuperviewMargin:ALEdgeLeft];
  [self.buttonBack autoPinEdgeToSuperviewMargin:ALEdgeRight];
  [self.buttonBack autoSetDimension:ALDimensionHeight toSize:[MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkTrackBackButtonHeight") floatValue]];
}

#pragma mark - Button Actions

- (IBAction)didTapBackButton:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
