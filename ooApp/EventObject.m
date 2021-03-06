//
//  EventObject.m
//  ooApp
//
//  Created by Anuj Gujar on 8/13/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "EventObject.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "OOAPI.h"
#import "AppDelegate.h"
#import "UserObject.h"
#import "Settings.h"

NSString *const kKeyEventEventID = @"event_id";
NSString *const kKeyEventIsComplete = @"is_complete";
NSString *const kKeyEventSpecialEvent = @"special_event";
NSString *const kKeyEventReviewSite = @"review_site";
NSString *const kKeyEventName = @"name";
NSString *const kKeyEventComment = @"comment";
NSString *const kKeyEventTotalPrice = @"total_price";
NSString *const kKeyEventCreatedAt = @"created_at";
NSString *const kKeyEventUpdatedAt = @"updated_at";
NSString *const kKeyEventEventDate = @"event_date";
NSString *const kKeyEventWhenVotingCloses = @"voting_closed_at";
NSString *const kKeyEventEventType = @"type";
NSString *const kKeyEventKeywords = @"keywords";
NSString *const kKeyEventFriendRecommendationAge = @"friend_recommendation_age";
NSString *const kKeyEventCreatorID = @"creator_id";
NSString *const kKeyEventNumberOfPeople = @"num_people";
NSString *const kKeyEventNumberOfPeopleResponded = @"num_responded";
NSString *const kKeyEventNumberOfPeopleVoted = @"num_voted";
NSString *const kKeyEventMediaURL = @"media_url";
NSString *const kKeyEventNumberOfVenues=  @"num_restaurants";
NSString *const kKeyEventEventMediaItem = @"media_item";
NSString *const kKeyEventAdministrators=  @"admin_ids";

BOOL isEventObject (id  object)
{
    return [ object isKindOfClass:[EventObject  class]];
}

@implementation EventObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _venues= [NSMutableOrderedSet new];
        _users= [NSMutableOrderedSet new];
        _votes= [NSMutableArray new];
    }
    return self;
}

+ (EventObject *)eventFromDictionary:(NSDictionary *)dictionary;
{
    EventObject *e= [[EventObject  alloc] init];
    if  (![dictionary isKindOfClass:[NSDictionary class]] )
        return e;
    
    e.eventID = [dictionary [kKeyEventEventID] intValue];
    e.creatorID = [dictionary [kKeyEventCreatorID] intValue];
    
    id price=dictionary[ kKeyEventTotalPrice ];
    if  ([price isKindOfClass:[NSNumber class]] ) {
        e.totalPrice= [ ( (NSNumber*)price) doubleValue];
    }
    
    e.isComplete = parseIntegerOrNullFromServer(dictionary[kKeyEventIsComplete ]) ? YES : NO;
    e.eventType = parseIntegerOrNullFromServer(dictionary[kKeyEventEventType]);
    e.date= parseUTCDateFromServer ( dictionary[ kKeyEventEventDate]);
    e.dateWhenVotingClosed=parseUTCDateFromServer ( dictionary[ kKeyEventWhenVotingCloses]);
    e.name= parseStringOrNullFromServer ( dictionary[ kKeyEventName]);
    e.friendRecommendationAge = parseNumberOrNullFromServer ( dictionary[ kKeyEventFriendRecommendationAge]);
    e.reviewSite= parseStringOrNullFromServer ( dictionary[ kKeyEventReviewSite]);
    e.specialEvent= parseStringOrNullFromServer ( dictionary[ kKeyEventSpecialEvent]);
    e.comment=  parseStringOrNullFromServer(dictionary[ kKeyEventComment]);
    e.createdAt= parseUTCDateFromServer ( dictionary[ kKeyEventCreatedAt]);
    e.updatedAt= parseUTCDateFromServer( dictionary[ kKeyEventUpdatedAt]);
    
    e.numberOfVenues= parseIntegerOrNullFromServer( dictionary[kKeyEventNumberOfVenues ]);
    e.numberOfPeople = parseIntegerOrNullFromServer (  dictionary[kKeyEventNumberOfPeople ]);
    e.numberOfPeopleResponded = parseIntegerOrNullFromServer ( dictionary[ kKeyEventNumberOfPeopleResponded]);
    e.numberOfPeopleVoted = parseIntegerOrNullFromServer ( dictionary[ kKeyEventNumberOfPeopleVoted]);
    
    e.eventCoverImageURL = parseStringOrNullFromServer (  dictionary[kKeyEventMediaURL ]);
    
    NSMutableArray* results=[NSMutableArray new];
    e.keywords= results;
    NSArray* array=dictionary[ kKeyEventKeywords];
    if (array) {
        for (NSString* string  in  array) {
            [results  addObject:string];
        }
    }
    
    NSDictionary* mediaDictionary= dictionary[kKeyEventEventMediaItem];
    if (mediaDictionary ) {
        NSLog  (@"EVENT INCLUDED MEDIA ITEM FOR %@",e.name);
        e.mediaItem= [MediaItemObject mediaItemFromDict:mediaDictionary];
        e.primaryImageURL= e.mediaItem.url;
        e.primaryVenueImageIdentifier= e.mediaItem.reference;
    }
    
    // NOTE: We need to know early as possible whether the current user can edit this event.

    NSMutableOrderedSet* administrators=[NSMutableOrderedSet new];
    e.administrators= administrators;
    e.editability= EVENT_USER_CANNOT_EDIT;

    array=dictionary[kKeyEventAdministrators];
    if (array) {
        e.administrators= [NSMutableOrderedSet new];

        UserObject*user= [Settings sharedInstance].userObject;
        if ( user) {
            NSUInteger currentUserID=user.userID;
            for (NSNumber* number  in  array) {
                [e.administrators  addObject: number];
                
                NSUInteger userid= [number  unsignedLongValue];
                if  (userid== currentUserID) {
                    e.editability= EVENT_USER_CAN_EDIT;
                    NSLog  (@"USER CAN EDIT EVENT.");
                }
            }
        }
    }

    return e;
}

