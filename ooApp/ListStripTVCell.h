//
//  ListStripTVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 8/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListObject.h"

@interface ListStripTVCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) ListObject *listItem;
@property (nonatomic, weak) UINavigationController *navigationController;

- (void)getRestaurants;

@end
