//
//  ListObject.m
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListObject.h"
#import "OOAPI.h"
#import "Common.h"

NSString *const kKeyListID = @"list_id";
NSString *const kKeyListUserIDs = @"user_ids";;
NSString *const kKeyListName = @"name";
NSString *const kKeyListType = @"type";
NSString *const kKeyListMediaItem = @"media_item";
NSString *const kKeyListNumRestaurants = @"num_restaurants";

BOOL isListObject (id  object)
{
    return [object isKindOfClass:[ListObject class]];
}

@implementation ListObject

-(instancetype)init {
    if (self) {
        self.listDisplayType = KListDisplayTypeStrip;
        _type = kListTypeSystem;
    }
    return self;
}

+ (ListObject *)listFromDict:(NSDictionary *)dict {
    if (!dict  || ![dict isKindOfClass:[NSDictionary class ]]) {
        return nil;
    }
    
    //NSLog(@"dict=%@", dict);
    
    ListObject *list = [[ListObject alloc] init];
    list.listID = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyListID]);
    if (!list.listID) return nil;
    
    if ([dict objectForKey:kKeyListUserIDs] && ![[dict objectForKey:kKeyListUserIDs] isKindOfClass:[NSNull class]]) {
        NSMutableArray *uids = [NSMutableArray array];
        for (id uID in [dict objectForKey:kKeyListUserIDs]) {
            [uids addObject:[NSNumber numberWithUnsignedInteger:parseUnsignedIntegerOrNullFromServer(uID)]];
        }
//        list.userIDs = [dict objectForKey:kKeyListUserIDs];
        list.userIDs = uids;
    }

    list.name = [[dict objectForKey:kKeyListName] isKindOfClass:[NSNull class]] ? @"" : [dict objectForKey:kKeyListName];
    list.type = (ListType)[[dict objectForKey:kKeyListType] integerValue];
    list.numRestaurants = (NSUInteger)[dict[kKeyListNumRestaurants] integerValue];
    NSDictionary *mediaItem = [[dict objectForKey:kKeyListMediaItem] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyListMediaItem];
    if (mediaItem && ![mediaItem isKindOfClass:[NSNull class]]) {
        list.mediaItem = [MediaItemObject mediaItemFromDict:mediaItem];
    }
    return list;
}

+ (NSDictionary *)dictFromList:(ListObject *)list {
    return @{
             kKeyListID : [NSString stringWithFormat:@"%ld",(long) list.listID] ? : @"",
             kKeyListName : list.name?: @"",
             kKeyListType : [NSString stringWithFormat:@"%ld",(long) list.type] ?: @""
             };
}

- (BOOL)isListOwner:(NSUInteger)userID {
    __block BOOL result = NO;
    
    [_userIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger theID = [obj unsignedIntegerValue];
        if (theID == userID) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
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

- (void)removeVenue:(RestaurantObject *)venue completionBlock:(void (^)(BOOL))completionBlock;
{
    if (!venue) {
        if  (completionBlock) completionBlock (NO);
        return;
    }
    __weak  ListObject *weakSelf = self;
    [OOAPI removeVenue: venue
              fromList: self
               success:^(id response) {
                   NSLog (@"Venue removed from list.");
                   weakSelf.numRestaurants--;
                   [weakSelf.venues removeObject: venue];
                   if  (completionBlock) completionBlock (YES);
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                   NSLog  (@"Failed to remove venue from list %@", error);
                   if  (completionBlock) completionBlock (NO);
               }];
}

- (void)addVenue:(RestaurantObject *)venue completionBlock:(void (^)(BOOL))completionBlock
{
    if (!venue) {
        if  (completionBlock) completionBlock (NO);
        return;
    }
    
    if (!_venues)
        _venues = [NSMutableArray new];
    
    @synchronized(_venues)  {
        if (![_venues containsObject: venue]) {
            [_venues addObject: venue];
            [OOAPI addRestaurants: @[venue] toList:_listID
                        success:^(id response) {
                            NSLog (@"Venue added to list");
                            self.numRestaurants++;
                            if  (completionBlock) completionBlock (YES);
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog  (@"Failed to add venue to list %@",error);
                            [_venues removeObject: venue];
                            if  (completionBlock) completionBlock (NO);
                        }];
        }
    }
}

- (NSString *)listName {
    if (_type == kListTypePlaceIveBeen) {
        UserObject *user = [Settings sharedInstance].userObject;
        if (_userIDs && [_userIDs count]) {
            
            if ([[_userIDs objectAtIndex:0] isKindOfClass:[NSNumber class]] &&
                (user.userID == [[_userIDs objectAtIndex:0] unsignedIntegerValue])) {
                return @"Places I've Been";
            } else {
                return @"Places They Went";
            }
        }
    } return _name;
}

@end
