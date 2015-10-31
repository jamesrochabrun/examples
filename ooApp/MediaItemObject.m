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
NSString *const kKeyMediaItemID = @"media_item_id";
NSString *const kKeyMediaItemHeight = @"height";
NSString *const kKeyMediaItemWidth = @"width";

@implementation MediaItemObject

+ (MediaItemObject *)mediaItemFromDict:(NSDictionary *)dict {
    if (! [dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    MediaItemObject *mio = [[MediaItemObject alloc] init];
    mio.mediaItemId = [dict objectForKey:kKeyMediaItemID];
    mio.type = [dict objectForKey:kKeyMediaItemType];
    mio.reference = [dict objectForKey:kKeyMediaItemReference];
    mio.height = [dict[kKeyMediaItemHeight] isKindOfClass:[NSNull class]] ? 0 : [dict[kKeyMediaItemHeight] floatValue];
    mio.width = [dict[kKeyMediaItemWidth] isKindOfClass:[NSNull class]] ? 0 : [dict[kKeyMediaItemWidth] floatValue]; 
    return mio;
}

@end
