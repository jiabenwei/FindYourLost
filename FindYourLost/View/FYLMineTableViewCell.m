//
//  FYLMineTableViewCell.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/9.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLMineTableViewCell.h"
#import "FYLMineModel.h"
#import "FYLMineViewModel.h"

@interface FYLMineTableViewCell()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIImageView *iconImageView;
@property (nonatomic , strong) UILabel *titlesLabel;
@property (nonatomic , strong) UIImageView *rightArrowImageView;

@end

@implementation FYLMineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setNeedsUpdateConstraints];
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupUI {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(2, RatioPoint(15), 2, RatioPoint(15)));
    }];
    
    [self.bgView addSubview:self.rightArrowImageView];
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(13, 13));
        make.centerY.equalTo(self.bgView);
        make.right.equalTo(self.bgView).offset(-15);
    }];
    
    [self.bgView addSubview:self.titlesLabel];
    [self.titlesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(15);
        make.centerY.equalTo(self.bgView);
    }];
}


- (void)updateWithModel:(id)model {
    if (model && [model isKindOfClass:[FYLMineModel class]]) {
        FYLMineModel *dataModel = (FYLMineModel *)model;
        self.titlesLabel.text = dataModel.titleString;
        
        [self.bgView bk_whenTapped:^{
            [self.viewModel.jumpCommand execute:self.indexPath];
        }];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1f];
//        _bgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _bgView.layer.borderWidth = 0.5;
        
    }
    return _bgView;
}

- (UIImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rightArrowImageView.image = [UIImage imageNamed:@"btn-arrow-right"];
    }
    return _rightArrowImageView;
}

- (UILabel *)titlesLabel {
    if (!_titlesLabel) {
        _titlesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titlesLabel.font = [UIFont systemFontOfSize:14];
        _titlesLabel.textColor = UIColorFromRGB(0xFFFFFF);
        [_titlesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_titlesLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titlesLabel;
}

@end
