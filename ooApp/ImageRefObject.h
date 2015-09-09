//
//  ImageRefObject.h
//  ooApp
//
//  Created by Anuj Gujar on 9/4/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageRefObject : NSObject

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) NSUInteger height;
@property (nonatomic) NSUInteger width;

+ (ImageRefObject *)imageRefFromDict:(NSDictionary *)dict;

@end
