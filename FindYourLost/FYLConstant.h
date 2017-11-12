//
//  FYLConstant.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define Screen_Width  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define Screen_height MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define RatioPoint(value)  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)/375*value

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?94:60)
#define kNormalTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?78:44)
#define kSafeBottomHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

#define ISLOGIN           @"isLogin"
#define FYLUSERID         @"userId"
#define FYLUSERNAME       @"userName"
#define FYLUSERIMAGE      @"userImage"
#define TABLEUSER         @"JWUser"
#define TABLELOST         @"JWLost"
#define TABLEVISITOR      @"JWVisitor"
#define BMOBKEY           @"0f0323eafba9cf517ce59c4aaec88359"
