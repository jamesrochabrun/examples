//
//  GroupObject.m
//  ooApp
//
//  Created by Anuj Gujar on 7/31/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "GroupObject.h"

@implementation GroupObject

static  NSString *const kKeyCreatedAt = @"created_at";
static NSString *const kKeyUpdatedAt = @"updated_at";
static NSString *const kKeyName = @"name";
static NSString *const kKeyGroupID = @"group_id";

//{
//    "created_at" = "2015-10-09T00:55:26.000Z";
//    "group_id" = 26;
//    name = "My awesome Group";
//    "updated_at" = "2015-10-09T00:55:26.000Z";
//}

+ (GroupObject*) groupFromDictionary: (NSDictionary*)dictionary;
{
    GroupObject* g= [[GroupObject alloc] init];
    
    g.groupID= [dictionary[ kKeyGroupID] intValue];
    g.name= parseStringOrNullFromServer ( dictionary[ kKeyName]);
    g.createdAt= parseUTCDateFromServer ( dictionary[ kKeyCreatedAt]);
    g.updatedAt= parseUTCDateFromServer( dictionary[ kKeyUpdatedAt]);
    
    //        g.eventCoverImageURL = parseStringOrNullFromServer ( kKeyMediaURL);
    
    return g;
}

@end
