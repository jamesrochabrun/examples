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

@implementation MediaItemObject

+ (MediaItemObject *)mediaItemFromDict:(NSDictionary *)dict {
    if (! [dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    MediaItemObject *mio = [[MediaItemObject alloc] init];
    mio.mediaItemId = [dict objectForKey:kKeyMediaItemID];
    mio.type = [dict[kKeyMediaItemType] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyMediaItemType] unsignedIntegerValue];
    mio.source = [dict[kKeyMediaItemSource] isKindOfClass:[NSNull class]] ? 0 : [[dict objectForKey:kKeyMediaItemSource] unsignedIntegerValue];
    mio.reference = [dict objectForKey:kKeyMediaItemReference];
    mio.height = [dict[kKeyMediaItemHeight] isKindOfClass:[NSNull class]] ? 0 : [dict[kKeyMediaItemHeight] floatValue];
    mio.width = [dict[kKeyMediaItemWidth] isKindOfClass:[NSNull class]] ? 0 : [dict[kKeyMediaItemWidth] floatValue]; 
    mio.url = [[dict objectForKey:kKeyMediaItemURL] isKindOfClass:[NSNull class]] ? nil : [dict objectForKey:kKeyMediaItemURL];
    return mio;
}

@end
