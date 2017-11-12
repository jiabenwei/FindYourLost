//
//  FYLRootViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLRootViewController.h"

@interface FYLRootViewController ()

@end

@implementation FYLRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.view.backgroundColor = UIColorFromRGB(0xf8f8f8);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgImage"]];
    
    [self.view addSubview:self.cNavigationBar];
    [self.cNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(kTopHeight);
    }];
    self.cNavigationBar.hidden = YES;
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,63.5, Screen_Width, 0.5)];
//    lineView.backgroundColor = UIColorFromRGB(0xDDDDDD);
//    [self.cNavigationBar addSubview:lineView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)cNavigationBar {
    if (!_cNavigationBar) {
        _cNavigationBar = [[UIView alloc] initWithFrame:CGRectZero];
        _cNavigationBar.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
    }
    return _cNavigationBar;
}

- (UIView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _noDataView;
}

- (void)showNoDataView:(UIEdgeInsets)inset {
    [self.view addSubview:self.noDataView];
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(inset);
    }];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectZero];
    icon.image = [UIImage imageNamed:@"noData"];
    [self.noDataView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.equalTo(self.noDataView);
        make.top.equalTo(self.noDataView).offset(RatioPoint(100));
    }];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.textColor = UIColorFromRGB(0xFFFFFF);
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.text = @"No data";
    [self.noDataView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(icon.mas_bottom).offset(10);
        make.centerX.equalTo(icon);
    }];
}

- (void)dismissNoDataView {
    [self.noDataView removeFromSuperview];
    self.noDataView = nil;
}



@end
