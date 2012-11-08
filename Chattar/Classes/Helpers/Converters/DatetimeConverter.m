//
//  DatetimeConverter.m
//  ChattAR for facebook
//
//  Created by QuickBlox developers on 9/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DatetimeConverter.h"

@implementation DatetimeConverter

+ (NSDate *)dateFromString:(NSString *)str{
    static NSDateFormatter* sISO8601 = nil;
    
    str = [str stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@" +"];
	
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        [sISO8601 setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    }
    NSDate *d = [sISO8601 dateFromString:str];
    return d;
	
}

@end
