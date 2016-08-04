//
//  NSString+NSStringToDate.h
//  ooApp
//
//  Created by James Rochabrun on 23-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


//seconds in
#define kDay       (86400)
#define kMonth    (kDay*30)
#define kHour     (3600)
#define kMinute    (60)




@interface NSString (NSStringToDate)
+ (NSString *)getTimeAgoString:(NSDate *)date;

@end
