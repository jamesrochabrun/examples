//
//  MenuObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMenuItemPlay;
extern NSString *const kMenuItemFeed;
extern NSString *const kMenuItemFoodFeed;
extern NSString *const kMenuItemConnect;
extern NSString *const kMenuItemProfile;
extern NSString *const kMenuItemDiscover;
extern NSString *const kMenuItemWhatsNew;
extern NSString *const kMenuItemEat;
extern NSString *const kMenuItemMeet;
extern NSString *const kMenuItemSettings;
extern NSString *const kMenuItemSearch;
extern NSString *const kMenuItemDiagnostic;

@interface MenuObject : NSObject

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) SEL selector;

@end
