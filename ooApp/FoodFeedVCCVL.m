//
//  FoodFeedVCCVL.m
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "FoodFeedVCCVL.h"
#import "OOStripHeader.h"

@interface FoodFeedVCCVL ()
@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) NSMutableArray *sectionAttributes;
@end

@implementation FoodFeedVCCVL

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
        
        NSLog(@"section:%ld items:%lu yOffset=%f", (unsigned long)section, [self.collectionView numberOfItemsInSection:section], yOffset);
    
        numberOfColumnsInRow = [_delegate collectionView:self.collectionView layout:self numberOfColumnsInSection:section];// kFoodFeedNumColumnsForMediaItems;
        
        itemSize = CGSizeMake(floorf((width(self.collectionView) - (numberOfColumnsInRow-1) - 2*kGeomSpaceEdge)/numberOfColumnsInRow), 0);
        xOffset = kGeomSpaceEdge;//(width(self.collectionView) - numberOfColumnsInRow*itemSize.width - kGeomInterImageGap)/2;
        yOffset += kGeomSpaceEdge;
        
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
                yOffset = itemAboveAttributes.frame.origin.y+itemAboveAttributes.frame.size.height + kGeomInterImageGap;
            }
                
            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));
            if (section == kFoodFeedSectionTypeMediaItems) {
                NSLog(@"attribute frame=%@, column=%lu", NSStringFromCGRect(attributes.frame), (unsigned long)column);
            }
            [itemAttributes addObject:attributes];
            
            if ([lastRowAttributes count] > index%numberOfColumnsInRow &&
                [lastRowAttributes objectAtIndex:index%numberOfColumnsInRow]) {
                [lastRowAttributes replaceObjectAtIndex:index%numberOfColumnsInRow withObject:attributes];
            } else {
                [lastRowAttributes addObject:attributes];
            }
            
            xOffset = xOffset+itemSize.width + kGeomInterImageGap;
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

        NSLog(@"after section:%ld items:%ld yOffset=%f numColumns=%ld", section, [self.collectionView numberOfItemsInSection:section], yOffset, numberOfColumnsInRow);
    }
    
    // Get the last item to calculate the total height of the content
    NSArray *lastSectionAttributes = [_sectionAttributes lastObject];
    
    UICollectionViewLayoutAttributes *a;
    CGFloat y = 0, lastY;
    for (int i=0; i<kFoodFeedNumColumnsForMediaItems; i++) {
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
