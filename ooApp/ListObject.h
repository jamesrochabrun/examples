//
//  ListObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

typedef enum {
    kListDisplayTypeFeatured,
    KListDisplayTypeStrip,
    KListDisplayTypeCount
} ListDisplayType;

typedef enum {
    kListTypeSystem = 1,
    kListTypeUser = 2,
    kListTypeFavorites = 3,
    kListTypeToTry = 4
} ListType;

extern NSString *const kKeyListID;
extern NSString *const kKeyListName;
extern NSString *const kKeyListType;
extern NSString *const kKeyListMediaItem;
extern NSString *const kKeyListNumRestaurants;


#import <Foundation/Foundation.h>
#import "MediaItemObject.h"

@interface ListObject : NSObject

@property (nonatomic) NSUInteger listID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic) NSUInteger numRestaurants;
@property (nonatomic, strong) MediaItemObject *mediaItem;
@property (nonatomic) ListDisplayType listDisplayType;

+ (ListObject *)listFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromList:(ListObject *)list;

@end
