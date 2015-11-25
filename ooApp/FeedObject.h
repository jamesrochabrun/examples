//
//  FeedObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
#import <time.h>
#import "MediaItemObject.h"

@interface FeedObject: NSObject

@property (nonatomic, assign) NSUInteger feedID; 
@property (nonatomic, assign) NSUInteger publisherID; // user
@property (nonatomic, strong) NSString* publisherUsername;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* translatedMessage;
@property (nonatomic, strong) NSString* parameters;
@property (nonatomic, strong) NSString* action;
@property (nonatomic, strong) MediaItemObject *mediaItem;
@property (nonatomic, strong) UIImage *loadedImage;
@property (nonatomic,strong) NSDate* publishedAt;
@property (nonatomic,assign) BOOL isNotification;

+ (instancetype) feedObjectFromDictionary:(NSDictionary *)dictionary;

@end

