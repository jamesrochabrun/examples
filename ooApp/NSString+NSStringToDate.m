//
//  NSString+NSStringToDate.m
//  ooApp
//
//  Created by James Rochabrun on 23-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//


#import "NSString+NSStringToDate.h"

@implementation NSString (NSStringToDate)

+ (NSString *)getTimeAgoString:(NSDate *)date {
    
    if(!date) {
        return @"";
    }

    NSInteger seconds = -1 * [date timeIntervalSinceNow];
    
    NSLog(@"the seconds past are %lu", seconds);
    NSString *timeStamp;
    
    if (seconds <= kMinute) {
        //return NSLocalizedString(@"moments ago", @"datetime string");
        return timeStamp = [NSString stringWithFormat:@"%lisec", (NSInteger)seconds];

    } else if (seconds <= kMinute + 29) {
        //return NSLocalizedString(@"1 minute ago", @"datetime string");
        return timeStamp = [NSString stringWithFormat:@"%limin", (NSInteger)seconds/kMinute];
        
    } else if (seconds <= 44 * kMinute + 29) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d minutes ago", @"datetime string"),(NSInteger)(seconds/kMinutes == 1 ? 2 : seconds/kMinutes)];];
        return timeStamp = [NSString stringWithFormat:@"%limin", (NSInteger)(seconds/kMinute == 1 ? 2 : seconds/kMinute)];

    } else if (seconds <= 90 * kMinute) {
        //return NSLocalizedString(@"about 1 hour ago", @"datetime string");
        return  timeStamp = @"1h";
        
    } else if (seconds <= 23 * kHour + 59 * kMinute + 29) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"about %d hours ago", @"datetime string"),(NSInteger)(seconds/kHours)];
        NSString *timeStamp = [NSString stringWithFormat:@"%ldh", (NSInteger)(seconds/kHour)];
        NSLog(@"the timestamp is  %@", timeStamp);
        return timeStamp;
        
    } else if (seconds <= 47 * kHour + 59 * kMinute + 29) {
        //return NSLocalizedString(@"1 day ago", @"datetime string");
        return timeStamp = @"1d";
        
    } else if (seconds <= 29 * kDay + 23 * kHour + 59 * kMinute + 29) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d days ago", @"datetime string"),(NSInteger)seconds/kDays];
        return timeStamp = [NSString stringWithFormat:@"%ldd" , (NSInteger)seconds/kDay];
        
    } else if (seconds <= 59 * kDay + 23 * kHour + 59 * kMinute + 29) {
        //return NSLocalizedString(@"1 month ago", @"datetime string");
        return  timeStamp = @"1m";
        
    } else if (seconds <= 365 * kDay - 1) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d months ago", @"datetime string"), (NSInteger)seconds/kMonths];
        return timeStamp = [NSString stringWithFormat:@"%ldm",(NSInteger)seconds/kMonth];
        
    } else if (seconds <= 365 * kDay + 3 * kMonth) {
        //return NSLocalizedString(@"1 year ago", @"datetime string");
        return timeStamp = @"1y";
        
    } else if (seconds <= 365 * kDay + 9 * kMonth) {
        //return NSLocalizedString(@"1+ year ago", @"datetime string");
        return timeStamp = @"1y";
        
    } else if (seconds <= 2 * 365 * kDay - 1) {
        //return NSLocalizedString(@"2 years ago", @"datetime string");
        return timeStamp = @"2y";
        
    } else {
       // return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d years ago", @"datetime string"), (NSInteger)seconds/(365*kDays)];
        return timeStamp = [NSString stringWithFormat:@"%ldy", (NSInteger)seconds/(365 * kDay)];
        
    }
}








@end
