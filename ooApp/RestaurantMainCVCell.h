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

@interface RestaurantMainCVCell : UICollectionViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) MediaItemObject *mediaItemObject;

@end
