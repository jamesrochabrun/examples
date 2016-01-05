//
//  EventSelectionVC.h E1S
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "ParticipantsView.h"
#import "EventCoordinatorVC.h"
#import "RestaurantObject.h"
#import "EventTVCell.h"

@interface EventSelectionVC : BaseVC <UITableViewDataSource, UITableViewDelegate,
        EventTVCellDelegate, EventCoordinatorVCDelegate>
@property (nonatomic,strong) RestaurantObject* restaurantBeingAdded;
@end

@interface EventSelectionTableTitleView: UIView

- (void)setTitle:(NSString *)string;

@end
