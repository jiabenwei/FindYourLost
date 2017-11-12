//
//  FYLTabBarController.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYLTabBar.h"


@protocol FYLTabBarControllerDelegate;

@interface FYLTabBarController : UIViewController <FYLTabBarDelegate>

@property (nonatomic, weak) id<FYLTabBarControllerDelegate> delegate;

@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray *viewControllers;

@property (nonatomic, readonly) FYLTabBar *tabBar;

@property (nonatomic, weak) UIViewController *selectedViewController;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@protocol FYLTabBarControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(FYLTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;


- (void)tabBarController:(FYLTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;


- (void)tabBarController:(FYLTabBarController *)tabBarController  didSelectMiddleItem:(UIButton *)button;

@end

@interface UIViewController (RDVTabBarControllerItem)


@property(nonatomic, setter = rdv_setTabBarItem:) FYLTabBarItem *rdv_tabBarItem;


@property(nonatomic, readonly) FYLTabBarController *rdv_tabBarController;

@end
