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

// A navigation icon resize helper.
@interface MYQTKNavigationBarConstants : NSObject
// The icon size for large state. This is the default size of the icon.
@property (readonly) CGFloat imageSizeForLargeState;
// The default right margin for the icon.
@property (readonly) CGFloat imageRightMargin;
// The default bottom margin for the large icon.
@property (readonly) CGFloat imageBottomMarginForLargeState;
// The default bottom margin for the smaller icon.
@property (readonly) CGFloat imageBottomMarginForSmallState;
// The image size for the smaller icon.
@property (readonly) CGFloat imageSizeForSmallState;
// The default nav bar height for small state.
@property (readonly) CGFloat navBarHeightSmallState;
// The default nav bar height for large state.
@property (readonly) CGFloat navBarHeightLargeState;
// Resize the icon when the scroll occurs.
// @param item The UIView item - can be a button, an image view, etc. - any view in the nav bar.
// @param height The height of the UINavigationBar.
- (void)resizeNavBarItem:(UIView *)item forNavBarHeight:(CGFloat)height;
@end
