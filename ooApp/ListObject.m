//
//  ListObject.m
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListObject.h"

NSString *const kKeyListName = @"name";
NSString *const kKeyListType = @"type";

@implementation ListObject

-(instancetype)init {
    if (self) {
        _identifier= -1;
        self.listType = KListTypeStrip;
    }
    return self;
}

+ (ListObject *)listFromDict:(NSDictionary *)dict {
    ListObject *list = [[ListObject alloc] init];
    list.name = [dict objectForKey:kKeyListName];
    list.type = [dict objectForKey:kKeyListType];
    return list;
}

+ (NSDictionary *)dictFromList:(ListObject *)list {
    return @{
             kKeyListName : list.name?: @"",
             kKeyListType : list.type ?: @""
             };
}

@end
