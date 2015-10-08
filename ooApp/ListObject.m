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
NSString *const kKeyListName = @"name";
NSString *const kKeyListType = @"type";

@implementation ListObject

-(instancetype)init {
    if (self) {
        self.listDisplayType = KListDisplayTypeStrip;
        _type = kOOAPIListTypeSystem;
    }
    return self;
}

+ (ListObject *)listFromDict:(NSDictionary *)dict {
    ListObject *list = [[ListObject alloc] init];
    list.listID = [dict objectForKey:kKeyListID];
    list.name = [dict objectForKey:kKeyListName];
    list.type = [[dict objectForKey:kKeyListType] integerValue];
    return list;
}

+ (NSDictionary *)dictFromList:(ListObject *)list {
    return @{
             kKeyListID : list.listID ? : @"",
             kKeyListName : list.name?: @"",
             kKeyListType : [NSString stringWithFormat:@"%ld",(long) list.type] ?: @""
             };
}

@end
