//
//  FYLTabBarController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLTabBarController.h"
#import "FYLTabBarItem.h"
#import <objc/runtime.h>

@interface UIViewController (FYLTabBarControllerItemInternal)

- (void)rdv_setTabBarController:(FYLTabBarController *)tabBarController;

@end

@interface FYLTabBarController () {
    UIView *_contentView;
}

@property (nonatomic, readwrite) FYLTabBar *tabBar;

@end

@implementation FYLTabBarController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:[self contentView]];
    [self.view addSubview:[self tabBar]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setSelectedIndex:[self selectedIndex]];
    
    [self setTabBarHidden:self.isTabBarHidden animated:NO];
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//- (NSUInteger)supportedInterfaceOrientations {
//    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
//    for (UIViewController *viewController in [self viewControllers]) {
//        if (![viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
//            return UIInterfaceOrientationMaskPortrait;
//        }
//
//        UIInterfaceOrientationMask supportedOrientations = [viewController supportedInterfaceOrientations];
//
//        if (orientationMask > supportedOrientations) {
//            orientationMask = supportedOrientations;
//        }
//    }
//
//    return orientationMask;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    for (UIViewController *viewCotroller in [self viewControllers]) {
//        if (![viewCotroller respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] ||
//            ![viewCotroller shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
//            return NO;
//        }
//    }
//    return YES;
//}

#pragma mark - Methods

- (UIViewController *)selectedViewController {
    return [[self viewControllers] objectAtIndex:[self selectedIndex]];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
    }
    
    if ([self selectedViewController]) {
        [[self selectedViewController] willMoveToParentViewController:nil];
        [[[self selectedViewController] view] removeFromSuperview];
        [[self selectedViewController] removeFromParentViewController];
    }
    
    _selectedIndex = selectedIndex;
    [[self tabBar] setSelectedItem:[[self tabBar] items][selectedIndex]];
    
    [self setSelectedViewController:[[self viewControllers] objectAtIndex:selectedIndex]];
    [self addChildViewController:[self selectedViewController]];
    [[[self selectedViewController] view] setFrame:[[self contentView] bounds]];
    [[self contentView] addSubview:[[self selectedViewController] view]];
    [[self selectedViewController] didMoveToParentViewController:self];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        _viewControllers = [viewControllers copy];
        
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        
        for (UIViewController *viewController in viewControllers) {
            FYLTabBarItem *tabBarItem = [[FYLTabBarItem alloc] init];
            [tabBarItem setTitle:viewController.title];
            [tabBarItems addObject:tabBarItem];
            [viewController rdv_setTabBarController:self];
        }
        
        [[self tabBar] setItems:tabBarItems];
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [viewController rdv_setTabBarController:nil];
        }
        
        _viewControllers = nil;
    }
}

- (NSInteger)indexForViewController:(UIViewController *)viewController {
    UIViewController *searchedController = viewController;
    if ([searchedController navigationController]) {
        searchedController = [searchedController navigationController];
    }
    return [[self viewControllers] indexOfObject:searchedController];
}

- (FYLTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[FYLTabBar alloc] init];
        [_tabBar setBackgroundColor:[UIColor clearColor]];
        [_tabBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                      UIViewAutoresizingFlexibleTopMargin|
                                      UIViewAutoresizingFlexibleLeftMargin|
                                      UIViewAutoresizingFlexibleRightMargin|
                                      UIViewAutoresizingFlexibleBottomMargin)];
        [_tabBar setDelegate:self];
    }
    return _tabBar;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor clearColor]];
        [_contentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                           UIViewAutoresizingFlexibleHeight)];
    }
    return _contentView;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    _tabBarHidden = hidden;
    
    __weak FYLTabBarController *weakSelf = self;
    
    void (^block)() = ^{
        CGSize viewSize = weakSelf.view.bounds.size;
        CGFloat tabBarStartingY = viewSize.height;
        CGFloat contentViewHeight = viewSize.height;
        CGFloat tabBarHeight = CGRectGetHeight([[weakSelf tabBar] frame]);
        
        if (!tabBarHeight) {
            tabBarHeight = 60+kSafeBottomHeight;
        }
        
        if (!hidden) {
            tabBarStartingY = viewSize.height - tabBarHeight;
            if (![[weakSelf tabBar] isTranslucent]) {
                contentViewHeight -= ([[weakSelf tabBar] minimumContentHeight] ?: tabBarHeight);
            }
            [[weakSelf tabBar] setHidden:NO];
        }
        
        [[weakSelf tabBar] setFrame:CGRectMake(0, tabBarStartingY, viewSize.width, tabBarHeight)];
        [[weakSelf contentView] setFrame:CGRectMake(0, 0, viewSize.width, contentViewHeight)];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished){
        if (hidden) {
            [[weakSelf tabBar] setHidden:YES];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.24 animations:block completion:completion];
    } else {
        block();
        completion(YES);
    }
}

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

#pragma mark - RDVTabBarDelegate

- (BOOL)tabBar:(FYLTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index {
    if ([[self delegate] respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![[self delegate] tabBarController:self shouldSelectViewController:[self viewControllers][index]]) {
            return NO;
        }
    }
    
    if ([self selectedViewController] == [self viewControllers][index]) {
        if ([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *selectedController = (UINavigationController *)[self selectedViewController];
            
            if ([selectedController topViewController] != [selectedController viewControllers][0]) {
                [selectedController popToRootViewControllerAnimated:YES];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void)tabBar:(FYLTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= [[self viewControllers] count]) {
        return;
    }
    
    [self setSelectedIndex:index];
    
    if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        
        [[self delegate] tabBarController:self didSelectViewController:[self viewControllers][index]];
    }
}

- (void)tabBar:(FYLTabBar *)tabBar middleItemSelected:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectMiddleItem:)]) {
        [self.delegate tabBarController:self didSelectMiddleItem:sender];
    }
    
}

@end

#pragma mark - UIViewController+RDVTabBarControllerItem

@implementation UIViewController (FYLTabBarControllerItemInternal)

- (void)rdv_setTabBarController:(FYLTabBarController *)tabBarController {
    objc_setAssociatedObject(self, @selector(rdv_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIViewController (RDVTabBarControllerItem)

- (FYLTabBarController *)rdv_tabBarController {
    FYLTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(rdv_tabBarController));
    
    if (!tabBarController && self.parentViewController) {
        tabBarController = [self.parentViewController rdv_tabBarController];
    }
    
    return tabBarController;
}

- (FYLTabBar *)rdv_tabBarItem {
    FYLTabBarController *tabBarController = [self rdv_tabBarController];
    NSInteger index = [tabBarController indexForViewController:self];
    return [[[tabBarController tabBar] items] objectAtIndex:index];
}

- (void)rdv_setTabBarItem:(FYLTabBar *)tabBarItem {
    FYLTabBarController *tabBarController = [self rdv_tabBarController];
    
    if (!tabBarController) {
        return;
    }
    
    FYLTabBar *tabBar = [tabBarController tabBar];
    NSInteger index = [tabBarController indexForViewController:self];
    
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:[tabBar items]];
    [tabBarItems replaceObjectAtIndex:index withObject:tabBarItem];
    [tabBar setItems:tabBarItems];
}

@end
