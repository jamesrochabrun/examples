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

@implementation EventObject

+ (EventObject*) eventFromDictionary: (NSDictionary*)dictionary;
{
    EventObject* e= [[EventObject  alloc] init];
    if  ([dictionary isKindOfClass:[NSDictionary class]] ) {
        e.eventID= [dictionary[ @"event_id"] intValue];
        e.creatorID= [dictionary[ @"creator_id"] intValue];
        
        id price=dictionary[ @"total_price"];
        if  ([price isKindOfClass:[NSNumber class]] ) {
            e.totalPrice= [ ( (NSNumber*)price) doubleValue];
        }
        
        e.isComplete= parseIntegerOrNullFromServer( dictionary[ @"is_complete"]) ? YES : NO;
        e.eventType= parseIntegerOrNullFromServer( dictionary[ @"type"]);
        e.date= parseUTCDateFromServer ( dictionary[ @"event_date"]);
        e.dateWhenVotingClosed=parseUTCDateFromServer ( dictionary[ @"when_voting_closed"]);
        e.name= parseStringOrNullFromServer ( dictionary[ @"name"]);
        e.friendRecommendationAge = parseNumberOrNullFromServer ( dictionary[ @"friend_recommendation_age"]);
        e.reviewSite= parseStringOrNullFromServer ( dictionary[ @"review_site"]);
        e.specialEvent= parseStringOrNullFromServer ( dictionary[ @"special_event"]);
        e.comment=  parseStringOrNullFromServer(dictionary[ @"comment"]);
        e.createdAt= parseUTCDateFromServer ( dictionary[ @"created_at"]);
        e.updatedAt= parseUTCDateFromServer( dictionary[ @"updated_at"]);
        
        e.numberOfPeople = parseNumberOrNullFromServer ( dictionary[ @"num_people"]);
        e.numberOfPeopleResponded = parseNumberOrNullFromServer ( dictionary[ @"num_responded"]);
        e.numberOfPeopleVoted = parseNumberOrNullFromServer ( dictionary[ @"num_voted"]);

        e.eventCoverImageURL = parseStringOrNullFromServer ( dictionary[ @"media_url"]);

        NSMutableArray* results=[NSMutableArray new];
        e.keywords= results;
        NSArray* array=dictionary[ @"keywords"];
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
                                        @"created_at":_createdAt,
                                        @"updated_at":_updatedAt,
                                        @"is_complete": @(_isComplete),
                                        @"event_type": @(_eventType),// 1= user, 2= curated

                                        }.mutableCopy;
    
    if  (_reviewSite  && _reviewSite.length) dictionary[ @"review_site"]= _reviewSite;
    if  (_name  && _name.length) dictionary[ @"name"]= _name;
    if  (_comment  && _comment.length) dictionary[ @"review_site"]= _comment;
    if  (_specialEvent  && _specialEvent.length) dictionary[ @"special_event"]= _specialEvent;
    if  (_keywords  && _keywords.count) dictionary[ @"keywords"]= _keywords;
    if  (_eventID>0 ) dictionary[ @"event_id"]=@(_eventID);
    if  (_date  ) dictionary[ @"event_date"]= _date;
    if  (_dateWhenVotingClosed  ) dictionary[ @"when_voting_closed"]= _dateWhenVotingClosed;
    if  (_friendRecommendationAge>0 ) dictionary[ @"friend_recommendation_age"]=@(_friendRecommendationAge);
    if  (_totalPrice>0 ) dictionary[ @"total_price"]=@(_totalPrice);

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
