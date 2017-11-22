//
//  AppDelegate.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "AppDelegate.h"
#import "FYLTabBarController.h"
#import "FYLTabBarItem.h"
#import "FYLTabBar.h"
#import "FYLHomeViewController.h"
#import "FYLMineViewController.h"
#import "FYLCommon.h"
#import "FYLLoginViewController.h"
#import "FYLAddViewController.h"

@interface AppDelegate ()<FYLTabBarControllerDelegate>

@property (nonatomic , strong) FYLHomeViewController   * homeViewController;
@property (nonatomic , strong) FYLMineViewController   * mineViewController;
@property (nonatomic , strong) UINavigationController  * navigationController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Bmob registerWithAppKey:BMOBKEY];
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:ISURL];
    if (!urlString || urlString.length == 0) {
        BmobQuery   *bquery = [BmobQuery queryWithClassName:TABLELOAD];
        [bquery getObjectInBackgroundWithId:@"sf2Cbbbm" block:^(BmobObject *object, NSError *error) {
            if (object) {
                NSString *path = [object objectForKey:@"pathString"];
                if (path && path.length) {
                    [[NSUserDefaults standardUserDefaults] setObject:path forKey:ISURL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }
        }];
    }
    
    [self doLauchHomepage];
    return YES;
}


-(void)doLauchHomepage{
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [self setupViewControllers];
    self.window.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.86f green:0.86f blue:0.87f alpha:1.00f];
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
    
}


- (void)setupViewControllers {
    
    self.homeViewController = [[FYLHomeViewController alloc] init];
    self.mineViewController = [[FYLMineViewController alloc] init];
    
    self.tabBarController = [[FYLTabBarController alloc] init];
    self.tabBarController.delegate = self;
    [self.tabBarController.view setBackgroundColor:[UIColor clearColor]];
    self.homeViewController.title = @"home";
    self.mineViewController.title = @"mine";
    
    [self.tabBarController setViewControllers:@[self.homeViewController,self.mineViewController]];
    [self customizeTabBarForController:self.tabBarController];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController setSelectedIndex:0];
}


- (void)customizeTabBarForController:(FYLTabBarController *)tabBarController {
    UIImage *finishedImage;
    UIImage *unfinishedImage;
    finishedImage = [FYLCommon createImageWithColor:[UIColor clearColor]];
    unfinishedImage = [FYLCommon createImageWithColor:[UIColor clearColor]] ;
    NSInteger index = 0;
    for (FYLTabBarItem *item in [[tabBarController tabBar] items]) {
        item.unselectedTitleAttributes = @{
                                           NSFontAttributeName: [UIFont systemFontOfSize:10.f],
                                           NSForegroundColorAttributeName: UIColorFromRGB(0x8a8a8a),
                                           };
        item.selectedTitleAttributes = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:10.f],
                                         NSForegroundColorAttributeName: UIColorFromRGB(0xFFFFFF),
                                         };
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        
        NSString *selectedimageStr;
        NSString *unselectedimageStr;
        if (index == 0) {
            selectedimageStr = @"home-on.png";
            unselectedimageStr = @"home-off.png";
        }else if(index == 1){
            selectedimageStr = @"mine-on.png";
            unselectedimageStr = @"mine-off.png";
        }
        [item setFinishedSelectedImage:[UIImage imageNamed:selectedimageStr] withFinishedUnselectedImage:[UIImage imageNamed:unselectedimageStr]];
        index++;
    }
}

- (void)HiddenTabbar:(BOOL)hidden animation:(BOOL)animation{
    [self.tabBarController setTabBarHidden:hidden animated:animation];
}

#pragma  SATabBarControllerDelegate

- (BOOL)tabBarController:(FYLTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isEqual:self.mineViewController]){
        if (![FYLCommon isLogin]) {
            //
            FYLLoginViewController *loginViewController = [[FYLLoginViewController alloc] initWithLoginHandle:^(BOOL isLogin) {
                if (isLogin) {
                    [self.tabBarController setSelectedIndex:1];
                }else{
                    
                }
                
            }];
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            navigation.navigationBarHidden = YES;
            [self.navigationController presentViewController:navigation animated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}

- (void)tabBarController:(FYLTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //    if (viewController == self.competitionViewController && [self.competitionViewController respondsToSelector:@selector(changeTodayGameState)]) {
    //        [self.competitionViewController changeTodayGameState];
    //    }
}

- (void)tabBarController:(FYLTabBarController *)tabBarController didSelectMiddleItem:(UIButton *)button {
    if (![FYLCommon isLogin]) {
        FYLLoginViewController *loginViewController = [[FYLLoginViewController alloc] initWithLoginHandle:^(BOOL isLogin) {
            if (isLogin) {
                [self jumpToAddViewController];
            }
        }];
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        navigation.navigationBarHidden = YES;
        [self.navigationController presentViewController:navigation animated:YES completion:nil];
    }else{
        [self jumpToAddViewController];
    }
    
}

- (void)jumpToAddViewController {
    FYLAddViewController *addVC = [[FYLAddViewController alloc] initWithModel:nil andHandle:^(BOOL isSuccess, NSString *type) {
        [self.tabBarController setSelectedIndex:0];
        [self.homeViewController jumpToBarIndex:type andRefresh:YES];
    }];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
