//
//  ProfileVCCVLayout.m
//  ooApp
//
//  Created by Anuj Gujar on 10/12/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "ProfileVCCVLayout.h"
#import "OOStripHeader.h"

@interface ProfileVCCVLayout ()
@property (nonatomic) BOOL showingLists;
@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) NSMutableArray *sectionAttributes;
@end

@implementation ProfileVCCVLayout

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section=  indexPath.section;
    NSUInteger row=   indexPath.row;
    if ( section>= _sectionAttributes.count) {
        return nil;
    }
    NSArray*sectionArray= [_sectionAttributes objectAtIndex: section];
    if (  row>= sectionArray.count) {
        return nil;
    }
    return [ sectionArray objectAtIndex: row];
}

- (void)prepareLayout
{
    if  ( _showingLists || _thereAreNoItems) {
        [self prepareListsLayout];
    } else {
        [self preparePhotosLayout];
    }
}

- (void)prepareListsLayout
{
    NSUInteger column = 0;    // Current column inside row
    
    [self setSectionAttributes:nil];
    _sectionAttributes = [[NSMutableArray alloc] init];
    
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    
    CGFloat contentWidth = 0.0;         // Used to determine the contentSize
    CGFloat contentHeight = 0.0;        // Used to determine the contentSize
    
    NSUInteger numberOfColumnsInRow = 1;
    
    NSMutableArray *itemAttributes;
    CGSize itemSize;
    
    float allowableHorizontalSpace= round ((width(self.collectionView)));
    
    int hdrHeight = [self heightOfHeader];

    NSUInteger section = 0;
    
    NSLog(@"section:%ld items:%lu yOffset=%f", (long)section, (unsigned long)[self.collectionView numberOfItemsInSection:section], yOffset);
    
    itemAttributes = [NSMutableArray array];
    [_sectionAttributes addObject:itemAttributes];
    column = 0;
    
    itemSize = CGSizeMake( (width(self.collectionView)/numberOfColumnsInRow)-1, 0);
    UICollectionViewLayoutAttributes *suppattributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                      withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    suppattributes.frame = CGRectIntegral(CGRectMake(0, yOffset, width(self.collectionView),
                                                     hdrHeight));
    xOffset = 0;
    yOffset += hdrHeight;
    [itemAttributes addObject:suppattributes];
    
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    
    NSMutableArray *lastRowAttributes = [NSMutableArray array];
    
    // Loop through all items in section and calculate the UICollectionViewLayoutAttributes for each one
    for (NSUInteger index = 0; index < numberOfItems; index++)
    {
        //get the items height
        itemSize.height = [_delegate collectionView:self.collectionView layout:self
                           heightForItemAtIndexPath:[NSIndexPath
                                                     indexPathForItem:index
                                                     inSection:section]];
        
        // Create the actual UICollectionViewLayoutAttributes and add it to your array. We'll use this later in layoutAttributesForItemAtIndexPath:
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        if ([lastRowAttributes count] > index%numberOfColumnsInRow) {
            UICollectionViewLayoutAttributes *itemAboveAttributes = [lastRowAttributes objectAtIndex:index%numberOfColumnsInRow];
            yOffset = itemAboveAttributes.frame.origin.y+itemAboveAttributes.frame.size.height + 2;
        }
        
        attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, allowableHorizontalSpace, itemSize.height));
        
        NSLog(@"attribute frame=%@, column=%lu", NSStringFromCGRect(attributes.frame), (unsigned long)column);
        
        [itemAttributes addObject:attributes];
        
        if ([lastRowAttributes count] > index%numberOfColumnsInRow &&
            [lastRowAttributes objectAtIndex:index%numberOfColumnsInRow]) {
            [lastRowAttributes replaceObjectAtIndex:index%numberOfColumnsInRow withObject:attributes];
        } else {
            [lastRowAttributes addObject:attributes];
        }
        
        xOffset += allowableHorizontalSpace + kGeomInterImageGap;
        column++;
        
        // Create a new row if this was the last column
        if (column == numberOfColumnsInRow)
        {
            if (CGRectGetMaxX(attributes.frame) > contentWidth)
                contentWidth = CGRectGetMaxX(attributes.frame);
            
            // Reset values
            column = 0;
            xOffset = 0;
            yOffset += /*itemSize.height+*/kGeomInterImageGap;
        }
    }
    //done with section, set the x & y offsets for the new section appropriately
    xOffset = 0;
    UICollectionViewLayoutAttributes *theLastAttribute = [itemAttributes lastObject];
    if (theLastAttribute) {
        yOffset = theLastAttribute.frame.origin.y+theLastAttribute.frame.size.height + kGeomSpaceEdge;
    }
    
    NSLog(@"after section:%ld items:%ld yOffset=%f numColumns=%ld",(long) section,(long) [self.collectionView numberOfItemsInSection:section], yOffset, (long)numberOfColumnsInRow);
    
    // Get the last item to calculate the total height of the content
    NSArray *lastSectionAttributes = [_sectionAttributes lastObject];
    
    UICollectionViewLayoutAttributes *a;
    CGFloat y = 0, lastY;
    for (int i=0; i<numberOfColumnsInRow; i++) {
        NSInteger index = [lastSectionAttributes count] - 1 - i;
        if (index >= 0) {
            a = [lastSectionAttributes objectAtIndex: index];
            lastY = a.frame.origin.y + a.frame.size.height;
            if (lastY > y)
                y = lastY;
        }
    }
    
    contentHeight = y + kGeomSpaceEdge;
    
    _contentSize = CGSizeMake(contentWidth, contentHeight);
    NSLog (@"CV SIZE %@",NSStringFromCGSize(_contentSize));
}

