//
//  UserStatsObject.m
//  Oomami
//
//  Created by Zack Smith on 12/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UserStatsObject.h"

@implementation UserStatsObject

NSString *const kKeyStatsUser = @"user_id";
NSString *const kKeyStatsVenueTotal = @"restaurant_count";
NSString *const kKeyStatsListsTotal = @"list_count";
NSString *const kKeyStatsFollowerTotal = @"follower_count";
NSString *const kKeyStatsFolloweeTotal = @"followee_count";
NSString *const kKeyStatsPhotosTotal = @"media_item_count";
NSString *const kKeyStatsLikesTotal = @"likes_count";

+ (UserStatsObject *)statsFromDictionary:(NSDictionary *)dictionary;
{
    if (!dictionary) {
        return nil;
    }
    
    UserStatsObject *object= [[UserStatsObject  alloc] init];
    if  (![dictionary isKindOfClass:[NSDictionary class]] )
        return object;
    
    object.userid=  parseUnsignedIntegerOrNullFromServer(dictionary[kKeyStatsUser]);
    object.totalVenues=parseUnsignedIntegerOrNullFromServer( dictionary[ kKeyStatsVenueTotal]);
    object.totalLists=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey: kKeyStatsListsTotal]);
    object.totalFollowers=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey: kKeyStatsFollowerTotal]);
    object.totalFollowees=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey: kKeyStatsFolloweeTotal]);
    object.totalPhotos=parseUnsignedIntegerOrNullFromServer([dictionary objectForKey:kKeyStatsPhotosTotal]);
    object.totalLikes= parseUnsignedIntegerOrNullFromServer([ dictionary  objectForKey:kKeyStatsLikesTotal]);
    
    return object;
}

@end
