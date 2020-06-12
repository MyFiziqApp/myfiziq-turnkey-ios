//
//  MYQTKCardResultCellView.h
//  MyFiziqTurnkey
//
//  Created by Phillip Cooper on 14/4/20.
//

#import <UIKit/UIKit.h>

@interface MYQTKCardResultCellView : UITableViewCell
@property (strong, nonatomic) UILabel *measurementLabel;
@property (strong, nonatomic) UILabel *measurementValue;
+ (NSString *)cellIdentifier;
@end
