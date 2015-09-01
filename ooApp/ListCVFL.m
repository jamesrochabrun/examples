//
//  ListCVFL.m
//  ooApp
//
//  Created by Anuj Gujar on 8/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ListCVFL.h"

@implementation ListCVFL

- (id)init
{
    self = [super init];
    if (self) {
        self.sectionInset = UIEdgeInsetsMake(kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter);
    }
    return self;
}


@end
