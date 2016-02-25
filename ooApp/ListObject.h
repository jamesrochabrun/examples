//
//  ListObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

@class RestaurantObject;

typedef enum {
    kListDisplayTypeFeatured,
    KListDisplayTypeStrip,
    KListDisplayTypeCount
} ListDisplayType;

typedef enum {
    kListTypeSystem = 1,
    kListTypeUser = 2,
    kListTypeFavorites = 3,
    kListTypeToTry = 4,
    kListTypeNotNow = 5,
    kListTypePlaceIveBeen = 6,
    kListTypeYumList = 7,
    kListTypeTrending = 2000,
    kListTypePopular = 2001,
    kListTypeJustForYou = 2002
} ListType;

extern NSString *const kKeyListID;
extern NSString *const kKeyListUserIDs;
extern NSString *const kKeyListName;
extern NSString *const kKeyListType;
extern NSString *const kKeyListMediaItem;
extern NSString *const kKeyListNumRestaurants;


#import <Foundation/Foundation.h>
#import "MediaItemObject.h"

@interface ListObject : NSObject

@property (nonatomic) NSUInteger listID;
@property (nonatomic, strong) NSArray *userIDs;
@property (nonatomic,strong) NSMutableArray *venues;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) ListType type;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic) NSUInteger numRestaurants;
@property (nonatomic, strong) MediaItemObject *mediaItem;
@property (nonatomic) ListDisplayType listDisplayType;

+ (ListObject *)listFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromList:(ListObject *)list;
- (BOOL)isListOwner:(NSUInteger)userID;
- (void)removeVenue:(RestaurantObject *)venue completionBlock:(void (^)(BOOL))completionBlock;
- (BOOL)alreadyHasVenue:(RestaurantObject *)venue;
- (void)addVenue:(RestaurantObject *)venue completionBlock:(void (^)(BOOL))completionBlock;

@end

extern BOOL isListObject (id  object);
