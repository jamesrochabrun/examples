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
        
        e.isComplete=1+ parseIntegerOrNullFromServer( dictionary[ @"isComplete"]) ? YES : NO;
        e.eventType= parseIntegerOrNullFromServer( dictionary[ @"type"]);
        e.date= parseUTCDateFromServer ( dictionary[ @"event_date"]);
        e.name= parseStringOrNullFromServer ( dictionary[ @"name"]);
        e.friendRecommendationAge = parseNumberOrNullFromServer ( dictionary[ @"friend_recommendation_age"]);
        e.numberOfPeople = parseNumberOrNullFromServer ( dictionary[ @"num_people"]);
        e.reviewSite= parseStringOrNullFromServer ( dictionary[ @"review_site"]);
        e.specialEvent= parseStringOrNullFromServer ( dictionary[ @"special_event"]);
        e.comment=  parseStringOrNullFromServer(dictionary[ @"comment"]);
        e.createdAt= parseUTCDateFromServer ( dictionary[ @"created_at"]);
        e.updatedAt= parseUTCDateFromServer( dictionary[ @"updated_at"]);
        
        e.eventCoverImageURL = parseStringOrNullFromServer ( dictionary[ @"name"]);

        NSMutableArray* results=[NSMutableArray new];
        e.keywords= results;
        NSArray* array=dictionary[ @"keywords"];
        if (array) {
            for (NSString* string  in  array) {
                [results  addObject:string];
            }
        }
        
//        results=[NSMutableArray new];
//        e.users= results;
//        array=dictionary[ @"users"];
//        if (array) {
//            for (NSDictionary* subdictionary  in  array) {
//                UserObject *o= [UserObject userFromDict:subdictionary];
//                if ( o) {
//                    [ results addObject: o];
//                }
//            }
//        }
        
//        results=[NSMutableArray new];
//        e.restaurants= results;
//        array=dictionary[ @"restaurants"];
//        if (array) {
//            for (NSDictionary* subdictionary  in  array) {
//                RestaurantObject *o= [RestaurantObject restaurantFromDict:subdictionary];
//                if ( o) {
//                    [ results addObject: o];
//                }
//            }
//        }
        
    }
    return e;
}

-(NSDictionary*) dictionaryFromEvent;
{
    if (!_date) {
        NSLog  (@"EVENT LACKS DATE");
        return nil;
    }
    if  (!_createdAt) {
        _createdAt= [NSDate date];
    }
    if  (!_updatedAt) {
        _updatedAt= [NSDate date];
    }
    
    NSMutableArray *userDictionaries= [NSMutableArray new];
    NSMutableArray *restaurantDictionaries= [NSMutableArray new];
    
//    if ( _restaurants) {
//        for (RestaurantObject* o  in  _restaurants) {
//            NSDictionary* d= [ RestaurantObject dictFromRestaurant: o];
//            if  ( d) {
//                [restaurantDictionaries addObject: d];
//            }
//        }
//    }
//    
//    if ( _users) {
//        for (UserObject* u  in  _users) {
//            NSDictionary* d= [ u dictionaryFromUser];
//            if  ( d) {
//                [userDictionaries addObject: d];
//            }
//        }
//    }
    
    return  @{
              @"event_id": @(_eventID),
               @"isComplete": @(_isComplete),
              @"event_type": @(_eventType),// 0= user, 1=  other
              @"total_price": @(_totalPrice),
              @"event_date": _date,
              @"created_at":_createdAt,
              @"updated_at":_updatedAt,
              @"review_site":_reviewSite?:  @"",
              @"friend_recommendation_age":  @(_friendRecommendationAge),
              @"num_people":@(_numberOfPeople),
              @"comment":_comment ?:  @"",
              @"special_event":_specialEvent ?:  @"",
              @"keywords": _keywords?:  @[],
              @"users":userDictionaries,
              @"restaurants":restaurantDictionaries,
              
              };
}

@end
