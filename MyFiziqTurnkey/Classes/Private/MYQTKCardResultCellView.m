//
//  MYQTKCardResultCellView.m
//  MyFiziqTurnkey
//
//  Created by Phillip Cooper on 14/4/20.
//

#import "MYQTKCardResultCellView.h"
#import "MYQTKBaseView.h"

@interface MYQTKCardResultCellView()
// - State
@property (assign, nonatomic) BOOL didSetupConstraints;
@end

@implementation MYQTKCardResultCellView

#pragma mark - Properties

- (UILabel *)measurementLabel {
    if (!_measurementLabel) {
        _measurementLabel = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _measurementLabel, @"myq-tk-card-result-table-cell-label");
    }
    return _measurementLabel;;
}

- (UILabel *)measurementValue {
    if (!_measurementValue) {
        _measurementValue = [[UILabel alloc] init];
        MFZStyleView(MyFiziqTurnkeyCommon, _measurementValue, @"myq-tk-card-result-table-cell-value");
    }
    return _measurementValue;
}

#pragma mark - Init Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initForAutoLayout {
    self = [super initForAutoLayout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    MFZStyleView(MyFiziqTurnkeyCommon, self, @"myq-tk-card-result-table-cell");
    [self addSubview:self.measurementLabel];
    [self addSubview:self.measurementValue];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)updateConstraints {
    [super updateConstraints];
    // Stop memory leaking by only setting constraints once!
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        // Label
        [self.measurementLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.measurementLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        // Value
        [self.measurementValue autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.measurementValue autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        // Spread across the cell
        NSArray<UIView *> *components = @[self.measurementLabel, self.measurementValue];
        [components autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALEdgeBottom withFixedSpacing:0.0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    MFZStyleApply(MyFiziqTurnkeyCommon, self);
}

#pragma mark - Cell Methods

+ (NSString *)cellIdentifier {
    return @"MYQTKCardResultCellView";
}

@end
