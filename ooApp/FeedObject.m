//
//  FeedObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "FeedObject.h"

@implementation FeedObject

//{
//publisher_id: 1
//publisher_username: "Walt"
//message: "following"
//parameters: "Weaver_Mollie"
//action: "none"
//media_item: {
//}
//published_at: "2015-11-20T18:28:54.379Z"
//}
//-
//1:  {
//publisher_id: 1
//publisher_username: "Walt"
//message: "following"
//parameters: "Becker_Eugenia"
//action: "none"
//media_item: {
//media_item_id: 107
//restaurant_id: 29
//type: 1
//reference: "CmRdAAAAQ4xNUKj3gCZg2sqLGJ3dWxkFuLqO3IalUieYA4DXTOrAnKktq44kTsA0WO0xRDpEsrg1WMiey2CRqzCICTfZn2GugcDoyk-N7dmPMQePP56dnivBo7SSKjPQYsi3yRY7EhBBGXgMSK4ugEoFR6d3gOydGhRaMCJm44ipdEzR-ArKE7-Z09bTtA"
//created_at: "2015-11-15T18:36:07.000Z"
//updated_at: "2015-11-15T18:36:07.000Z"
//source: 2
//source_user_id: null
//height: 400
//width: 300
//url: null
//}
//    -
//published_at: "2015-11-20T18:28:50.756Z"
//}

NSString*const kVerbRequestsToFollow=  @"request_follow";
NSString*const kVerbFavorite=  @"favorite";
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
        object.verb= VERB_FOLLOW;
    }
    else if ([verbString isEqualToString: kVerbFavorite]) {
        object.verb= VERB_FAVORITE;
    }
    else if ([verbString isEqualToString: kVerbAddedList]) {
        object.verb= VERB_NEW_LIST;
    }
    else if ([verbString isEqualToString: kVerbAddedRestaurant]) {
        object.verb= VERB_NEW_VENUE;
    }
    else if ([verbString isEqualToString: kVerbAddedEvent]) {
        object.verb= VERB_NEW_EVENT;
    }
    else if ([verbString isEqualToString: kVerbAddedPhotos]) {
        object.verb= VERB_NEW_PHOTOS;
    }
    else if ([verbString isEqualToString: kVerbRepostedList]) {
        object.verb= VERB_REPOST_LIST;
    }
    else if ([verbString isEqualToString: kVerbRepostedPhoto]) {
        object.verb= VERB_REPOST_PHOTO;
    }
    else if ([verbString isEqualToString: kVerbRepostedRestaurant]) {
        object.verb= VERB_REPOST_VENUE;
    }
    else if ([verbString isEqualToString: kVerbVotedOnEvent]) {
        object.verb= VERB_VOTE;
    }
    
    return object;
}

@end

