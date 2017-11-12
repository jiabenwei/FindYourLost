//
//  FYLIPRecorder.m
//  FindYourLost
//
//  Created by 贾 on 2017/11/12.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLIPRecorder.h"

@implementation FYLIPRecorder

+ (NSString *)getDeviceWANIPAddress {
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSData *data = [NSData dataWithContentsOfURL:ipURL];
    NSString *ipStr = nil;
    if (data) {
        NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (ipDic && [ipDic[@"code"] integerValue] == 0) {
            ipStr = ipDic[@"data"][@"ip"];
        }
    }
    return (ipStr ? ipStr : @"");
}
@end
