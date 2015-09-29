//
//  TimeUtilities.m
//  ooApp
//
//  Created by Anuj Gujar on 9/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "TimeUtilities.h"

NSString *const kMealCategoryBreakfast = @"breakfast";
NSString *const kMealCategoryLunch = @"lunch";
NSString *const kMealCategoryDinner = @"dinner";
NSString *const kMealCategoryBar = @"bar+restaurant";

@implementation TimeUtilities

/////////////
// Given a time determine if we are looking for breakfast, lunch, dinner or bars
/////////////
+ (NSString *)categorySearchString:(NSDate *)date {
    NSString *category = @"restaurant";

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    //start of day
    NSDate *dayStart = [gregorian dateBySettingHour:0 minute:00 second:0 ofDate:date options:0];
    //breakfast zone starts 4AM
    NSDate *breakfastStart = [dayStart dateByAddingTimeInterval:(4)*60*60];
    //lunch zone starts 10:30AM
    NSDate *lunchStart = [dayStart dateByAddingTimeInterval:(10.5)*60*60];
    //dinner zone starts 3PM
    NSDate *dinnerStart = [dayStart dateByAddingTimeInterval:11*60*60];
    //bar zone starts 10PM
    NSDate *barStart = [dayStart dateByAddingTimeInterval:11*60*60];
    
    if (([dayStart compare:date] == NSOrderedAscending ||
        [dayStart compare:date] == NSOrderedSame) &&
        [breakfastStart compare:date] == NSOrderedDescending) {
        category = kMealCategoryBar;
    } else if (([breakfastStart compare:date] == NSOrderedAscending ||
               [breakfastStart compare:date] == NSOrderedSame) &&
               [lunchStart compare:date] == NSOrderedDescending) {
        category = kMealCategoryBreakfast;
    } else if (([lunchStart compare:date] == NSOrderedAscending ||
                [lunchStart compare:date] == NSOrderedSame) &&
               [dinnerStart compare:date] == NSOrderedDescending) {
        category = kMealCategoryLunch;
    } else if (([dinnerStart compare:date] == NSOrderedAscending ||
                 [dinnerStart compare:date] == NSOrderedSame) &&
                [barStart compare:date] == NSOrderedDescending) {
        category = kMealCategoryDinner;
    } else {
        category = kMealCategoryBar;
    }
    
    return category;
}

@end
