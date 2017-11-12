//
//  FYLCommon.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLCommon.h"

@implementation FYLCommon


+ (UIImage*) createImageWithColor: (UIColor*) color {
    CGRect rect=CGRectMake(0,0, 1, 60);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (BOOL)isLogin {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERID];
    if (string && string.length) {
        return YES;
    }
    return NO;
}

+ (NSDate*)dateFromDateString:(NSString*)dateStr formatter:(NSString*)formatter {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:formatter];
    NSDate* date = [dateFormatter dateFromString:dateStr];
    return date;
}

+ (NSString*)stringFromDate:(NSDate *)date formatter:(NSString*)formatter{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

+ (NSString*)specifyDay:(NSInteger)offsetHour {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
    [components setHour:offsetHour];
    [components setMinute:0];
    [components setSecond:0];
    NSDate* specifyDate = [cal dateByAddingComponents:components toDate:today options:0];
    NSString* specifyDateString = [self stringFromDate:specifyDate formatter:@"yyyy-MM-dd"];
    return specifyDateString;
}

+ (NSString*)yesterdayDate {
    
    return [self specifyDay:-24];
}

+ (NSString*)todayDate {
    return [self specifyDay:0];
}

+ (NSString*)tomorrowDate {
    
    return [self specifyDay:24];
    
}
+ (NSString*)dayAfterTomorrow {
    
    return [self specifyDay:48];
}


+ (NSString *)geDateStringWithOriginString:(NSString *)string {
    NSDate* date = [self dateFromDateString:string formatter:@"yyyy-MM-dd"];
    
    NSString* dateString = [self stringFromDate:date formatter:@"yyyy-MM-dd"];
    NSString* dateStringWithoutYear = [self stringFromDate:date formatter:@"M-d"];
    
    NSString * yearString = [self stringFromDate:date formatter:@"yyyy"];
    NSString * thisYearString = [self stringFromDate:[NSDate date] formatter:@"yyyy"];
    
    NSString *returnDateString;
    if ([yearString isEqualToString:thisYearString]) {
        if ([dateString isEqualToString:[self yesterdayDate]]) {
            returnDateString = @"Yesterday";
        }else if ([dateString isEqualToString:[self todayDate]]){
            returnDateString = @"Today";
        }else if ([dateString isEqualToString:[self tomorrowDate]]){
            returnDateString = @"Tomorrow";
        }else{
            returnDateString = dateStringWithoutYear;
        }
    }else{
        returnDateString = dateString;
    }
    return returnDateString;
}


@end
