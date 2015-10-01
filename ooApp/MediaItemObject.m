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

@implementation MediaItemObject

+ (MediaItemObject *)mediaItemFromDict:(NSDictionary *)dict {
    MediaItemObject *iro = [[MediaItemObject alloc] init];
    iro.mediaItemId = [dict objectForKey:kKeyMediaItemID];
    iro.type = [dict objectForKey:kKeyMediaItemType];
    iro.reference = [dict objectForKey:kKeyMediaItemReference];
    return iro;
}

@end
