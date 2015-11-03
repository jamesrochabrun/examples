//
//  EventsListVC.h E1
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface EventsListVC : BaseVC <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@end

@interface EventListTableTitleView: UIView

- (void)setTitle:(NSString *)string;

@end
