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
    e.currentUserCanEdit= EVENT_USER_CANNOT_EDIT;

    array=dictionary[kKeyEventAdministrators];
    if (array) {
        UserObject*user= [Settings sharedInstance].userObject;
        if ( user) {
            NSUInteger currentUserID=user.userID;
            
            for (NSNumber* number  in  array) {
                [results  addObject: number];
                
                NSUInteger userid= [number  unsignedLongValue];
                if  (userid== currentUserID) {
                    e.currentUserCanEdit= EVENT_USER_CAN_EDIT;
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
        return [_venues containsObject: venue];
    }
}

- (void)addVenue:(RestaurantObject *)venue;
{
    if (!venue) {
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
//                             message( @"Added.");6
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog  (@"FAILED TO ADD VENUE TO EVENT %@",error);
                             [_venues removeObject: venue];
                             
                         }];
        }
    }
}

- (void)removeVenue:(RestaurantObject *)venue;
{
    if (!venue) {
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
                                message( @"Removed.");
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [_venues addObject: venue];
                                NSLog  (@"FAILED TO REMOVE VENUE FROM EVENT %@",error);
                            }];
        }
    }
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

- (void)sendDatesToServer;
{
    [OOAPI reviseEvent: self
               success:^(id foo) {
                   NSLog  (@"UPDATED BACKEND WITH NEW DATES.");
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog  (@"UNABLE TO UPDATE BACKEND WITH NEW DATES.");
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
