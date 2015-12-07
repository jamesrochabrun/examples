//
//  TimeUtilities.h
//  ooApp
//
//  Created by Anuj Gujar on 9/28/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtilities : NSObject

+ (NSArray *)categorySearchTerms:(NSDate *)date;
+ (NSTimeInterval)intervalFromDays:(NSUInteger)days hours:(NSUInteger)hours minutes:(NSUInteger)minutes second:(NSUInteger)seconds;

@end
