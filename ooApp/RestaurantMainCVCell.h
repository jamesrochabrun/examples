//
//  RestaurantMainCVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "RestaurantObject.h"
#import "MediaItemObject.h"
#import "ListObject.h"

@class RestaurantMainCVCell;

@protocol RestaurantMainCVCellDelegate

- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell
                       gotoURL:(NSURL *)url;
- (void)restaurantMainCVCell:(RestaurantMainCVCell *)restaurantMainCVCell
                listButtonTapped:(ListType)listType;
@end

@interface RestaurantMainCVCell : UICollectionViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) MediaItemObject *mediaItemObject;
@property (nonatomic, strong) id<RestaurantMainCVCellDelegate>delegate;

- (void)setToTry:(BOOL)on;
- (void)setFavorite:(BOOL)on;

@end
