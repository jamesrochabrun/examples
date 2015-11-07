//
//  EventsListVC.h E1
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "ParticipantsView.h"
#import "EventCoordinatorVC.h"

@interface EventsListVC : BaseVC <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,  EventCoordinatorVCDelegate>
@property (nonatomic,strong) EventObject* eventBeingEdited;
@end

@interface EventListTableTitleView: UIView

- (void)setTitle:(NSString *)string;

@end
