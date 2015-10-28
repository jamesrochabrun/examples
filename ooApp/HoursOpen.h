//
//  HoursOpen.h
//  ooApp
//
//  Created by Anuj Gujar on 10/23/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyHoursDay;
extern NSString *const kKeyHoursOpen;
extern NSString *const kKeyHoursClose;
extern NSString *const kKeyHoursTime;

@interface HoursOpen : NSObject

@property (nonatomic) NSUInteger openDay;
@property (nonatomic) NSUInteger openTime;
@property (nonatomic) NSUInteger closeDay;
@property (nonatomic) NSUInteger closeTime;

+ (HoursOpen *)hoursOpenFromDict:(NSDictionary *)dict;
- (NSString *)formattedHoursOpen;

@end
