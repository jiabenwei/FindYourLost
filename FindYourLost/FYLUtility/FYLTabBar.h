//
//  FYLTabBar.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYLTabBar, FYLTabBarItem;

@protocol FYLTabBarDelegate <NSObject>

/**
 * Asks the delegate if the specified tab bar item should be selected.
 */
- (BOOL)tabBar:(FYLTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index;

/**
 * Tells the delegate that the specified tab bar item is now selected.
 */
- (void)tabBar:(FYLTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

- (void)tabBar:(FYLTabBar *)tabBar middleItemSelected:(UIButton *)sender;

@end

@interface FYLTabBar : UIView

/**
 * The tab bar’s delegate object.
 */
@property (nonatomic, weak) id <FYLTabBarDelegate> delegate;

/**
 * The items displayed on the tab bar.
 */
@property (nonatomic, copy) NSArray *items;

/**
 * The currently selected item on the tab bar.
 */
@property (nonatomic, weak) FYLTabBarItem *selectedItem;

/**
 * backgroundView stays behind tabBar's items. If you want to add additional views,
 * add them as subviews of backgroundView.
 */
@property (nonatomic, readonly) UIView *backgroundView;

/*
 * contentEdgeInsets can be used to center the items in the middle of the tabBar.
 */
@property UIEdgeInsets contentEdgeInsets;

/**
 * Sets the height of tab bar.
 */
- (void)setHeight:(CGFloat)height;

/**
 * Returns the minimum height of tab bar's items.
 */
- (CGFloat)minimumContentHeight;

/*
 * Enable or disable tabBar translucency. Default is NO.
 */
@property (nonatomic, getter=isTranslucent) BOOL translucent;



@end
