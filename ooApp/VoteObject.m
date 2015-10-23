//
//  VoteObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "VoteObject.h"

@implementation VoteObject


+ (instancetype)voteFromDictionary:(NSDictionary *)dictionary;
{
    if  (!dictionary) {
        return nil;
    }
    
    VoteObject *object = [[VoteObject alloc] init];
    object.venueID = parseIntegerOrNullFromServer( dictionary[@"restaurant_id"]);
    object.userID = parseIntegerOrNullFromServer( dictionary[@"user_id"]);
    object.vote = parseIntegerOrNullFromServer( dictionary[@"vote"]);
    object.eventID = parseIntegerOrNullFromServer( dictionary[@"event_id"]);
    
    // XX: Need more validation here.
    if (object.vote != 1) {
        object.vote= 0;
    }
    
    return object;
}

@end

