//
//  FYLDetailViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLDetailViewController.h"

@interface FYLDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic , strong) BmobObject *dataModel;
@property (nonatomic , strong) UIButton *backBtn;
@property (nonatomic , strong) UIScrollView *mainScrollView;
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic , strong) UIImageView *iconImageView;
@property (nonatomic , strong) UIView *bottomBgView;
@property (nonatomic , strong) UIImageView *statusImageView;

@end

@implementation FYLDetailViewController

- (instancetype)initWithModel:(BmobObject *)model {
    if (self = [super init]) {
        self.dataModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cNavigationBar.hidden = NO;
    self.cNavigationBar.backgroundColor = [UIColor clearColor];
    [self.view setNeedsUpdateConstraints];
    [self.cNavigationBar addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.left.equalTo(self.cNavigationBar).offset(5);
        make.bottom.equalTo(self.cNavigationBar);
    }];
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 48, 0));
    }];
    
    [self.view addSubview:self.imageView];
    self.imageView.frame = CGRectMake(0, 0, Screen_Width, 200);
    self.mainScrollView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
    self.mainScrollView.scrollIndicatorInsets = self.mainScrollView.contentInset;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[self.dataModel objectForKey:@"photoUrl"]] placeholderImage:[UIImage imageNamed:@"defaultPic"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self adjustImageView:image];
    }];
    
    [self.view addSubview:self.iconImageView];
    self.iconImageView.frame = CGRectMake(15,CGRectGetMaxY(self.imageView.frame)-35, 70, 70);
    [self findUserIcon];
    
    
    [self.view bringSubviewToFront:self.cNavigationBar];
    
    [self.mainScrollView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mainScrollView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.width.mas_equalTo(Screen_Width);
    }];
    [self setupBgView];
    
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(48+kSafeBottomHeight);
    }];
    
    UIImageView *phoneImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.bottomBgView addSubview:phoneImageView];
    [phoneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48, 48));
        make.left.equalTo(self.bottomBgView).offset(15);
        make.top.equalTo(self.bottomBgView).offset(0);
    }];
    phoneImageView.image = [UIImage imageNamed:@"phone"];
    
    UILabel *tipLabel = [self titleLabel];
    [self.bottomBgView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomBgView).offset(-15);
        make.centerY.equalTo(phoneImageView);
    }];
    
    if ([[self.dataModel objectForKey:@"type"] isEqualToString:@"1"]) {
        //lost
        tipLabel.text = @"If you find it,please call me";
    }else{
        //found
        tipLabel.text = @"If it's yours,please call me";
    }
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.textColor = UIColorFromRGB(0x555555);
    
    @weakify(self);
    [self.bottomBgView bk_whenTapped:^{
        @strongify(self);
        NSMutableString* str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",[self.dataModel objectForKey:@"phoneNum"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    
    NSString *status = [self.dataModel objectForKey:@"status"];
    if ([status isEqualToString:@"2"]) {
        [self.view addSubview:self.statusImageView];
        [self.statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.right.equalTo(self.view).offset(-15);
            make.bottom.equalTo(self.view).offset(-50-kSafeBottomHeight);
        }];
    }
    
}


