//
//  EventWhoVC.h E6, E6A, E6B
//  ooApp
//
//  Created by Zack Smith on 10/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "UserObject.h"
#import "GroupObject.h"

@protocol EventWhoTableCellDelegate
- (void) radioButtonChanged: (BOOL)value for: (id)object;
@end

@protocol EventWhoVCDelegate
- (void) userDidAlterEventParticipants;
@end

@interface EventWhoVC : SubBaseVC  <EventWhoTableCellDelegate, UIAlertViewDelegate>
@property (nonatomic,assign) id <EventWhoVCDelegate> delegate;
@end

@interface EventWhoTableCell: UITableViewCell
@property (nonatomic,assign) EventWhoVC *viewController;
- (void) specifyUser:  (UserObject*)user;
- (void) specifyGroup:  (GroupObject*)group;
@end
