//
//  FeedObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "FeedObject.h"

@implementation FeedObject

NSString*const kVerbRequestsToFollow=  @"request_follow";
NSString*const kVerbUpdatedList=  @"updated_list";
NSString*const kVerbAddedList=  @"added_list";
NSString*const kVerbAddedRestaurant=  @"added_restaurant";
NSString*const kVerbAddedEvent=  @"added_event";
NSString*const kVerbAddedPhotos=  @"added_photos";
NSString*const kVerbRepostedPhoto=  @"reposted_photo";
NSString*const kVerbRepostedList=  @"reposted_list";
NSString*const kVerbRepostedRestaurant=  @"reposted_restaurant";
NSString*const kVerbVotedOnEvent=  @"voted";

+ (instancetype) feedObjectFromDictionary:(NSDictionary *)dictionary;
{
    if  (!dictionary) {
        return nil;
    }
    
    FeedObject *object = [[FeedObject alloc] init];
    object.feedID=parseIntegerOrNullFromServer( dictionary[@"feed_id"]);
    object.subjectID = parseIntegerOrNullFromServer( dictionary[@"user_id"]);
    object.objectID = parseIntegerOrNullFromServer( dictionary[@"object_id"]);
    object.mediaID = parseIntegerOrNullFromServer( dictionary[@"photo_id"]);
    object.textToDisplay= trimString( dictionary[@"description"] ?:  @"");
    object.timestamp = parseIntegerOrNullFromServer( dictionary[@"timestamp"]);
    
    NSString* typeString= dictionary[@"type"] ?:  @"";
    object.isNotification= [typeString isEqualToString: @"notification"];
    
    NSString* verbString= dictionary[@"description"] ?:  @"";
    object.verb = VERB_UNKNOWN;
    if ( [verbString isEqualToString: kVerbRequestsToFollow]) {
        object.verb= VERB_REQUESTED_TO_FOLLOW;
    }
    else if ([verbString isEqualToString: kVerbUpdatedList]) {
        object.verb= VERB_UPDATED_LIST;
    }
    else if ([verbString isEqualToString: kVerbAddedList]) {
        object.verb= VERB_ADDED_LIST;
    }
    else if ([verbString isEqualToString: kVerbAddedRestaurant]) {
        object.verb= VERB_ADDED_VENUE;
    }
    else if ([verbString isEqualToString: kVerbAddedEvent]) {
        object.verb= VERB_ADDED_EVENT;
    }
    else if ([verbString isEqualToString: kVerbAddedPhotos]) {
        object.verb= VERB_ADDED_PHOTOS;
    }
    else if ([verbString isEqualToString: kVerbRepostedList]) {
        object.verb= VERB_REPOSTED_LIST;
    }
    else if ([verbString isEqualToString: kVerbRepostedPhoto]) {
        object.verb= VERB_REPOSTED_PHOTO;
    }
    else if ([verbString isEqualToString: kVerbRepostedRestaurant]) {
        object.verb= VERB_REPOSTED_VENUE;
    }
    else if ([verbString isEqualToString: kVerbVotedOnEvent]) {
        object.verb= VERB_VOTED_ON_EVENT;
    }
    
    return object;
}

@end

