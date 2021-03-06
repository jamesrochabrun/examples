//
//  RestaurantMainCVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"
#import "MediaItemObject.h"
#import "ListObject.h"

@class RestaurantMainCVCell;

@protocol RestaurantMainCVCellDelegate

- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell
                       gotoURL:(NSURL *)url;
- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell
                listButtonTapped:(ListType)listType;
- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell
               showMapTapped:(CLLocationCoordinate2D)coordinate;
- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell
               showListSearchingKeywords:(NSArray *)keywords;
- (void)restaurantMainCVCellMorePressed:(id)sender;
@end

@interface RestaurantMainCVCell : UICollectionViewCell

@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) MediaItemObject *mediaItemObject;
@property (nonatomic, weak) id<RestaurantMainCVCellDelegate>delegate;

- (CGFloat)getHeight;
    
@end
