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
@end

@interface FeedVC : BaseVC <UITableViewDataSource, UITableViewDelegate, FeedCellDelegate>
@end

@interface FeedCell:UITableViewCell
@property (nonatomic,weak) id <FeedCellDelegate>  delegate;
@end
