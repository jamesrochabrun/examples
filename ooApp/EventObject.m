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
NSString *const kKeyWhenVotingCloses = @"when_voting_closed";
NSString *const kKeyEventType = @"type";
NSString *const kKeyKeywords = @"keywords";
NSString *const kKeyFriendRecommendationAge = @"friend_recommendation_age";
NSString *const kKeyCreatorID = @"creator_id";
NSString *const kKeyNumberOfPeople = @"num_people";
NSString *const kKeyNumberOfPeopleResponded = @"num_responded";
NSString *const kKeyNumberOfPeopleVoted = @"num_voted";
NSString *const kKeyMediaURL = @"media_url";

@implementation EventObject

+ (EventObject *)eventFromDictionary:(NSDictionary *)dictionary;
{
    EventObject* e= [[EventObject  alloc] init];
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
        
        e.numberOfPeople = parseNumberOrNullFromServer ( kKeyNumberOfPeople);
        e.numberOfPeopleResponded = parseNumberOrNullFromServer ( dictionary[ kKeyNumberOfPeopleResponded]);
        e.numberOfPeopleVoted = parseNumberOrNullFromServer ( dictionary[ kKeyNumberOfPeopleVoted]);

        e.eventCoverImageURL = parseStringOrNullFromServer ( kKeyMediaURL);

        NSMutableArray* results=[NSMutableArray new];
        e.keywords= results;
        NSArray* array=dictionary[ kKeyKeywords];
        if (array) {
            for (NSString* string  in  array) {
                [results  addObject:string];
            }
        }
        
    }
    return e;
}

-(NSDictionary*) dictionaryFromEvent;
{
    if  (!_createdAt) {
        _createdAt= [NSDate date];
    }
    if  (!_updatedAt) {
        _updatedAt= [NSDate date];
    }
    
    NSMutableDictionary *dictionary=  @{
                                        kKeyCreatedAt:_createdAt,
                                        kKeyUpdatedAt:_updatedAt,
                                        kKeyIsComplete: @(_isComplete),
                                        kKeyEventType: @(_eventType),// 1= user, 2= curated

                                        }.mutableCopy;
    
    if  (_reviewSite  && _reviewSite.length) dictionary[ kKeyReviewSite]= _reviewSite;
    if  (_name  && _name.length) dictionary[kKeyName]= _name;
    if  (_comment  && _comment.length) dictionary[ kKeyComment]= _comment;
    if  (_specialEvent  && _specialEvent.length) dictionary[kKeySpecialEvent]= _specialEvent;
    if  (_keywords  && _keywords.count) dictionary[ kKeyKeywords]= _keywords;
    if  (_eventID>0 ) dictionary[ kKeyEventID ]=@(_eventID);
    if  (_date  ) dictionary[ kKeyEventDate]= _date;
    if  (_dateWhenVotingClosed  ) dictionary[ kKeyWhenVotingCloses]= _dateWhenVotingClosed;
    if  (_friendRecommendationAge>0 ) dictionary[ kKeyFriendRecommendationAge]=@(_friendRecommendationAge);
    if  (_totalPrice>0 ) dictionary[ kKeyTotalPrice]=@(_totalPrice);

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
