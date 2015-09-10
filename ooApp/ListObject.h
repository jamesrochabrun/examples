//
//  ListObject.h
//  ooApp
//
//  Created by Anuj Gujar on 8/29/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

typedef enum {
    kListTypeFeatured,
    KListTypeStrip,
    KListTypeCount
} ListType;

#import <Foundation/Foundation.h>

@interface ListObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic) ListType listType;

@end
