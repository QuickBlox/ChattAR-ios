//
//  Utilites.m
//  ChattAR
//
//  Created by Igor Alefirenko on 26/09/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

static NSString* const kSecondsKey = @"seconds";
static NSString* const kMinutesKey = @"minutes";
static NSString* const kHoursKey = @"hours";
static NSString* const kDayKey = @"day";
static NSString* const kDaysKey = @"days";
static NSString* const kWeekKey = @"week";
static NSString* const kWeeksKey = @"weeks";
static NSString* const kMonthKey = @"month";
static NSString* const kMonthsKey = @"months";
static NSString* const kYearKey = @"year";
static NSString* const kYearsKey = @"years";

static const CGFloat kMinute = 60.0f;
static const CGFloat kHour = 3600.0f;
static const CGFloat kDay = 86400.0f;
static const CGFloat kWeek = 604800.0f;
static const CGFloat kMonth = 2419200.0f;
static const CGFloat kYear = 29030400.0f;

#import "Utilites.h"
#import "MBProgressHUD.h"

@implementation Utilites

+ (instancetype)shared {
    static id defaultKit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultKit = [[self alloc] init];
    });
    return defaultKit;
}

- (id)init {
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        self.userLoggedIn = NO;
        self.isArNotAvailable = NO;
    }
    return self;
}

- (NSInteger)yearsFromDate:(NSString *)dateString {
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    [self.dateFormatter setDateFormat:@"HH:mm"];
    NSDate *todayDate = [NSDate date];
    int seconds = [todayDate timeIntervalSinceDate:date];
    
    int allDays = (((seconds/60)/60)/24);
    int days = allDays%365;
    int years = (allDays-days)/365;
    return years;
}

#pragma mark -
#pragma mark Converter

- (NSString *)distanceFormatter:(CLLocationDistance)distance {
    NSString *formatedDistance;
    NSInteger dist = round(distance);
    if (distance <=999) {
        formatedDistance = [NSString stringWithFormat:@"%d m", dist];
    } else{
        dist = round(dist) / 1000;
        formatedDistance = [NSString stringWithFormat:@"%d km",dist];
    }
    return formatedDistance;
}


# pragma mark -
#pragma mark Time
- (NSDictionary *)fullTimePassedFormat
{
	if (_fullTimePassedFormat == nil) {
		_fullTimePassedFormat = @{kSecondsKey : @"%d sec. ago",
								  kMinutesKey : @"%d min. ago",
								  kHoursKey : @"%d hr. ago",
                                  kDayKey : @"%d days ago",
                                  kDaysKey : @"%d days ago",
                                  kWeekKey : @"%d week ago",
								  kWeeksKey : @"%d weeks ago",
                                  kMonthKey : @"%d month ago",
								  kMonthsKey : @"%d months ago",
                                  kYearKey : @"%d year ago",
								  kYearsKey : @"%d years ago"};
	}
	return _fullTimePassedFormat;
}

- (NSString *)fullFormatPassedTimeFromDate:(NSDate *)date
{
	return [self timePassedToString:date withPatternDictionary:self.fullTimePassedFormat];
}

- (NSString *)timePassedToString:(NSDate *)date withPatternDictionary:(NSDictionary *)patterns
{
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
	
    NSString *datetimeString;
	
	if (interval < kMinute) {
		datetimeString = [NSString stringWithFormat:patterns[kSecondsKey], (int)interval];
	} else if (interval >= kMinute && interval <= kHour) {
		datetimeString = [NSString stringWithFormat:patterns[kMinutesKey], (int)(interval / kMinute)];
	} else if (interval > kHour && interval <= kDay) {
		datetimeString = [NSString stringWithFormat:patterns[kHoursKey], (int)(interval / kHour)];
	} else if (interval > kDay && interval <= kWeek) {
		datetimeString = [self formatDateTimeForDay:(int)(interval / kDay) withPatternDictionary:patterns];
	} else if (interval > kWeek && interval <= kMonth) {
        datetimeString = [self formatDateTimeForWeek:(int)(interval / kWeek) withPatternDictionary:patterns];
	} else if (interval > kMonth && interval <= kYear) {
        datetimeString = [self formatDateTimeForMonth:(int)(interval / kMonth) withPatternDictionary:patterns];
	} else if (interval > kYear) {
        datetimeString = [self formatDateTimeForYear:(int)(interval / kYear) withPatternDictionary:patterns];
	}
    
    return datetimeString;
}

///////////////////////////

- (NSString*)formatDateTimeForYear:(NSInteger)yearValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* year = nil;
    if (yearValue == 1) {
        year = [NSString stringWithFormat:patterns[kYearKey], yearValue];
    } else {
        year = [NSString stringWithFormat:patterns[kYearsKey], yearValue];
    }
    return year;
}

- (NSString*)formatDateTimeForDay:(NSInteger)dayValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* day = nil;
    if (dayValue == 1) {
        day = [NSString stringWithFormat:patterns[kDayKey], dayValue];
    } else {
        day = [NSString stringWithFormat:patterns[kDaysKey], dayValue];
    }
    return day;
}

- (NSString*)formatDateTimeForWeek:(NSInteger)weekValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* week = nil;
    if (weekValue == 1) {
        week = [NSString stringWithFormat:patterns[kWeekKey], weekValue];
    } else {
        week = [NSString stringWithFormat:patterns[kWeeksKey], weekValue];
    }
    return week;
}

- (NSString*)formatDateTimeForMonth:(NSInteger)monthValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* month = nil;
    if (monthValue == 1) {
        month = [NSString stringWithFormat:patterns[kMonthKey], monthValue];
    } else {
        month = [NSString stringWithFormat:patterns[kMonthsKey], monthValue];
    }
    return month;
}


#pragma mark -
#pragma mark Status Bar

- (void)checkAndPutStatusBarColor{
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}


#pragma mark -
#pragma mark Supporting AR

+ (BOOL)deviceSupportsAR {
	BOOL support;
	//Detect camera and compas
	if((![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) || (![CLLocationManager headingAvailable])){
		support = NO;
	} else {
        support = YES;
    }
	return support;
}

- (BOOL)isUserLoggedIn {
    return self.userLoggedIn;
}

- (void)setUserLogIn {
    self.userLoggedIn = YES;
}


#pragma mark -
#pragma mark Escape symbols encoding

+(NSString*)urlencode:(NSString*)unencodedString{
	NSString * encodedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!-*|~'();:%@&=+$,/\?%#[]{}_^#<>£€¥•", kCFStringEncodingUTF8 ));
	return encodedString;
}

+(NSString*)urldecode:(NSString*)encodedString{
	NSString* decodedString =CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding( NULL, (CFStringRef)encodedString, CFSTR(""), kCFStringEncodingUTF8));
	return decodedString;
}

@end
