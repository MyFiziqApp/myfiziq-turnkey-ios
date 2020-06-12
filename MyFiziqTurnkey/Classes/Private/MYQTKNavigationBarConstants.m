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

#import "MYQTKNavigationBarConstants.h"
#import "MyFiziqTurnkeyCommon.h"

@implementation MYQTKNavigationBarConstants

- (CGFloat)imageSizeForLargeState {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkNavBarImageSizeForLargeState") floatValue];
}

- (CGFloat)imageRightMargin {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkNavBarImageRightMargin") floatValue];
}

- (CGFloat)imageBottomMarginForLargeState {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkNavBarImageBottomMarginForLargeState") floatValue];
}

- (CGFloat)imageBottomMarginForSmallState {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkNavBarImageBottomMarginForSmallState") floatValue];
}

- (CGFloat)imageSizeForSmallState {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkNavBarImageSizeForSmallState") floatValue];
}

- (CGFloat)navBarHeightSmallState {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtkNavBarHeightSmallState") floatValue];
}

- (CGFloat)navBarHeightLargeState {
    return [MFZStyleVarNumber(MyFiziqTurnkeyCommon, @"myqtknavBarHeightLargeState") floatValue];
}

- (void)resizeNavBarItem:(UIView *)item forNavBarHeight:(CGFloat)height {
    CGFloat delta = height - self.navBarHeightSmallState;
    CGFloat heightDifferenceBetweenStates = self.navBarHeightLargeState - self.navBarHeightSmallState;
    CGFloat coeff = delta / heightDifferenceBetweenStates;
    CGFloat factor = self.imageSizeForSmallState / self.imageSizeForLargeState;
    CGFloat sizeAddendumFactor = coeff * (1.0 - factor);
    CGFloat scale = MIN(1.0, sizeAddendumFactor + factor);
    CGFloat sizeDiff = self.imageSizeForLargeState * (1.0 - factor);
    CGFloat maxYTranslation = (self.imageBottomMarginForLargeState - self.imageBottomMarginForSmallState) + sizeDiff;
    CGFloat yTranslation = MAX(0, MIN(maxYTranslation, (maxYTranslation - coeff * (self.imageBottomMarginForSmallState + sizeDiff))));
    CGFloat xTranslation = MAX(0, sizeDiff - coeff * sizeDiff);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(xTranslation, yTranslation);
    item.transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformConcat(scaleTransform, translateTransform));
}

@end
