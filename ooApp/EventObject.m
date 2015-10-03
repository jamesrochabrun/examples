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
        id price=dictionary[ @"total_price"];
        if  ([price isKindOfClass:[NSNumber class]] ) {
            e.totalPrice= [ ( (NSNumber*)price) doubleValue];
        }
        e.date= parseUTCDateFromServer ( dictionary[ @"event_date"]);
        e.name= parseStringOrNullFromServer ( dictionary[ @"name"]);
        e.friendRecommendationAge = parseNumberOrNullFromServer ( dictionary[ @"friend_recommendation_age"]);
        NSInteger nPeople = parseNumberOrNullFromServer ( dictionary[ @"num_people"]);
        e.reviewSite= parseStringOrNullFromServer ( dictionary[ @"review_site"]);
        e.specialEvent= parseStringOrNullFromServer ( dictionary[ @"special_event"]);
        e.comment=  parseStringOrNullFromServer(dictionary[ @"comment"]);
        e.createdAt= parseUTCDateFromServer ( dictionary[ @"created_at"]);
        e.updatedAt= parseUTCDateFromServer( dictionary[ @"updated_at"]);
        
        NSMutableArray* results=[NSMutableArray new];
        e.keywords= results;
        NSArray* array=dictionary[ @"keywords"];
        if (array) {
            for (NSString* string  in  array) {
                [results  addObject:string];
            }
        }
        
        results=[NSMutableArray new];
        e.users= results;
        array=dictionary[ @"users"];
        if (array) {
            for (NSDictionary* subdictionary  in  array) {
                UserObject *o= [UserObject userFromDict:subdictionary];
                if ( o) {
                    [ results addObject: o];
                }
            }
        }
        
        results=[NSMutableArray new];
        e.restaurants= results;
        array=dictionary[ @"restaurants"];
        if (array) {
            for (NSDictionary* subdictionary  in  array) {
                RestaurantObject *o= [RestaurantObject restaurantFromDict:subdictionary];
                if ( o) {
                    [ results addObject: o];
                }
            }
        }
        
    }
    return e;
}

@end
