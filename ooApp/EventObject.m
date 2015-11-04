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

NSString *const kKeyEventID = @"event_id";
NSString *const kKeyIsComplete = @"is_complete";
NSString *const kKeySpecialEvent = @"special_event";
NSString *const kKeyReviewSite = @"review_site";
NSString *const kKeyName = @"name";
NSString *const kKeyComment = @"comment";
NSString *const kKeyTotalPrice = @"total_price";
NSString *const kKeyCreatedAt = @"created_at";
NSString *const kKeyUpdatedAt = @"updated_at";
NSString *const kKeyEventDate = @"event_date";
NSString *const kKeyWhenVotingCloses = @"voting_closed_at";
NSString *const kKeyEventType = @"type";
NSString *const kKeyKeywords = @"keywords";
NSString *const kKeyFriendRecommendationAge = @"friend_recommendation_age";
NSString *const kKeyCreatorID = @"creator_id";
NSString *const kKeyNumberOfPeople = @"num_people";
NSString *const kKeyNumberOfPeopleResponded = @"num_responded";
NSString *const kKeyNumberOfPeopleVoted = @"num_voted";
NSString *const kKeyMediaURL = @"media_url";
NSString *const kKeyNumberOfVenues=  @"num_restaurants";
NSString *const kKeyEventMediaItem = @"media_item";

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
    if  ([dictionary isKindOfClass:[NSDictionary class]] ) {
        e.eventID = [dictionary [kKeyEventID] intValue];
        e.creatorID = [dictionary [kKeyCreatorID] intValue];
        
        id price=dictionary[ kKeyTotalPrice ];
        if  ([price isKindOfClass:[NSNumber class]] ) {
            e.totalPrice= [ ( (NSNumber*)price) doubleValue];
        }
        
        e.isComplete = parseIntegerOrNullFromServer(dictionary[kKeyIsComplete ]) ? YES : NO;
        e.eventType = parseIntegerOrNullFromServer(dictionary[kKeyEventType]);
        e.date= parseUTCDateFromServer ( dictionary[ kKeyEventDate]);
        e.dateWhenVotingClosed=parseUTCDateFromServer ( dictionary[ kKeyWhenVotingCloses]);
        e.name= parseStringOrNullFromServer ( dictionary[ kKeyName]);
        e.friendRecommendationAge = parseNumberOrNullFromServer ( dictionary[ kKeyFriendRecommendationAge]);
        e.reviewSite= parseStringOrNullFromServer ( dictionary[ kKeyReviewSite]);
        e.specialEvent= parseStringOrNullFromServer ( dictionary[ kKeySpecialEvent]);
        e.comment=  parseStringOrNullFromServer(dictionary[ kKeyComment]);
        e.createdAt= parseUTCDateFromServer ( dictionary[ kKeyCreatedAt]);
        e.updatedAt= parseUTCDateFromServer( dictionary[ kKeyUpdatedAt]);
        
        e.numberOfVenues= parseIntegerOrNullFromServer( dictionary[kKeyNumberOfVenues ]);
        e.numberOfPeople = parseIntegerOrNullFromServer (  dictionary[kKeyNumberOfPeople ]);
        e.numberOfPeopleResponded = parseIntegerOrNullFromServer ( dictionary[ kKeyNumberOfPeopleResponded]);
        e.numberOfPeopleVoted = parseIntegerOrNullFromServer ( dictionary[ kKeyNumberOfPeopleVoted]);

        e.eventCoverImageURL = parseStringOrNullFromServer (  dictionary[kKeyMediaURL ]);

        NSMutableArray* results=[NSMutableArray new];
        e.keywords= results;
        NSArray* array=dictionary[ kKeyKeywords];
        if (array) {
            for (NSString* string  in  array) {
                [results  addObject:string];
            }
        }
        
        NSDictionary* mediaDictionary= dictionary[kKeyEventMediaItem];
        if (mediaDictionary ) {
            NSLog  (@"EVENT INCLUDED MEDIA ITEM FOR %@",e.name);
            e.mediaItem= [MediaItemObject mediaItemFromDict:mediaDictionary];
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
    self.primaryImage= nil;
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

- (void)setPrimaryImage:(UIImage *)primaryImage
{
    if (primaryImage ) {
        _primaryImage= primaryImage;
    } else {
        _primaryImage= nil;
    }
    
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
                                        kKeyCreatedAt:_createdAt,
                                        kKeyUpdatedAt:_updatedAt,
                                        kKeyIsComplete:@(_isComplete),
                                        kKeyEventType:@(_eventType),// 1= user, 2= curated
                                        }.mutableCopy;
    
    if (_reviewSite && _reviewSite.length) dictionary[kKeyReviewSite] = _reviewSite;
    if (_name && _name.length) dictionary[kKeyName] = _name;
    if (_comment && _comment.length) dictionary[kKeyComment] = _comment;
    if (_specialEvent && _specialEvent.length) dictionary[kKeySpecialEvent] = _specialEvent;
    if (_keywords && _keywords.count) dictionary[ kKeyKeywords] = _keywords;
    if (_eventID > 0) dictionary[kKeyEventID] = @(_eventID);
    if (_date) dictionary[kKeyEventDate] = _date;
    if (_dateWhenVotingClosed) dictionary[kKeyWhenVotingCloses] = _dateWhenVotingClosed;
    if (_friendRecommendationAge > 0) dictionary[kKeyFriendRecommendationAge] = @(_friendRecommendationAge);
    if (_totalPrice > 0) dictionary[kKeyTotalPrice] = @(_totalPrice);
    
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
        if  (!_venues || !_venues.count) {
            return nil;
        }
        return _venues[0];
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
                             message( @"Added.");
                         } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
                            } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
                           weakSelf.hasBeenAltered= YES;
                          success();
                       } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
                                     
                                     [self.users removeAllObjects];
                                     for (UserObject *user in users) {
                                         [self.users addObject:user];
                                     }
                                     weakSelf.hasBeenAltered= YES;

                                     success();
                                 } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                     failure();
                                 }];
    
}

