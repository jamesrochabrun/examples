//
//  MediaItemObject.h
//  ooApp
//
//  Created by Anuj Gujar on 9/4/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

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
