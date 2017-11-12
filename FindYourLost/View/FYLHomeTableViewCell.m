//
//  FYLHomeTableViewCell.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/10.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLHomeTableViewCell.h"
#import "FYLHomeViewModel.h"

@interface FYLHomeTableViewCell()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIImageView *iconImageView;
@property (nonatomic , strong) UILabel *subtitleLabel;
@property (nonatomic , strong) UILabel *titlesLabel;
@property (nonatomic , strong) UILabel *addressLabel;
@property (nonatomic , strong) UIView *typeView;
@property (nonatomic , strong) UILabel *typeLabel;
@property (nonatomic , strong) UIImageView *statusImageView;

@end

@implementation FYLHomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView setNeedsUpdateConstraints];
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(2, 2, 2, 2));
    }];
    
    [self.bgView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(15);
        make.top.equalTo(self.bgView).offset(5);
        make.size.mas_equalTo(CGSizeMake(86, 86));
    }];
    
    [self.bgView addSubview:self.titlesLabel];
    [self.titlesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(15);
    }];
    
    [self.bgView addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.iconImageView);
        make.right.equalTo(self.bgView).offset(-15);
    }];

    [self.bgView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.subtitleLabel.mas_top).offset(-5);
        make.right.equalTo(self.bgView).offset(-15);
        make.left.equalTo(self.titlesLabel);
    }];
    
    [self.iconImageView addSubview:self.typeView];
    [self.typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.iconImageView);
    }];
    [self.typeView addSubview:self.typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.typeView).insets(UIEdgeInsetsMake(2, 5, 2, 5));
    }];
    
    [self.contentView addSubview:self.statusImageView];
    [self.statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.right.top.equalTo(self.contentView);
//        make.right.equalTo(self.bgView).offset(-80);
    }];
    self.statusImageView.hidden = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateWithModel:(id)obj {
    if ([obj isKindOfClass:[BmobObject class]]) {
        BmobObject *model = (BmobObject *)obj;
        
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[model objectForKey:@"photoUrl"]] placeholderImage:[UIImage imageNamed:@"defaultPic"]];
        self.titlesLabel.text = [model objectForKey:@"titleString"];
        self.subtitleLabel.text = [FYLCommon geDateStringWithOriginString:[model objectForKey:@"dateString"]];
        self.addressLabel.text = [model objectForKey:@"addressString"];
        NSString *type = [model objectForKey:@"type"];
        if ([type isEqualToString:@"1"]) {
            //lost
            self.typeView.backgroundColor = [UIColor colorWithRed:0.88f green:0.08f blue:0.08f alpha:0.50f];
            self.typeLabel.text = @"Lost";
        }else{
            self.typeView.backgroundColor = [UIColor colorWithRed:0.61f green:0.93f blue:0.38f alpha:0.50f];
            self.typeLabel.text = @"Found";
        }
        NSString *status = [obj objectForKey:@"status"];
        if ([status isEqualToString:@"1"]) {
            self.statusImageView.hidden = YES;
        }else{
            self.statusImageView.hidden = NO;
        }
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
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
    }
    return _iconImageView;
}

- (UILabel *)titlesLabel {
    if (!_titlesLabel) {
        _titlesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titlesLabel.font = [UIFont systemFontOfSize:14];
        _titlesLabel.textColor = UIColorFromRGB(0xFFFFFF);
        _titlesLabel.numberOfLines = 2;
        _titlesLabel.preferredMaxLayoutWidth = Screen_Width-2-2-15-86-15-15;
        [_titlesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_titlesLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titlesLabel;
}

- (UILabel *)subtitleLabel {
    
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:13];
        _subtitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
        [_subtitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_subtitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _subtitleLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.font = [UIFont systemFontOfSize:13];
        _addressLabel.textColor = UIColorFromRGB(0xFFFFFF);
//        _addressLabel.preferredMaxLayoutWidth = Screen_Width-2-2-15-86-15-15;
//        [_addressLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [_addressLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _addressLabel;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.font = [UIFont systemFontOfSize:10];
        _typeLabel.textColor = UIColorFromRGB(0xFFFFFF);
        [_typeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_typeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _typeLabel;
}

- (UIView *)typeView {
    if (!_typeView) {
        _typeView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _typeView;
}

- (UIImageView *)statusImageView {
    if (!_statusImageView) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _statusImageView.image = [UIImage imageNamed:@"finish"];
    }
    return _statusImageView;
}

@end
