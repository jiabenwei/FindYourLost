//
//  FYLAddViewController.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/8.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLRootViewController.h"

typedef void(^refreshHandle)(BOOL isSuccess, NSString *type);

@interface FYLAddViewController : FYLRootViewController

- (instancetype)initWithModel:(BmobObject *)model andHandle:(refreshHandle)handle;


@end
