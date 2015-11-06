//
//  MediaItemObject.h
//  ooApp
//
//  Created by Anuj Gujar on 9/4/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kMediaItemTypeOomami = 1,
    kMediaItemTypeGoogle = 2
} MediaItemType;

extern NSString *const kKeyMediaItemReference;
extern NSString *const kKeyMediaItemType;
extern NSString *const kKeyMediaItemSource;
extern NSString *const kKeyMediaItemID;
extern NSString *const kKeyMediaItemHeight;
extern NSString *const kKeyMediaItemWidth;
extern NSString *const kKeyMediaItemURL;

@interface MediaItemObject : NSObject

@property (nonatomic, strong) NSString *reference;
@property (nonatomic) NSUInteger type;
@property (nonatomic) NSUInteger source;
@property (nonatomic, strong) NSString *mediaItemId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

+ (MediaItemObject *)mediaItemFromDict:(NSDictionary *)dict;

@end
