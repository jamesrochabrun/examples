//
//  TileCVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 8/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"

@interface TileCVCell : UICollectionViewCell

@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic) ListDisplayType displayType;

@end
