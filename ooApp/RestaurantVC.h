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

@interface RestaurantVC : SubBaseVC <UIActionSheetDelegate, UICollectionViewDataSource, RestaurantVCCollectionViewDelegate>

@property (nonatomic, strong) RestaurantObject *restaurant;

- (void)getRestaurant;

@end
