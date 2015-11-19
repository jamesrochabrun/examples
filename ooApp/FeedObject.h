//
//  FeedObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
#import <time.h>

@interface FeedObject: NSObject

@property (nonatomic, assign) NSUInteger feedID; 
@property (nonatomic, assign) NSUInteger subjectID; // user
@property (nonatomic, assign) NSUInteger objectID; // venue, list, event
@property (nonatomic, assign) NSUInteger mediaID; //  photo etc.
@property (nonatomic, assign) NSUInteger objectType;
@property (nonatomic, assign) NSUInteger verb;
@property (nonatomic,strong) NSString* textToDisplay;
@property (nonatomic, assign) BOOL isNotification; // false =>  update
@property (nonatomic,assign)  time_t timestamp;

+ (instancetype) feedObjectFromDictionary:(NSDictionary *)dictionary;


//
//Returnable Objects: Restaurants, Lists, Events, Profile, Photo
//Actions: Favorite, Add to wishlist, Add to list/event, Repost, Follow, New List/Events

enum{
    VERB_UNKNOWN= 0,
	VERB_FOLLOW= 1,
    VERB_ADD_TO_WISHLIST = 2,
    VERB_ADD_TO_LIST = 3,
	VERB_ADD_TO_VENUE= 4,
    VERB_ADD_TO_EVENT = 5,
    VERB_NEW_PHOTOS = 6,
    VERB_NEW_LIST = 7,
    VERB_NEW_EVENT = 8,
    VERB_NEW_VENUE = 9,
    VERB_REPOST_PHOTO= 10,
    VERB_REPOST_LIST= 11,
    VERB_REPOST_VENUE = 12,
    VERB_VOTE= 13,
    VERB_FAVORITE= 14,

};

@end

