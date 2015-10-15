//
//  RestaurantListVC.h
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListObject.h"
#import "SubBaseVC.h"

@interface RestaurantListVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ListObject *listItem;

- (void)getRestaurants;

@end