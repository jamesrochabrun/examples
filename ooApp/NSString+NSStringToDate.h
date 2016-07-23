//
//  NSString+NSStringToDate.h
//  ooApp
//
//  Created by James Rochabrun on 23-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDays       (86400)
#define kMonths     (kDays*30)
#define kHours      (3600)
#define kMinutes    (60)




@interface NSString (NSStringToDate)
+ (NSString *)getTimeAgoString:(NSString *)dateStr;

@end
