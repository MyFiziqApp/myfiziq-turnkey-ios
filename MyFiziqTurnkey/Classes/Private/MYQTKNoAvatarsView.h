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

// The no avatars view delegate provides a method for receiving the button event from the view.
@protocol MYQTKNoAvatarsViewDelegate;

// The no avatars view provides a view for displaying a title label, description label and button.
// This view is a convenient view to use in the event that the user has no avatars.
// It is however not restricted to just this use.
@interface MYQTKNoAvatarsView : UIView
// A delegate for receiving the button action event.
@property (weak, nonatomic) id <MYQTKNoAvatarsViewDelegate> delegate;
// When creating a new instance, it is recommended that you provide a localised string for each the title and the detail label.
// @param titleText The view title.
// @param detailText A summarised description about the view or information you wish to convey to the user.
// @param show Choose whether or not the button should be visible. The default behaviour is that the button will be visible.
- (instancetype)initWithTitle:(NSString *_Nonnull)titleText detailText:(NSString *_Nonnull)detailText shouldShowButton:(BOOL)show;
// When creating a new instance, it is recommended that you provide a localised string for each the title and the detail label.
// @param titleText The view title.
// @param detailText A summarised description about the view or information you wish to convey to the user.
// @param buttonTitle The title of the button. The default title is `START`.
// @param show Choose whether or not the button should be visible. The default behaviour is that the button will be visible.
- (instancetype)initWithTitle:(NSString *_Nonnull)titleText detailText:(NSString *_Nonnull)detailText buttonText:(NSString *_Nonnull)buttonTitle shouldShowButton:(BOOL)show;
// Update the title label text
// @param titleText You can set the text to be nil.
- (void)setTitleLabelText:(NSString *_Nullable)titleText;
// Update the detail label text
// @param detailText You can set the text to be nil.
- (void)setDetailLabelText:(NSString *_Nullable)detailText;
@end

@protocol MYQTKNoAvatarsViewDelegate <NSObject>
@required
// When the user taps on the button in the No Avatars View, this delegate event will be fired.
// @param noAvatarsView The instance of the view that the button was called from.
- (void)didTapNoAvatarsViewButtonFromView:(MYQTKNoAvatarsView *_Nonnull)noAvatarsView;
@end
