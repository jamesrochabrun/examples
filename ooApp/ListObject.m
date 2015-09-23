//
//  ListObject.m
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListObject.h"

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
    
    return list;
}

+ (NSDictionary *)dictFromList:(ListObject *)list {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    return dict;
}

@end
