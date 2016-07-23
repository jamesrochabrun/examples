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
extern NSString *const kKeyMediaItemSourceUserID;
extern NSString *const kKeyMediaItemCaption;
extern NSString *const kKeyMediaItemIsFood;
extern NSString *const kKeyMediaItemRestaurantID;
extern NSString *const kKeyMediaItemYumCount;
extern NSString *const kKeyMediaItemSourceUsername;
extern NSString *const kKeyMediaItemIsYummedByUser;
extern NSString *const kKeyMediaItemCreatedAt;


@interface MediaItemObject : NSObject

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic) NSUInteger type;
@property (nonatomic) NSUInteger source;
@property (nonatomic) NSUInteger mediaItemId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) NSUInteger sourceUserID;
@property (nonatomic) NSUInteger restaurantID; // if given.
@property (nonatomic) BOOL isFood;
@property (nonatomic) BOOL isUserYummed;
@property (nonatomic) NSUInteger yumCount;
@property (nonatomic, strong) NSString *sourceUsername;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *updatedAt;

+ (MediaItemObject *)mediaItemFromDict:(NSDictionary *)dict;
- (NSDictionary*) dictionaryOfMediaItem;

@end
