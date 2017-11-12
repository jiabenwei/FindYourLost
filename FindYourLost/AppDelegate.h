//
//  AppDelegate.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYLTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong)  FYLTabBarController*    tabBarController;

- (void)HiddenTabbar:(BOOL)hidden animation:(BOOL)animation;


@end

