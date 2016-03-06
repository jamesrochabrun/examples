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
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"list CVFL: section=%ld row=%ld", (long)indexPath.section, (long)indexPath.row);
    UICollectionViewLayoutAttributes* currentItemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    NSInteger numberOfItemsPerLine = floor([self collectionViewContentSize].width / [self itemSize].width);
    
    if (indexPath.item % numberOfItemsPerLine != 0)
    {
        NSInteger cellIndexInLine = (indexPath.item % numberOfItemsPerLine);
        
        CGRect itemFrame = [currentItemAttributes frame];
        itemFrame.origin.x = ([self itemSize].width * cellIndexInLine) + ([self minimumInteritemSpacing] * cellIndexInLine);
        currentItemAttributes.frame = itemFrame;
    }
    
    return currentItemAttributes;
}
@end
