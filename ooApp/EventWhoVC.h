//
//  EventWhoVC.h
//  ooApp
//
//  Created by Zack Smith on 10/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "UserObject.h"
#import "GroupObject.h"

@protocol EventWhoTableCellDelegate
- (void) radioButtonChanged: (BOOL)value for: (id)object;
@end

@interface EventWhoVC : BaseVC  <EventWhoTableCellDelegate, UIAlertViewDelegate>

@end

@interface EventWhoTableCell: UITableViewCell
@property (nonatomic,assign) EventWhoVC *viewController;
- (void) specifyUser:  (UserObject*)user;
- (void) specifyGroup:  (GroupObject*)group;

@end
