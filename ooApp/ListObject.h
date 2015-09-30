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

#import <Foundation/Foundation.h>

@interface ListObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *listID;
@property (nonatomic, assign) int  identifier;
@property (nonatomic) ListDisplayType listDisplayType;

+ (ListObject *)listFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromList:(ListObject *)list;

@end