- (NSUInteger)totalUsers;
{
    return _users.count;
}

- (void)dealloc
{
    [_venues removeAllObjects ];
    [_users removeAllObjects ];
    [_votes removeAllObjects ];
    [_keywords removeAllObjects ];
    self.date= nil;
    self.dateWhenVotingClosed= nil;
    self.createdAt= nil;
    self.updatedAt= nil;
    self.eventCoverImageURL= nil;
    self.name= nil;
    self.eventCoverImageURL= nil;
    self.reviewSite= nil;
    self.specialEvent= nil;
    self.comment= nil;
    self.mediaItem= nil;
}

- (NSDictionary *)dictionaryFromEvent;
{
    if (!_createdAt) {
        _createdAt= [NSDate date];
    }
    if (!_updatedAt) {
        _updatedAt= [NSDate date];
    }
    
    NSMutableDictionary *dictionary=  @{
                                        kKeyEventCreatedAt:_createdAt,
                                        kKeyEventUpdatedAt:_updatedAt,
                                        kKeyEventIsComplete:@(_isComplete),
                                        kKeyEventEventType:@(_eventType),// 1= user, 2= curated
                                        }.mutableCopy;
    
    if (_reviewSite && _reviewSite.length) dictionary[kKeyEventReviewSite] = _reviewSite;
    if (_name && _name.length) dictionary[kKeyEventName] = _name;
    if (_comment && _comment.length) dictionary[kKeyEventComment] = _comment;
    if (_specialEvent && _specialEvent.length) dictionary[kKeyEventSpecialEvent] = _specialEvent;
    if (_keywords && _keywords.count) dictionary[ kKeyEventKeywords] = _keywords;
    if (_eventID > 0) dictionary[kKeyEventEventID] = @(_eventID);
    if (_date) dictionary[kKeyEventEventDate] = _date;
    if (_dateWhenVotingClosed) dictionary[kKeyEventWhenVotingCloses] = _dateWhenVotingClosed;
    if (_friendRecommendationAge > 0) dictionary[kKeyEventFriendRecommendationAge] = @(_friendRecommendationAge);
    if (_totalPrice > 0) dictionary[kKeyEventTotalPrice] = @(_totalPrice);
    if ( _creatorID>0) {
        dictionary[kKeyEventCreatorID]= @(_creatorID);
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSUInteger) totalVenues
{
    @synchronized(_venues)  {
        return _venues.count;
    }
}

- (RestaurantObject *)firstVenue
{
    @synchronized(_venues)  {
        return [_venues firstObject];
    }
    return nil;
}

- (BOOL)alreadyHasVenue:(RestaurantObject *)venue;
{
    @synchronized(_venues)  {
        BOOL hasMatchingID=  [_venues containsObject: venue];
        if ( hasMatchingID) {
            return YES;
        }
        if  (venue.googleID ) {
            NSString*goog=venue.googleID;
            for (RestaurantObject* object  in  _venues) {
                if  ([object.googleID isEqualToString: goog  ]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)addVenue:(RestaurantObject *)venue completionBlock:(void (^)(BOOL))completionBlock
{
    if (!venue) {
        if  (completionBlock) completionBlock (NO);
        return;
    }
    
    @synchronized(_venues)  {
        if (![_venues containsObject: venue]) {
            [_venues addObject: venue];
            self.hasBeenAltered= YES;

            [OOAPI addRestaurant:venue
                         toEvent:self
                         success:^(id response) {
                             NSLog (@"SUCCESS IN ADDING VENUE TO EVENT.");
//                             message( @"Added.");
                             self.numberOfVenues++;
                             if  (completionBlock) completionBlock (YES);
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog  (@"FAILED TO ADD VENUE TO EVENT %@",error);
                             [_venues removeObject: venue];
                             if  (completionBlock) completionBlock (NO);
                         }];
        }
    }
}

- (void)removeVenue:(RestaurantObject *)venue completionBlock:(void (^)(BOOL))completionBlock;
{
    if (!venue) {
        if  (completionBlock) completionBlock (NO);
        return;
    }
    
    @synchronized(_venues)  {
        if ([_venues containsObject: venue]) {
            [_venues removeObject: venue];
            self.hasBeenAltered= YES;

            [OOAPI removeRestaurant:venue
                          fromEvent:self
                            success:^(id response) {
                                NSLog (@"SUCCESS IN REMOVING VENUE FROM EVENT.");
//                                message( @"Removed.");
                                self.numberOfVenues--;

                                if  (completionBlock) completionBlock (YES);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [_venues addObject: venue];
                                NSLog  (@"FAILED TO REMOVE VENUE FROM EVENT %@",error);
                                if  (completionBlock) completionBlock (NO);
                            }];
        }
    }
}

- (BOOL)userIsAdministrator: (NSUInteger)userid
{
    if  ([self.administrators containsObject:@(userid)] ) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addVenue:(RestaurantObject *)venue 
{
    [self addVenue:venue completionBlock:nil];
}

- (void)removeVenue:(RestaurantObject *)venue
{
    [self removeVenue:venue completionBlock:nil];
}

- (RestaurantObject *)getNthVenue:(NSInteger)index;
{
    if  (index <0 )
        return nil;
    
    @synchronized(_venues)  {
        
        if  (index>= _venues.count ) {
            return nil;
        }
        return _venues[index];
    }
}

- (AFHTTPRequestOperation *)refreshParticipantStatsFromServerWithSuccess:(void (^)())success
                                                                 failure:(void (^)())failure;
{
    __weak EventObject *weakSelf = self;

    return [OOAPI getEventByID:self.eventID
                       success:^(EventObject *event) {
                           weakSelf.numberOfPeople= event.numberOfPeople;
                           weakSelf.numberOfPeopleResponded= event.numberOfPeopleResponded;
                           weakSelf.numberOfPeopleVoted= event.numberOfPeopleVoted;
                          success();
                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           failure();
                       }
            ];
}

- (AFHTTPRequestOperation *)refreshUsersFromServerWithSuccess:(void (^)())success
                                                      failure:(void (^)())failure;
{
    __weak EventObject *weakSelf = self;

    return [OOAPI getParticipantsInEvent:self
                                 success:^(NSArray *users) {
                                     
                                     [weakSelf.users removeAllObjects];
                                     for (UserObject *user in users) {
                                         [weakSelf.users addObject:user];
                                     }

                                     success();
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     failure();
                                 }];
}

- (AFHTTPRequestOperation*) refreshWithSuccess: (void (^)())success
                                       failure:(void (^)())failure
{
    __weak EventObject *weakSelf = self;
    return [OOAPI getEventByID: self.eventID
                       success:^(EventObject *event) {
                           if  (!weakSelf.name || (event.name && ![event.name isEqualToString: weakSelf.name])) {
                               weakSelf.name=event.name;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (!weakSelf.eventCoverImageURL || (event.eventCoverImageURL && ![event.eventCoverImageURL isEqualToString: weakSelf.eventCoverImageURL])) {
                               weakSelf.eventCoverImageURL=event.eventCoverImageURL;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (!weakSelf.date || (event.date && ![event.date isEqualToDate: weakSelf.date])) {
                               weakSelf.date=event.date;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (!weakSelf.dateWhenVotingClosed || (event.dateWhenVotingClosed && ![event.dateWhenVotingClosed isEqualToDate: weakSelf.dateWhenVotingClosed])) {
                               weakSelf.dateWhenVotingClosed=event.dateWhenVotingClosed;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (weakSelf.totalPrice<=0 || (event.totalPrice>0 && event.totalPrice != weakSelf.totalPrice)) {
                               weakSelf.totalPrice=event.totalPrice;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (weakSelf.numberOfVenues==0 || (event.numberOfVenues>0 && event.numberOfVenues != weakSelf.numberOfVenues)) {
                               weakSelf.numberOfVenues=event.numberOfVenues;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (weakSelf.numberOfPeople==0 || (event.numberOfPeople>0 && event.numberOfPeople != weakSelf.numberOfPeople)) {
                               weakSelf.numberOfPeople=event.numberOfPeople;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (weakSelf.numberOfPeopleVoted==0 || (event.numberOfPeopleVoted>0 && event.numberOfPeopleVoted != weakSelf.numberOfPeopleVoted)) {
                               weakSelf.numberOfPeopleVoted=event.numberOfPeopleVoted;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (weakSelf.numberOfPeopleResponded==0 || (event.numberOfPeopleResponded>0 && event.numberOfPeopleResponded != weakSelf.numberOfPeopleResponded)) {
                               weakSelf.numberOfPeopleResponded=event.numberOfPeopleResponded;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (!weakSelf.reviewSite || (event.reviewSite && ![event.reviewSite isEqualToString: weakSelf.reviewSite])) {
                               weakSelf.reviewSite=event.reviewSite;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (!weakSelf.specialEvent || (event.specialEvent && ![event.specialEvent isEqualToString: weakSelf.specialEvent])) {
                               weakSelf.specialEvent=event.specialEvent;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (!weakSelf.comment || (event.comment && ![event.comment isEqualToString: weakSelf.comment])) {
                               weakSelf.comment=event.comment;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           if  (weakSelf.friendRecommendationAge<=0 || (event.friendRecommendationAge>0 && event.friendRecommendationAge != weakSelf.friendRecommendationAge)) {
                               weakSelf.friendRecommendationAge=event.friendRecommendationAge;
                               weakSelf.hasBeenAltered=YES;
                           }
                           
                           success();
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog  (@"FAILED TO REFRESH EVENT");
                           failure();
                       }];
}

- (AFHTTPRequestOperation *)refreshVenuesFromServerWithSuccess:(void (^)())success
                                                       failure:(void (^)())failure;
{
    __weak EventObject *weakSelf = self;
    return [OOAPI getVenuesForEvent:self success:^(NSArray *venues) {
        @synchronized(_venues)  {
            [weakSelf.venues removeAllObjects];
            for (RestaurantObject *venue in venues) {
                [weakSelf.venues addObject:venue];
            }
        }
        
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure();
    }];
}

- (NSString *)asString;
{
    return [NSString stringWithFormat:@"EVENT %ld %@ #venues=%ld media=%@",
            (long)_eventID,
            _name,
            (long)[self totalVenues],
            _primaryVenueImageIdentifier
            ];
}

- (void)sendDatesToServerWithCompletionBlock:(void (^)())completionBlock;
{
    [OOAPI reviseEvent: self
               success:^(id foo) {
                   completionBlock();
                   NSLog  (@"UPDATED BACKEND WITH NEW DATES.");
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog  (@"UNABLE TO UPDATE BACKEND WITH NEW DATES.");
                   completionBlock();
               }];
}

- (RestaurantObject *)lookupVenueByID:(NSUInteger)identifier;
{
    if  ( !identifier) {
        return nil;
    }
    
    @synchronized(_venues)  {
        if  (!_venues.count || !identifier) {
            return nil;
        }
        
        
        for (RestaurantObject *venue in _venues) {
            if (venue.restaurantID) {
                if (venue.restaurantID == identifier) {
                    return venue;
                }
            }
        }
    }
    return nil;
}

- (AFHTTPRequestOperation *)refreshVotesFromServerWithSuccess:(void (^)())success
                                                      failure:(void (^)())failure;
{
    __weak EventObject *weakSelf = self;
    return [OOAPI getVotesForEvent:self
                          success:^(NSArray *votes) {
                              @synchronized(weakSelf.votes) {
                                  [weakSelf.votes removeAllObjects];
                                  [weakSelf.votes addObjectsFromArray: votes ];
                              }

                              NSLog  (@"GOT %ld VOTES FOR EVENT %ld.", ( long)votes.count,  (long)weakSelf.eventID);
                              success();
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              NSLog  (@"UNABLE TO GET VOTES FOR EVENT.");
                              failure();
                          }];
    
}

- (VoteObject *)lookupVoteByVenueID:(NSUInteger)identifier;
{
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    
    @synchronized(_votes) {
        for (VoteObject* vote  in  _votes) {
            if ( vote.eventID ==  _eventID && vote.userID==userid  && identifier == vote.venueID) {
                return  vote;
            }
        }
    }
    return nil;
}

@end