- (AFHTTPRequestOperation *)refreshVenuesFromServerWithSuccess:(void (^)())success
                                                       failure:(void (^)())failure;
{
    __weak EventObject *weakSelf = self;
    return [OOAPI getVenuesForEvent:self success:^(NSArray *venues) {
        @synchronized(_venues)  {
            [self.venues removeAllObjects];
            for (RestaurantObject *venue in venues) {
                [_venues addObject:venue];
            }
        }
        [weakSelf establishPrimaryImage];
        
        success();
    } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
    [OOAPI reviseEvent:APP.eventBeingEdited
               success:^(id foo) {
                   NSLog  (@"UPDATED BACKEND WITH NEW DATES.");
               } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                   NSLog  (@"UNABLE TO UPDATE BACKEND WITH NEW DATES.");
               }];
}

- (void)establishPrimaryImage;
{
    NSString *originalImageIdentifier=self.primaryVenueImageIdentifier;
    
    self.primaryVenueImageIdentifier= nil;
    
    if ( self.mediaItem) {
        if ((self.primaryVenueImageIdentifier= self.mediaItem.reference))
            return;
    }
    
    // The previous slower way.
    @synchronized(_venues)  {
        for (RestaurantObject* r  in  self.venues) {
            if  (r.mediaItems.count ) {
                MediaItemObject *media= r.mediaItems[0];
                NSString *imageReference= media.reference;
                if  (imageReference ) {
                    self.primaryVenueImageIdentifier= imageReference;
                    if (!originalImageIdentifier ||  ![imageReference isEqualToString:originalImageIdentifier] ) {
                        self.hasBeenAltered= YES;
                    }
                    break;
                }
            }
        }
    }
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
    return [OOAPI getVoteForEvent:self
                          success:^(NSArray *votes) {
                              @synchronized(_votes) {
                                  [self.votes removeAllObjects];
                                  [self.votes addObjectsFromArray: votes ];
                              }
                              weakSelf.hasBeenAltered= YES;

                              NSLog  (@"GOT %ld VOTES FOR EVENT %ld.", ( long)votes.count,  (long)self.eventID);
                              success();
                          }
                          failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
