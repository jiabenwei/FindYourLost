//
//  FYLRootViewController.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^clickRetry)();

@interface FYLRootViewController : UIViewController

@property (nonatomic , strong) UIView *cNavigationBar;
@property (nonatomic , strong) UIView *noDataView;

- (void)showNoDataView:(UIEdgeInsets)inset;
- (void)showNetError:(UIEdgeInsets)inset clickHandle:(clickRetry)retry;
- (void)dismissNoDataView;
@end
