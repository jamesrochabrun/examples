//
//  EventObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/13/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventObject : NSObject

typedef enum : char {
    EVENT_TYPE_NONE= 0,
    EVENT_TYPE_USER= 1,
    EVENT_TYPE_SYSTEM= 2,
} EventType;

@property (nonatomic) NSInteger eventID;
@property (nonatomic,assign) BOOL isComplete;
@property (nonatomic) NSInteger creatorID; // Participant type 0.
@property (nonatomic, strong) NSString *eventCoverImageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic,assign) EventType eventType;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *dateWhenVotingClosed;
@property (nonatomic,assign) double totalPrice;
@property (nonatomic,assign) NSInteger numberOfPeople;
@property (nonatomic,assign) NSInteger numberOfPeopleVoted;
@property (nonatomic,assign) NSInteger numberOfPeopleResponded;
@property (nonatomic, strong) NSMutableArray *keywords;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) NSString *reviewSite;
@property (nonatomic, strong) NSString *specialEvent;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic,assign) NSInteger friendRecommendationAge;

+ (EventObject*) eventFromDictionary: (NSDictionary*)dictionary;
-(NSDictionary*) dictionaryFromEvent;

@end
