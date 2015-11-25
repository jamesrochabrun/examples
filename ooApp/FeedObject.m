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
NSString*const kVerbFavorite=  @"favorite";
NSString*const kVerbAddedList=  @"added_list";
NSString*const kVerbAddedRestaurant=  @"added_restaurant";
NSString*const kVerbAddedEvent=  @"added_event";
NSString*const kVerbAddedPhotos=  @"added_photos";
NSString*const kVerbRepostedPhoto=  @"reposted_photo";
NSString*const kVerbRepostedList=  @"reposted_list";
NSString*const kVerbRepostedRestaurant=  @"reposted_restaurant";
NSString*const kVerbVotedOnEvent=  @"voted";

NSString*const kKeyFeedID=  @"feed_id";
NSString*const kKeyPublisherID=  @"publisher_id";
NSString*const kKeyPublisherUsername=  @"publisher_username";
NSString*const kKeyMessage=  @"message";
NSString*const kKeyParameters=  @"parameters";
NSString*const kKeyAction=  @"action";
NSString*const kKeyPublishedAt=  @"published_at";
NSString*const kKeyMediaItem=  @"media_item";

static NSDictionary *translationDictionary= nil;

+ (instancetype) feedObjectFromDictionary:(NSDictionary *)dictionary;
{
    if  (!dictionary) {
        return nil;
    }
    
    FeedObject *object = [[FeedObject alloc] init];
    object.feedID=parseIntegerOrNullFromServer( dictionary[kKeyFeedID]);
    object.publisherID = parseIntegerOrNullFromServer( dictionary[kKeyPublisherID]);
    object.publisherUsername = parseStringOrNullFromServer( dictionary[kKeyPublisherUsername]);
    object.message = parseStringOrNullFromServer( dictionary[kKeyMessage]);
    object.parameters = parseStringOrNullFromServer( dictionary[kKeyParameters]);
    object.action = parseStringOrNullFromServer( dictionary[kKeyAction]);
    object.publishedAt = parseUTCDateFromServer( dictionary[kKeyPublishedAt ]);
    
    NSDictionary* mediaDictionary= dictionary[ kKeyMediaItem];
    if (mediaDictionary ) {
        object.mediaItem= [MediaItemObject mediaItemFromDict:mediaDictionary];
    }
    
    if  (!translationDictionary) {
        static dispatch_once_t once=0;
        dispatch_once(&once,
                      ^{
                          translationDictionary=  @{
                                                    @"follow": @"followed",
                                                    @"favorite": @"favorited",
                                                    @"repost": @"reposted",
                                                    @"vote": @"voted on your event",
                                                    @"text": @"sent you a message"
                                                    };
                          
                      });
    }
    
    if  ( object.message  ) {
        object.translatedMessage = translationDictionary [object.message];
        if  (object.translatedMessage ) {
            object.translatedMessage = LOCAL(object.translatedMessage);
        } else {
            object.translatedMessage= object.message;
        }
    }
    
    return object;
}


//
//Returnable Objects: Restaurants, Lists, Events, Profile, Photo
//Actions: Favorite, Add to wishlist, Add to list/event, Repost, Follow, New List/Events

@end

