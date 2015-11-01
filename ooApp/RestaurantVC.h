//
//  RestaurantVC.h
//  ooApp
//
//  Created by Anuj Gujar on 9/14/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantObject.h"
#import "SubBaseVC.h"
#import "RestaurantVCCVL.h"
#import "RestaurantMainCVCell.h"
#import "ListObject.h"

@interface RestaurantVC : SubBaseVC <UIActionSheetDelegate, UICollectionViewDataSource, RestaurantVCCollectionViewDelegate, RestaurantMainCVCellDelegate>

@property (nonatomic, strong) RestaurantObject *restaurant;
@property (nonatomic, strong) ListObject *listToAddTo;

- (void)getRestaurant;

@end
