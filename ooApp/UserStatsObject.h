//
//  UserStatsObject.h
//  Oomami
//
//  Created by Zack Smith on 12/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserStatsObject: NSObject

@property (nonatomic,assign) NSUInteger userid;
@property (nonatomic,assign) NSUInteger totalFollowers;
@property (nonatomic,assign) NSUInteger totalFollowees;
@property (nonatomic,assign) NSUInteger totalLists;
@property (nonatomic,assign) NSUInteger totalPhotos;
@property (nonatomic,assign) NSUInteger totalVenues;

+ (UserStatsObject *)statsFromDictionary:(NSDictionary *)dictionary;

@end
