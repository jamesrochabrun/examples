//
//  TagObject.h
//  ooApp
//
//  Created by Anuj Gujar on 11/21/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyTagTagID;
extern NSString *const kKeyTagName;
extern NSString *const kKeyTagType;

typedef enum {
    kTagTypeSelf = 1,
} TagType;

@interface TagObject : NSObject

@property (nonatomic) NSUInteger tagID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) TagType type;

+ (TagObject *)tagFromDict:(NSDictionary *)dict;

@end
