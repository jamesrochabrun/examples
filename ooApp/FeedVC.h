//
//  FeedVC.h
//  ooApp
//
//  Created by Zack Smith on 11/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@protocol FeedCellDelegate
- (void) reloadCell: (NSUInteger) which;
- (void) userTappedOnUser:(NSUInteger)userid;
- (void) userTappedOnRestaurantPhoto:(NSUInteger)restaurantID;
- (void) userTappedOnEvent:(NSUInteger)eventID;
- (void) userTappedOnList:(NSUInteger)listID;

@end

@interface FeedVC : BaseVC <UITableViewDataSource, UITableViewDelegate, FeedCellDelegate>
@end

@interface FeedCell:UITableViewCell
@property (nonatomic,weak) id <FeedCellDelegate>  delegate;
@end
