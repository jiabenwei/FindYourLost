//
//  FYLMYContributionViewController.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLRootViewController.h"
typedef NS_ENUM(NSUInteger,FYLType){
    FYLTypeLost,
    FYLTypeFound,
};


@interface FYLMYContributionViewController : FYLRootViewController

- (instancetype)initWithType:(FYLType)type;

@end
