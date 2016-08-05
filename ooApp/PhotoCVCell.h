//
//  PhotoCVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItemObject.h"
#import "UnverifiedUserVC.h"
#import "RestaurantObject.h"

@class PhotoCVCell;

@protocol PhotoCVCellDelegate <NSObject>
- (void)photoCell:(PhotoCVCell *)photoCell showPhotoOptions:(MediaItemObject *)mio;
- (void)photoCell:(PhotoCVCell *)photoCell showRestaurant:(RestaurantObject *)restaurant;
- (void)photoCell:(PhotoCVCell *)photoCell likePhoto:(MediaItemObject *)mio;
- (void)photoCell:(PhotoCVCell *)photoCell userNotVerified:(MediaItemObject *)mio;
@end

@interface PhotoCVCell : UICollectionViewCell

@property (nonatomic, strong) MediaItemObject *mediaItemObject;
@property (nonatomic, strong) RestaurantObject *restaurantObject;
@property (nonatomic, weak) id<PhotoCVCellDelegate> delegate;

//- (void)showActionButton:(BOOL)show;
- (UIImage *)shareImage;

@end
