//
//  OptionsVCCVL.m
//  ooApp
//
//  Created by Anuj Gujar on 12/3/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OptionsVCCVL.h"

@interface OptionsVCCVL ()
@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) NSMutableArray *sectionAttributes;
@end

@implementation OptionsVCCVL

- (CGSize)collectionViewContentSize {
    return _contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributesArray = [NSMutableArray array];
    
    NSArray *filteredArray;
    for (NSArray *aa in _sectionAttributes) {
        filteredArray = [aa filteredArrayUsingPredicate:
                         [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
            CGRectIntersectsRect(rect, [evaluatedObject frame]);
            return YES;
        }]];
        [attributesArray addObjectsFromArray:aa];
    }
    
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[_sectionAttributes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (void)prepareLayout {
    NSUInteger column = 0;    // Current column inside row
    
    [self setSectionAttributes:nil];
    _sectionAttributes = [[NSMutableArray alloc] init];
    
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    
    CGFloat contentWidth = 0.0;         // Used to determine the contentSize
    CGFloat contentHeight = 0.0;        // Used to determine the contentSize
    
    // We'll create a dynamic layout. Each row will have a random number of columns
    NSUInteger numberOfColumnsInRow;
    NSMutableArray *itemAttributes;
    CGSize itemSize;
    
    // Loop through all sections in the collectionview and set each item's attributes
    for (NSUInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        itemAttributes = [NSMutableArray array];
        [_sectionAttributes addObject:itemAttributes];
        column = 0;
        
        if (section == kOptionsSectionTypeTags && [self.collectionView numberOfItemsInSection:section]) {
            NSLog(@"section:%ld items:%ld yOffset=%f", (long)section, (long)[self.collectionView numberOfItemsInSection:section], yOffset);
            numberOfColumnsInRow = kNumColumnsForTags;
            itemSize = CGSizeMake(floorf((width(self.collectionView) - (numberOfColumnsInRow-1) - 2*kGeomSpaceEdge)/numberOfColumnsInRow), 0);
            xOffset = kGeomSpaceEdge;
            UICollectionViewLayoutAttributes *suppattributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"header" withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            suppattributes.frame = CGRectIntegral(CGRectMake(0, yOffset, width(self.collectionView), 40));
            yOffset += 40;
            [itemAttributes addObject:suppattributes];
        } else if (section == kOptionsSectionTypePrice && [self.collectionView numberOfItemsInSection:section]) {
            NSLog(@"section:%ld items:%ld yOffset=%f", (unsigned long)section, (long)[self.collectionView numberOfItemsInSection:section], yOffset);
            numberOfColumnsInRow = 1;
            itemSize = CGSizeMake(width(self.collectionView)/numberOfColumnsInRow -  2*kGeomSpaceEdge, 0);
            UICollectionViewLayoutAttributes *suppattributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"header" withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            suppattributes.frame = CGRectIntegral(CGRectMake(0, yOffset, width(self.collectionView), 40));
            xOffset = kGeomSpaceEdge;
            yOffset += 40;
            [itemAttributes addObject:suppattributes];
        } else if (section == kOptionsSectionTypeLocation && [self.collectionView numberOfItemsInSection:section]) {
            NSLog(@"section:%ld items:%ld yOffset=%f", (unsigned long)section, (long)[self.collectionView numberOfItemsInSection:section], yOffset);
            numberOfColumnsInRow = width(self.collectionView)/(50+kGeomSpaceEdge);
            itemSize = CGSizeMake(width(self.collectionView)/numberOfColumnsInRow -  2*kGeomSpaceEdge, 0);
            UICollectionViewLayoutAttributes *suppattributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:@"header" withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            suppattributes.frame = CGRectIntegral(CGRectMake(0, yOffset, width(self.collectionView), 40));
            xOffset = kGeomSpaceEdge;
            yOffset += 40;
            [itemAttributes addObject:suppattributes];
        } else {// if (section == kSectionTypeMain && [self.collectionView numberOfItemsInSection:section]) {
            NSLog(@"section:%ld items:%ld yOffset=%f", (unsigned long)section, (long)[self.collectionView numberOfItemsInSection:section], yOffset);
            numberOfColumnsInRow = 1;
            itemSize = CGSizeMake(width(self.collectionView)/numberOfColumnsInRow, 0);
            xOffset = 0;
        }
        
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        
        NSMutableArray *lastRowAttributes = [NSMutableArray array];
        
        // Loop through all items in section and calculate the UICollectionViewLayoutAttributes for each one
        for (NSUInteger index = 0; index < numberOfItems; index++)
        {
            //get the items height
            itemSize.height = [_delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
            
            // Create the actual UICollectionViewLayoutAttributes and add it to your array. We'll use this later in layoutAttributesForItemAtIndexPath:
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            if ([lastRowAttributes count] > index%numberOfColumnsInRow) {
                UICollectionViewLayoutAttributes *itemAboveAttributes = [lastRowAttributes objectAtIndex:index%numberOfColumnsInRow];
                yOffset = itemAboveAttributes.frame.origin.y+itemAboveAttributes.frame.size.height + 2;
            }
            
            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));
            if (section == kOptionsSectionTypeTags) {
                NSLog(@"attribute frame=%@, column=%lu", NSStringFromCGRect(attributes.frame), (unsigned long)column);
            }
            [itemAttributes addObject:attributes];
            
            if ([lastRowAttributes count] > index%numberOfColumnsInRow &&
                [lastRowAttributes objectAtIndex:index%numberOfColumnsInRow]) {
                [lastRowAttributes replaceObjectAtIndex:index%numberOfColumnsInRow withObject:attributes];
            } else {
                [lastRowAttributes addObject:attributes];
            }
            
            xOffset = xOffset+itemSize.width + 2;
            column++;
            
            // Create a new row if this was the last column
            if (column == numberOfColumnsInRow)
            {
                if (CGRectGetMaxX(attributes.frame) > contentWidth)
                    contentWidth = CGRectGetMaxX(attributes.frame);
                
                // Reset values
                column = 0;
                xOffset = kGeomSpaceEdge;
                yOffset += /*itemSize.height+*/kGeomSpaceEdge;
            }
        }
        //done with section, set the x & y offsets for the new section appropriately
        xOffset = kGeomSpaceEdge;
        UICollectionViewLayoutAttributes *theLastAttribute = [itemAttributes lastObject];
        if (theLastAttribute) {
            yOffset = /*yOffset +*/ theLastAttribute.frame.origin.y+theLastAttribute.frame.size.height + kGeomSpaceEdge;
        }
        
        NSLog(@"after section:%ld items:%ld yOffset=%f numColumns=%lu", (unsigned long)section, (long)[self.collectionView numberOfItemsInSection:section], yOffset, (unsigned long)numberOfColumnsInRow);
    }
    
    // Get the last item to calculate the total height of the content
    NSArray *lastSectionAttributes = [_sectionAttributes lastObject];
    
    UICollectionViewLayoutAttributes *a;
    CGFloat y = 0, lastY;
    for (int i=0; i<kNumColumnsForTags; i++) {
        NSInteger idx = [lastSectionAttributes count] - 1 - i;
        if (idx >= 0) {
            a = [lastSectionAttributes objectAtIndex:idx];
            lastY = a.frame.origin.y + a.frame.size.height;
            if (lastY > y) y = lastY;
        }
    }
    
    contentHeight = y + kGeomSpaceEdge;
    
    // Return this in collectionViewContentSize
    _contentSize = CGSizeMake(contentWidth, contentHeight);
}

@end