- (void)setupBgView {
    UIView *titleBg = [self itembgView];
    [self.bgView addSubview:titleBg];
    
    [titleBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(40);
        make.width.mas_equalTo(Screen_Width);
        make.centerX.equalTo(self.bgView);
    }];
    
    UILabel *titleLabel = [self titleLabel];
    [titleBg addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(titleBg).insets(UIEdgeInsetsMake(10, 15, 10, 15));
    }];
    titleLabel.text = [self.dataModel objectForKey:@"titleString"];
    
    UIView *addressBg = [self itembgView];
    [self.bgView addSubview:addressBg];
    [addressBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBg.mas_bottom).offset(10);
        make.width.equalTo(titleBg);
        make.centerX.equalTo(titleBg);
    }];
    
    UILabel *addressLabel = [self titleLabel];
    [addressBg addSubview:addressLabel];
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(addressBg).insets(UIEdgeInsetsMake(10, 15,10, 15));
    }];
    addressLabel.text = [self.dataModel objectForKey:@"addressString"];
    
    UIView *dateBg = [self itembgView];
    [self.bgView addSubview:dateBg];
    [dateBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressBg.mas_bottom).offset(10);
        make.width.equalTo(addressBg);
        make.centerX.equalTo(addressBg);
    }];
    
    UILabel *dateLabel = [self titleLabel];
    [dateBg addSubview:dateLabel];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(dateBg).insets(UIEdgeInsetsMake(10, 15,10, 15));
    }];
    dateLabel.text = [self.dataModel objectForKey:@"dateString"];
    
    NSString *des = [self.dataModel objectForKey:@"desString"];
    if (des && des.length) {
        UIView *desBg = [self itembgView];
        [self.bgView addSubview:desBg];
        [desBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(dateBg.mas_bottom).offset(10);
            make.width.equalTo(dateBg);
            make.centerX.equalTo(dateBg);
            make.bottom.equalTo(self.bgView).offset(-50);
        }];
        
        UILabel *desLabel = [self titleLabel];
        [desBg addSubview:desLabel];
        [desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(desBg).insets(UIEdgeInsetsMake(10, 15,10, 15));
        }];
        desLabel.text = des;
        
    }else{
        [dateBg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(addressBg.mas_bottom).offset(10);
            make.width.equalTo(addressBg);
            make.centerX.equalTo(addressBg);
            make.bottom.equalTo(self.bgView).offset(-50);
        }];
    }
}

- (void)findUserIcon {
    BmobQuery   *bquery = [BmobQuery queryWithClassName:TABLEUSER];
    @weakify(self);
    [bquery getObjectInBackgroundWithId:[self.dataModel objectForKey:@"userId"] block:^(BmobObject *object,NSError *error){
        @strongify(self);
        if (error){
        }else{
            if (object) {
                NSString *photoUrl = [object objectForKey:@"imageUrl"];
                [self setUserIcWithImageUrl:photoUrl];
            }
        }
    }];
}

- (void)setUserIcWithImageUrl:(NSString *)imageUrl {
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
}

- (void)adjustImageView:(UIImage *)image {
    CGSize size = [self imageSizeAfterAdapt:image];
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.size = size;
    imageViewFrame.origin.x = (Screen_Width-size.width)/2;
    self.imageView.frame = imageViewFrame;
    
    self.iconImageView.frame = CGRectMake(15,CGRectGetMaxY(self.imageView.frame)-35, 70, 70);
    
    self.mainScrollView.contentInset = UIEdgeInsetsMake(size.height, 0, 0, 0);
    self.mainScrollView.scrollIndicatorInsets = self.mainScrollView.contentInset;
}

- (CGSize)imageSizeAfterAdapt:(UIImage *)image {
    if (image) {
        CGFloat maxWidth = Screen_Width;
        return image.size.width > maxWidth ? CGSizeMake(maxWidth, image.size.height*maxWidth/image.size.width) : image.size;
    }
    return CGSizeZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        @weakify(self);
        [_backBtn bk_whenTapped:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _backBtn;
}

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _mainScrollView.delegate = self;
    }
    return _mainScrollView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bgView;
}


- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
    }
    return _bottomBgView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _imageView.layer.borderWidth = 0.5;
    }
    return _imageView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _imageView.layer.borderWidth = 0.5;
        _iconImageView.layer.cornerRadius = 35;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.backgroundColor = UIColorFromRGB(0xdddddd);

    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    titleLabel.numberOfLines = 0;
    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    return titleLabel;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float destinaOffset = -35-20;
    float startChangeOffset = -self.imageView.frame.size.height;
    CGPoint contentOffSet = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y<startChangeOffset?startChangeOffset:(scrollView.contentOffset.y>destinaOffset?destinaOffset:scrollView.contentOffset.y));
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y = -self.imageView.frame.size.height- contentOffSet.y;
    self.imageView.frame = imageFrame;
    
    self.iconImageView.frame = CGRectMake(15,CGRectGetMaxY(self.imageView.frame)-35, 70, 70);

}


- (UIView *)itembgView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1f];
    //    bgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
    //    bgView.layer.borderWidth = 0.5;
    return bgView;
}

- (UILabel *)subtitleLabel {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.userInteractionEnabled = YES;
    //    titleLabel.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
    //    titleLabel.layer.borderWidth = 0.5;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    //    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    return titleLabel;
}

- (UIImageView *)statusImageView {
    if (!_statusImageView) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _statusImageView.image = [UIImage imageNamed:@"finishIcon"];
    }
    return _statusImageView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

@end
