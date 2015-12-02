//
//  FeedObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
#import "MediaItemObject.h"

@interface FeedObject: NSObject

// NOTE: A feed item is like a sentence, with subject, verb and object.

@property (nonatomic, assign) NSUInteger subjectID;
@property (nonatomic, assign) BOOL subjectIsEvent;
@property (nonatomic, strong) NSString* subjectName;
@property (nonatomic, assign) NSObject *subject; // UserObject or EventObject.

@property (nonatomic, assign) NSUInteger objectID; 
@property (nonatomic, assign) NSObject *object; // UserObject, EventObject, RestaurantObject, or ListObject.
@property (nonatomic, strong) NSString* objectName;

enum  {
    FEED_OBJECT_TYPE_USER= 'u',
    FEED_OBJECT_TYPE_EVENT= 'e',
    FEED_OBJECT_TYPE_LIST= 'l',
    FEED_OBJECT_TYPE_RESTAURANT= 'r',
};
@property (nonatomic, assign) char subjectType; // used only temporarily
@property (nonatomic, assign) char objectType; // used only temporarily

@property (nonatomic, strong) NSString* verb;
@property (nonatomic, strong) NSString* translatedMessage;
@property (nonatomic, strong) NSString* parameters;
@property (nonatomic, strong) NSString* action;
@property (nonatomic, strong) MediaItemObject *mediaItem;
@property (nonatomic, strong) UIImage *loadedImage;
@property (nonatomic,strong) NSDate* publishedAt;
@property (nonatomic,assign) BOOL isNotification;

// NOTE: Notifications require action, updates require only attention.

+ (instancetype) feedObjectFromDictionary:(NSDictionary *)dictionary;

@end

