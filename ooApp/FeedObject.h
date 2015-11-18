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

enum{
    VERB_UNKNOWN= 0,
	VERB_REQUESTED_TO_FOLLOW= 1,
    VERB_UPDATED_LIST = 2,
    VERB_ADDED_LIST = 3,
	VERB_ADDED_VENUE= 4,
    VERB_ADDED_PHOTOS = 5,
    VERB_ADDED_EVENT = 6,
    VERB_REPOSTED_PHOTO= 7,
    VERB_REPOSTED_LIST= 8,
    VERB_REPOSTED_VENUE = 9,
    VERB_VOTED_ON_EVENT= 10,

};

@end

