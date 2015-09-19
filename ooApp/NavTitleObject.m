//
//  NavTitleObject.m
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "NavTitleObject.h"

@interface NavTitleObject ()

@end

@implementation NavTitleObject

- (id)initWithHeader:(NSString *)header subHeader:(NSString *)subHeader {
    if (self = [super init]) {
        self.header = header;
        self.subheader = subHeader;
    }
    return self;
}

@end