- (float)heightOfHeader
{
    float hdrHeight = PROFILE_HEADERVIEW_BASE_HEIGHT;
    if (! _userIsSelf)
        hdrHeight += PROFILE_HEADERVIEW_FOLLOW_HEIGHT;
    if (_userIsFoodie &&  _foodieHasURL)
        hdrHeight += PROFILE_HEADERVIEW_URL_HEIGHT;
    if (_userHasSpecialties)
        hdrHeight += PROFILE_HEADERVIEW_SPECIALTIES_HEIGHT;
    return hdrHeight;
}

- (void)preparePhotosLayout
{
    NSUInteger column = 0;    // Current column inside row
    
    [self setSectionAttributes:nil];
    _sectionAttributes = [[NSMutableArray alloc] init];
    
    CGFloat xOffset = kGeomSpaceEdge;
    CGFloat yOffset = 0;
    
    CGFloat contentWidth = 0.0;         // Used to determine the contentSize
    CGFloat contentHeight = 0.0;        // Used to determine the contentSize
    
    NSMutableArray *itemAttributes;
    CGSize itemSize;
    
    float allowableHorizontalSpace=round( (width(self.collectionView)-2*kGeomSpaceEdge)/kProfileNumColumnsForMediaItemsPhone);
    if (kProfileNumColumnsForMediaItemsPhone>=2 ) {
        allowableHorizontalSpace -= kGeomInterImageGap;
    }
    
    int hdrHeight = [self heightOfHeader];

    NSUInteger section=0;
    NSLog(@"section:%ld items:%lu yOffset=%f", (long)section, (unsigned long)[self.collectionView numberOfItemsInSection:section], yOffset);
    
    itemAttributes = [NSMutableArray array];
    [_sectionAttributes addObject:itemAttributes];
    column = 0;
    
    itemSize = CGSizeMake(width(self.collectionView)/kProfileNumColumnsForMediaItemsPhone-1, 0);
    UICollectionViewLayoutAttributes *suppattributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                      withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    suppattributes.frame = CGRectIntegral(CGRectMake(0, yOffset, width(self.collectionView), hdrHeight));
    xOffset = kGeomSpaceEdge;
    yOffset += hdrHeight  + kGeomSpaceEdge;
    [itemAttributes addObject:suppattributes];
    
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    
    NSMutableArray *lastRowAttributes = [NSMutableArray array];
    
    // Loop through all items in section and calculate the UICollectionViewLayoutAttributes for each one
    for (NSUInteger index = 0; index < numberOfItems; index++)
    {
        //get the items height
        itemSize.height = [_delegate collectionView:self.collectionView layout:self
                           heightForItemAtIndexPath:[NSIndexPath
                                                     indexPathForItem:index
                                                     inSection:section]];
        
        // Create the actual UICollectionViewLayoutAttributes and add it to your array. We'll use this later in layoutAttributesForItemAtIndexPath:
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        if ([lastRowAttributes count] > index%kProfileNumColumnsForMediaItemsPhone) {
            UICollectionViewLayoutAttributes *itemAboveAttributes = [lastRowAttributes objectAtIndex:index%kProfileNumColumnsForMediaItemsPhone];
            yOffset = itemAboveAttributes.frame.origin.y+itemAboveAttributes.frame.size.height + 2;
        }
        
        attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, allowableHorizontalSpace, itemSize.height));
        
        NSLog(@"attribute frame=%@, column=%lu", NSStringFromCGRect(attributes.frame), (unsigned long)column);
        
        [itemAttributes addObject:attributes];
        
        if ([lastRowAttributes count] > index%kProfileNumColumnsForMediaItemsPhone &&
            [lastRowAttributes objectAtIndex:index%kProfileNumColumnsForMediaItemsPhone]) {
            [lastRowAttributes replaceObjectAtIndex:index%kProfileNumColumnsForMediaItemsPhone withObject:attributes];
        } else {
            [lastRowAttributes addObject:attributes];
        }
        
        xOffset += allowableHorizontalSpace + kGeomInterImageGap;
        column++;
        
        if (CGRectGetMaxX(attributes.frame) > contentWidth)
            contentWidth = CGRectGetMaxX(attributes.frame);
        
        // Create a new row if this was the last column
        if (column == kProfileNumColumnsForMediaItemsPhone)
        {
            // Reset values
            column = 0;
            xOffset = kGeomSpaceEdge;
            yOffset += /*itemSize.height+*/kGeomInterImageGap;
        }
    }
    //done with section, set the x & y offsets for the new section appropriately
    xOffset = 0;
    UICollectionViewLayoutAttributes *theLastAttribute = [itemAttributes lastObject];
    if (theLastAttribute) {
        yOffset = theLastAttribute.frame.origin.y+theLastAttribute.frame.size.height + kGeomSpaceEdge;
    }
    
    NSLog(@"after section:%ld items:%ld yOffset=%f numColumns=%ld",(long) section,(long) [self.collectionView numberOfItemsInSection:section], yOffset, (long)kProfileNumColumnsForMediaItemsPhone);
    
    // Get the last item to calculate the total height of the content
    NSArray *lastSectionAttributes = [_sectionAttributes lastObject];
    
    UICollectionViewLayoutAttributes *a;
    CGFloat y = kGeomSpaceEdge, lastY;
    for (int i=0; i<kProfileNumColumnsForMediaItemsPhone; i++) {
        NSInteger index = [lastSectionAttributes count] - 1 - i;
        if (index >= 0) {
            a = [lastSectionAttributes objectAtIndex: index];
            lastY = a.frame.origin.y + a.frame.size.height;
            if (lastY > y)
                y = lastY;
        }
    }
    
    contentHeight = y + kGeomSpaceEdge;
    
    _contentSize = CGSizeMake(contentWidth, contentHeight);
    NSLog (@"CV SIZE %@",NSStringFromCGSize(_contentSize));
}

@end
