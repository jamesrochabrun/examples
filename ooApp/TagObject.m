//
//  TagObject.m
//  ooApp
//
//  Created by Anuj Gujar on 11/21/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "TagObject.h"

NSString *const kKeyTagTagID = @"tag_id";
NSString *const kKeyTagName = @"name";
NSString *const kKeyTagType = @"type";

@implementation TagObject

+ (TagObject *)tagFromDict:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    TagObject *tag = [[TagObject alloc] init];
    
    tag.name = parseStringOrNullFromServer([dict objectForKey:kKeyTagName]);
    tag.tagID = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyTagTagID]);
    tag.type = (TagType)parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyTagType]);
    
    return tag;
}

@end
