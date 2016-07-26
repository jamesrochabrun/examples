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
    NSString *timeStamp;
    
    if (seconds <= 29) {
        //return NSLocalizedString(@"moments ago", @"datetime string");
        return timeStamp = [NSString stringWithFormat:@"%lisec", (NSInteger)seconds];
        
    } else if (seconds <= kMinutes + 29) {
        //return NSLocalizedString(@"1 minute ago", @"datetime string");
        return timeStamp = [NSString stringWithFormat:@"%limin", (NSInteger)seconds];
        
    } else if (seconds <= 44 * kMinutes + 29) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d minutes ago", @"datetime string"),(NSInteger)(seconds/kMinutes == 1 ? 2 : seconds/kMinutes)];];
        return timeStamp = [NSString stringWithFormat:@"%limin", (NSInteger)(seconds/kMinutes == 1 ? 2 : seconds/kMinutes)];

    } else if (seconds <= 90 * kMinutes) {
        //return NSLocalizedString(@"about 1 hour ago", @"datetime string");
        return  timeStamp = @"1h";
        
    } else if (seconds <= 23 * kHours + 59 * kMinutes + 29) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"about %d hours ago", @"datetime string"),(NSInteger)(seconds/kHours)];
        return timeStamp = [NSString stringWithFormat:@"%ldh", (NSInteger)(seconds/kHours)];
        
    } else if (seconds <= 47*kHours+59*kMinutes+29) {
        //return NSLocalizedString(@"1 day ago", @"datetime string");
        return timeStamp = @"1d";
        
    } else if (seconds <= 29*kDays+23*kHours+59*kMinutes+29) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d days ago", @"datetime string"),(NSInteger)seconds/kDays];
        return timeStamp = [NSString stringWithFormat:@"%ldd" , (NSInteger)seconds/kDays];
        
    } else if (seconds <= 59 * kDays + 23 * kHours + 59 * kMinutes + 29) {
        //return NSLocalizedString(@"1 month ago", @"datetime string");
        return  timeStamp = @"1m";
        
    } else if (seconds <= 365 * kDays - 1) {
        //return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d months ago", @"datetime string"), (NSInteger)seconds/kMonths];
        return timeStamp = [NSString stringWithFormat:@"%ldm",(NSInteger)seconds/kMonths];
        
    } else if (seconds <= 365 * kDays + 3 * kMonths) {
        //return NSLocalizedString(@"1 year ago", @"datetime string");
        return timeStamp = @"1y";
        
    } else if (seconds <= 365*kDays+9*kMonths) {
        //return NSLocalizedString(@"1+ year ago", @"datetime string");
        return timeStamp = @"1y";
        
    } else if (seconds <= 2*365*kDays-1) {
        //return NSLocalizedString(@"2 years ago", @"datetime string");
        return timeStamp = @"2y";
        
    } else {
       // return [[NSString alloc] initWithFormat:NSLocalizedString(@"%d years ago", @"datetime string"), (NSInteger)seconds/(365*kDays)];
        return timeStamp = [NSString stringWithFormat:@"%ldy", (NSInteger)seconds/(365*kDays)];
        
    }
}








@end
