//
//  ListsVC.h
//  ooApp
//
//  Created by Anuj Gujar on 9/9/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "RestaurantObject.h"

@interface ListsVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RestaurantObject *restaurant;

- (void)getLists;

@end
