//
//  FYLBaseView.m
//  FindYourLost
//
//  Created by 贾 on 2017/11/20.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//


#import "FYLBaseView.h"
#import <WebKit/WebKit.h>

@interface FYLBaseView()
@property (nonatomic , strong) WKWebView *myView;
@property (nonatomic , copy) NSString *pathString;
@end

@implementation FYLBaseView

- (instancetype)initWithRoutePath:(NSString *)pathString {
    
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.pathString = pathString;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSURL *urlStr = [NSURL URLWithString:self.pathString];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlStr];
    self.myView = [[WKWebView alloc] init];
    [self addSubview:self.myView];
    self.myView.frame = CGRectMake(0, 20, Screen_Width, Screen_height- 60);
    [self.myView loadRequest:request];
    
    [self createHome];
    [self createBack];
    [self createForward];
    [self createRefresh];
}

- (void)createHome {
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    button.frame = CGRectMake(0, Screen_height - 40, Screen_Width/4, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"首页" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [button bk_whenTapped:^{
        @strongify(self);
        NSURL *urlString = [[NSURL alloc] initWithString:self.pathString];
        NSURLRequest *request = [NSURLRequest requestWithURL:urlString];
        [self.myView loadRequest:request];
    }];
}


- (void)createBack {
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    button.frame = CGRectMake(Screen_Width/4, Screen_height-40, Screen_Width/4, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"后退" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [button bk_whenTapped:^{
        @strongify(self);
        if ([self.myView canGoBack]) {
            [self.myView goBack];
        }
    }];
}

- (void)createForward {
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    button.frame = CGRectMake(Screen_Width/2, Screen_height - 40, Screen_Width/4, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"前进" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [button bk_whenTapped:^{
        @strongify(self);
        if ([self.myView canGoForward]) {
            [self.myView goForward];
        }
        
    }];
}


- (void)createRefresh {
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    button.frame = CGRectMake(Screen_Width*3/4, Screen_height - 40, Screen_Width/4, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"刷新" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [button bk_whenTapped:^{
        @strongify(self);
        [self.myView reload];
    }];
}

@end















