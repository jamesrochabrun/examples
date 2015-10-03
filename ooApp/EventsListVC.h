//
//  EventsListVC.h
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface EventsListVC : BaseVC <UITableViewDataSource, UITableViewDelegate>

@end

@interface EventListTableCell : UITableViewCell

//@property (nonatomic, strong) UIImageView *iv;
//@property (nonatomic, strong) UIButton *buttonFollow;
//@property (nonatomic, strong) UIButton *buttonNewList;
//@property (nonatomic, strong) UILabel *labelUsername;
//@property (nonatomic, strong) UILabel *labelDescription;
//@property (nonatomic, strong) UILabel *labelRestaurants;
//@property (nonatomic, strong) UIButton *buttonNewListIcon;
//@property (nonatomic, assign) float spaceNeededForFirstCell;
//@property (nonatomic, assign) UINavigationController *navigationController;
@end