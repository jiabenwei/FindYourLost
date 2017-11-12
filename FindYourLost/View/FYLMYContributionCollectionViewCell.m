//
//  FYLMYContributionCollectionViewCell.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLMYContributionCollectionViewCell.h"

@interface FYLMYContributionCollectionViewCell()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIImageView *iconImageView;
@property (nonatomic , strong) UILabel *subtitleLabel;
@property (nonatomic , strong) UILabel *titlesLabel;
@property (nonatomic , strong) UILabel *addressLabel;
@property (nonatomic , strong) UIImageView *finishIcon;


@end

@implementation FYLMYContributionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView setNeedsUpdateConstraints];
        [self setupUI];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.bgView];
    UIEdgeInsets insets = UIEdgeInsetsZero;
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(insets);
    }];
    
    [self.bgView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.bgView);
        make.height.equalTo(self.iconImageView.mas_width);
    }];
    
    [self.bgView addSubview:self.titlesLabel];
    [self.titlesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
        make.left.equalTo(self.bgView).offset(10);
        make.right.equalTo(self.bgView).offset(-10);
    }];
    
    [self.bgView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titlesLabel.mas_bottom).offset(10);
        make.left.equalTo(self.bgView).offset(10);
        make.right.equalTo(self.bgView).offset(-10);
    }];
    
    [self.bgView addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addressLabel.mas_bottom).offset(10);
        make.left.equalTo(self.bgView).offset(10);
    }];
    
    [self.bgView addSubview:self.finishIcon];
    [self.finishIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.bottom.right.equalTo(self.bgView);
    }];
    self.finishIcon.hidden = YES;
}

- (void)updataViewWithObject:(BmobObject *)obj {
    if (obj) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (self.indexPath.item % 2 == 0) {
            insets = UIEdgeInsetsMake(5, 10, 5, 5);
        }else{
            insets = UIEdgeInsetsMake(5, 5, 5, 10);
        }
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(insets);
        }];

         [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[obj objectForKey:@"photoUrl"]] placeholderImage:[UIImage imageNamed:@"defaultPic"]];
        
        self.titlesLabel.text = [obj objectForKey:@"titleString"];
        self.subtitleLabel.text = [FYLCommon geDateStringWithOriginString:[obj objectForKey:@"dateString"]];
        self.addressLabel.text = [obj objectForKey:@"addressString"];
        
        NSString *status = [obj objectForKey:@"status"];
        if ([status isEqualToString:@"1"]) {
            self.finishIcon.hidden = YES;
        }else{
            self.finishIcon.hidden = NO;
        }
        
        @weakify(self);
        [self.bgView bk_whenTapped:^{
            @strongify(self);
            [self.viewModel.jumpCommand execute:self.indexPath];
        }];
    }
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1f];
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
//        _titlesLabel.preferredMaxLayoutWidth = Screen_Width-2-2-15-86-15-15;
//        [_titlesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [_titlesLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titlesLabel;
}

- (UILabel *)subtitleLabel {
    
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:13];
        _subtitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
//        [_subtitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [_subtitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
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

- (UIImageView *)finishIcon {
    if (!_finishIcon) {
        _finishIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _finishIcon.image = [UIImage imageNamed:@"finishBottom"];
    }
    return _finishIcon;
}

@end
