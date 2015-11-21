//
//  EventObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/13/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OONetworkManager.h"
#import "VoteObject.h"
#import "MediaItemObject.h"

extern NSString *const kKeyEventEventID;

@class RestaurantObject;

@interface EventObject : NSObject

typedef enum : char {
    EVENT_TYPE_NONE= 0,
    EVENT_TYPE_CURATED= 1,
    EVENT_TYPE_USER= 2,
} EventType;

@property (nonatomic) NSUInteger eventID;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) BOOL hasBeenAltered;
@property (nonatomic) NSUInteger creatorID; // Participant type 0.
@property (nonatomic, strong) NSString *eventCoverImageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) EventType eventType;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *dateWhenVotingClosed;
@property (nonatomic, assign) double totalPrice;
@property (nonatomic, assign) NSInteger numberOfVenues;
@property (nonatomic, assign) NSInteger numberOfPeople;
@property (nonatomic, assign) NSInteger numberOfPeopleVoted;
@property (nonatomic, assign) NSInteger numberOfPeopleResponded;
@property (nonatomic, strong) NSMutableArray *keywords;
@property (nonatomic, strong) NSMutableOrderedSet *users;
@property (nonatomic, strong) NSMutableOrderedSet *administrators;
@property (nonatomic, strong) NSMutableOrderedSet *venues;
@property (nonatomic, strong) NSMutableArray *votes;
@property (nonatomic, strong) NSString *reviewSite;
@property (nonatomic, strong) NSString *specialEvent;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, assign) NSInteger friendRecommendationAge;
@property (nonatomic, strong) NSString *primaryVenueImageIdentifier;
@property (nonatomic, strong) UIImage *primaryImage;
@property (nonatomic, strong) MediaItemObject *mediaItem;
@property (nonatomic,assign) int currentUserCanEdit;
enum {
    EVENT_USER_CAN_EDIT=1,
    EVENT_USER_CANNOT_EDIT=2,
    EVENT_EDITABILITY_UNKNOWN=0
};
+ (EventObject *)eventFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryFromEvent;

- (NSUInteger)totalUsers;

- (void)addVenue:(RestaurantObject *)venue;
- (void)removeVenue:(RestaurantObject *)venue;
- (RestaurantObject *)getNthVenue:(NSInteger)index;
- (NSUInteger)totalVenues;
- (RestaurantObject *)firstVenue;

- (AFHTTPRequestOperation *)refreshUsersFromServerWithSuccess:(void (^)())success
                                                       failure:(void (^)())failure;
- (AFHTTPRequestOperation *)refreshVenuesFromServerWithSuccess:(void (^)())success
                                                       failure:(void (^)())failure;
- (AFHTTPRequestOperation *)refreshParticipantStatsFromServerWithSuccess:(void (^)())success
                                                                 failure:(void (^)())failure;
- (AFHTTPRequestOperation *)refreshVotesFromServerWithSuccess:(void (^)())success
                                                      failure:(void (^)())failure;
- (NSString *)asString;

- (void)sendDatesToServer;
- (void)establishPrimaryImage;

- (RestaurantObject *)lookupVenueByID:(NSUInteger)identifier;
- (VoteObject *)lookupVoteByVenueID:(NSUInteger)identifier;

@end

