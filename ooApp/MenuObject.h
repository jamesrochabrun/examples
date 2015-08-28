//
//  MenuObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMenutItemPlay;
extern NSString *const kMenutItemConnect;
extern NSString *const kMenutItemProfile;
extern NSString *const kMenutItemDiscover;
extern NSString *const kMenutItemEat;
extern NSString *const kMenutItemMeet;

@interface MenuObject : NSObject

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) SEL selector;

@end
