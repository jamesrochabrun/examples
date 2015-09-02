//
//  ListTVCell.h
//  ooApp
//
//  Created by Anuj Gujar on 8/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListObject.h"

@interface ListTVCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) ListObject *listItem;

- (void)getRestaurants;
- (void)deselectRow;

@end
