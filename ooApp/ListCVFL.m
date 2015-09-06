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
        self.sectionInset = UIEdgeInsetsZero;// UIEdgeInsetsMake(kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter);
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [super layoutAttributesForElementsInRect:rect];
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 0;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

@end
