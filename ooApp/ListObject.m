//
//  ListObject.m
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListObject.h"
#import "OOAPI.h"

NSString *const kKeyListID = @"list_id";
NSString *const kKeyListUserIDs = @"user_ids";;
NSString *const kKeyListName = @"name";
NSString *const kKeyListType = @"type";
NSString *const kKeyListMediaItem = @"media_item";
NSString *const kKeyListNumRestaurants = @"num_restaurants";

@implementation ListObject

-(instancetype)init {
    if (self) {
        self.listDisplayType = KListDisplayTypeStrip;
        _type = kListTypeSystem;
    }
    return self;
}

+ (ListObject *)listFromDict:(NSDictionary *)dict {
    ListObject *list = [[ListObject alloc] init];
    list.listID = [[dict objectForKey:kKeyListID] unsignedIntegerValue];
    
    if ([dict objectForKey:kKeyListUserIDs] && ![[dict objectForKey:kKeyListUserIDs] isKindOfClass:[NSNull class]]) {
        list.userIDs = [dict objectForKey:kKeyListUserIDs];
    }

    list.name = [[dict objectForKey:kKeyListName] isKindOfClass:[NSNull class]] ? @"" : [dict objectForKey:kKeyListName];
    list.type = (ListType)[[dict objectForKey:kKeyListType] unsignedIntegerValue];
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

@end
