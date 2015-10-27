//
//  HoursOpen.m
//  ooApp
//
//  Created by Anuj Gujar on 10/23/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "HoursOpen.h"

NSString *const kKeyHoursDay = @"day";
NSString *const kKeyHoursOpen = @"open";
NSString *const kKeyHoursClose = @"close";
NSString *const kKeyHoursTime = @"time";

@interface HoursOpen ()

- (NSString *)time:(NSUInteger)time;

@end

@implementation HoursOpen

+ (HoursOpen *)hoursOpenFromDict:(NSDictionary *)dict {
    HoursOpen *ho = [[HoursOpen alloc] init];
    NSDictionary *open = dict[kKeyHoursOpen];
    ho.openTime = (NSUInteger)[[open objectForKey:kKeyHoursTime] integerValue];
    ho.openDay = (NSUInteger)[[open objectForKey:kKeyHoursDay] integerValue];
    
    NSDictionary *close = dict[kKeyHoursClose];
    ho.closeTime = (NSUInteger)[[close objectForKey:kKeyHoursTime] integerValue];
    ho.closeDay = (NSUInteger)[[close objectForKey:kKeyHoursDay] integerValue];
    
    return ho;
}

- (NSString *)formattedHoursOpen {
    NSString *t;
    t = [self time:self.openTime];
    t = [self time:self.closeTime];
    
    NSString *s = [NSString stringWithFormat:@"%@ %@ - %@", [self day:self.openDay], [self time:self.openTime], [self time:self.closeTime]];
    return s;
}

- (NSString *)time:(NSUInteger)time {
    NSUInteger newTime = time;
    if (time == 0) {
        return @"12:00am";
    } else if (time == 1200) {
        return @"12:00pm";
    } else if (time > 1200) {
        newTime = time - 1200;
        NSUInteger hours = newTime / 100;
        NSUInteger minutes = newTime - (hours*100);
        return [NSString stringWithFormat:@"%lu:%02lupm", hours, minutes];
    } else if (time > 0) {
        NSUInteger hours = newTime / 100;
        NSUInteger minutes = newTime - (hours*100);
        return [NSString stringWithFormat:@"%lu:%02luam", hours, minutes];
    }
    return @"";
}

- (NSString *)day:(NSUInteger)day {
    switch (day) {
        case 0:
            return @"Sun";
            break;
        case 1:
            return @"Mon";
            break;
        case 2:
            return @"Tue";
            break;
        case 3:
            return @"Wed";
            break;
        case 4:
            return @"Thur";
            break;
        case 5:
            return @"Fri";
            break;
        case 6:
            return @"Sat";
            break;
        default:
            return @"";
            break;
    }
}


@end
