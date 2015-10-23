//
//  GroupObject.h
//  ooApp
//
//  Created by Anuj Gujar on 7/31/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupObject : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSUInteger groupID;
@property (nonatomic,strong) NSDate *createdAt;
@property (nonatomic,strong) NSDate *updatedAt;

+ (GroupObject*) groupFromDictionary: (NSDictionary*)dictionary;

@end
