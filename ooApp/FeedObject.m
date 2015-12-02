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
NSString*const kKeyObjectID=  @"object_id";
NSString*const kKeyVerb=  @"message";
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
    
    FeedObject *feedItem = [[FeedObject alloc] init];
    feedItem.subjectID = parseIntegerOrNullFromServer( dictionary[kKeyPublisherID]);
    feedItem.subjectName = parseStringOrNullFromServer( dictionary[kKeyPublisherUsername]);
    
    feedItem.objectID = parseIntegerOrNullFromServer( dictionary[kKeyPublisherID]);
    feedItem.objectName=parseStringOrNullFromServer( dictionary[kKeyParameters]);
    
    feedItem.verb = parseStringOrNullFromServer( dictionary[kKeyVerb]);
    
//    feedItem.parameters = parseStringOrNullFromServer( dictionary[kKeyParameters]);
//    feedItem.action = parseStringOrNullFromServer( dictionary[kKeyAction]);
    feedItem.publishedAt = parseUTCDateFromServer( dictionary[kKeyPublishedAt ]);
    
    NSDictionary* mediaDictionary= dictionary[ kKeyMediaItem];
    if (mediaDictionary ) {
        feedItem.mediaItem= [MediaItemObject mediaItemFromDict:mediaDictionary];
    }
    
    // Infer from verb what types the subject and object are.
    // NOTE: These values are used in provideFeedObject.
    //
    NSString* verb= feedItem.verb;
    feedItem.subjectType= FEED_OBJECT_TYPE_USER; // default subject type
    feedItem.objectType= FEED_OBJECT_TYPE_USER; //  default object type
    feedItem.isNotification= NO;

    if ([verb isEqualToString: @"followee-updated-list"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_LIST;
    }
    else if ([verb isEqualToString: @"posted-photo"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_RESTAURANT;
    }
    else if ([verb isEqualToString: @"posted-list"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_LIST;
    }
    else if ([verb isEqualToString: @"posted-restaurant"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_RESTAURANT;
    }
    else if ([verb isEqualToString: @"followed-users"  ]) {
    }
    else if ([verb isEqualToString: @"follow"  ]) {
        // This verb to be removed
    }
    else if ([verb isEqualToString: @"attended-event"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_EVENT;
    }
    else if ([verb isEqualToString: @"invited-you"  ]) {
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"voting-ended"  ]) {
        feedItem.subjectType= FEED_OBJECT_TYPE_EVENT;
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"canceled-event"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_EVENT;
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"voted-on-event"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_EVENT;
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"event-starting"  ]) {
        feedItem.subjectType= FEED_OBJECT_TYPE_EVENT;
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"added-restaurants-to-list"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_LIST;
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"requested-to-follow-you"  ]) {
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"accepted-follow-request"  ]) {
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"sent-you-restaurants"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_RESTAURANT;
        feedItem.isNotification= YES;
    }
    else if ([verb isEqualToString: @"sent-you-lists"  ]) {
        feedItem.objectType= FEED_OBJECT_TYPE_LIST;
        feedItem.isNotification= YES;
    }
    else  {
        NSLog  (@"UNKNOWN VERB  %@",verb);
    }
    
    if  (!translationDictionary) {
        static dispatch_once_t once=0;
        dispatch_once(&once,
                      ^{
                          translationDictionary=  @{
                                                    @"followed-users": @"followed",
                                                    @"posted-photo": @"posted photos",
                                                    @"invited-you": @"invited you to",
                                                    @"sent-you-lists": @"sent you lists"
                                                    // XX:  more to come
                                                    };
                          
                      });
    }
    
    if  ( feedItem.verb  ) {
        feedItem.translatedMessage = translationDictionary [feedItem.verb];
        if  (feedItem.translatedMessage ) {
            feedItem.translatedMessage = LOCAL(feedItem.translatedMessage);
        } else {
            feedItem.translatedMessage= feedItem.verb;
        }
    }
    
    return feedItem;
}

//
//Returnable Objects: Restaurants, Lists, Events, Profile, Photo
//Actions: Favorite, Add to wishlist, Add to list/event, Repost, Follow, New List/Events

@end

