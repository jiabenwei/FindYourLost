//
//  FYLCommon.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYLCommon : NSObject

+ (UIImage*) createImageWithColor: (UIColor*) color;
+ (BOOL)isLogin;
+ (NSString *)geDateStringWithOriginString:(NSString *)string;
@end
