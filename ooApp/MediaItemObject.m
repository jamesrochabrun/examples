//
//  MediaItemObject.m
//  ooApp
//
//  Created by Anuj Gujar on 9/4/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "MediaItemObject.h"

NSString *const kKeyMediaItemReference = @"reference";
NSString *const kKeyMediaItemType = @"type";
NSString *const kKeyMediaItemSource = @"source";
NSString *const kKeyMediaItemID = @"media_item_id";
NSString *const kKeyMediaItemHeight = @"height";
NSString *const kKeyMediaItemWidth = @"width";
NSString *const kKeyMediaItemURL = @"url";
NSString *const kKeyMediaItemSourceUserID = @"source_user_id";
NSString *const kKeyMediaItemRestaurantID = @"restaurant_id";
NSString *const kKeyMediaItemCaption = @"caption";

@implementation MediaItemObject

+ (MediaItemObject *)mediaItemFromDict:(NSDictionary *)dict {
    if (! [dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
//    NSLog(@"media_item: %@", dict);
    MediaItemObject *mio = [[MediaItemObject alloc] init];
    mio.mediaItemId = [[dict objectForKey:kKeyMediaItemID] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyMediaItemID] unsignedIntegerValue];
    mio.type = [dict[kKeyMediaItemType] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyMediaItemType] unsignedIntegerValue];
    mio.source = [dict[kKeyMediaItemSource] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyMediaItemSource] unsignedIntegerValue];
    
    mio.reference = parseStringOrNullFromServer ( dict [kKeyMediaItemReference]) ;
    mio.url = parseStringOrNullFromServer ( dict [kKeyMediaItemURL]) ;
    
    mio.height = [dict[kKeyMediaItemHeight] isKindOfClass:[NSNull class]] ? 0 : [dict[kKeyMediaItemHeight] floatValue];
    mio.width = [dict[kKeyMediaItemWidth] isKindOfClass:[NSNull class]] ? 0 : [dict[kKeyMediaItemWidth] floatValue]; 
    mio.caption = [[dict objectForKey:kKeyMediaItemCaption] isKindOfClass:[NSNull class]] ? @"" : [dict objectForKey:kKeyMediaItemCaption];
    mio.sourceUserID = [dict[kKeyMediaItemSourceUserID] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyMediaItemSourceUserID] unsignedIntegerValue];
    
    mio.restaurantID = parseUnsignedIntegerOrNullFromServer(dict [kKeyMediaItemRestaurantID ]);
    return mio;
}

- (NSDictionary*) dictionaryOfMediaItem;
{
    return @{
             kKeyMediaItemReference: self.reference ?:  @"",
             kKeyMediaItemID: self.mediaItemId ?  @(self.mediaItemId) :  @(0U),
             kKeyMediaItemType: self.type ? @(self.type) :  @(0U),
             kKeyMediaItemSource: self.source ?  @(self.source):  @(0U),
             kKeyMediaItemHeight: self.height ?  @(self.height):  @(0.f),
             kKeyMediaItemWidth: self.width ?  @(self.width):  @(0.f),
             kKeyMediaItemURL: self.url ?:  @"",
             kKeyMediaItemSourceUserID: self.sourceUserID ?  @(self.sourceUserID): @(0U),
             kKeyMediaItemRestaurantID: self.restaurantID ?  @(self.restaurantID): @(0U),
             };
}

@end






