//
//  EventObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/13/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventObject : NSObject

@property (nonatomic) NSInteger eventID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *restaurants;

@end
