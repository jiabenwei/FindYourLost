//
//  FYLLoginViewController.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/7.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLRootViewController.h"

typedef void(^loginHandle)(BOOL isLogin);

@interface FYLLoginViewController : FYLRootViewController

- (instancetype)initWithLoginHandle:(loginHandle)loginHandle;

@end
