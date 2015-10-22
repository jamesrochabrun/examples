//
//  EventParticipantVC.h E2
//  ooApp
//
//  Created by Zack Smith on 9/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"

@protocol EventParticipantFirstCellDelegate
- (void) userRequestToSubmit;
@end

@protocol EventParticipantVotingCellDelegate
@end

@interface EventParticipantVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate,
                EventParticipantFirstCellDelegate,EventParticipantVotingCellDelegate>

@property (nonatomic,strong) NSString *eventName;

@end

@interface EventParticipantFirstCell: UITableViewCell
@property (nonatomic,assign) id <EventParticipantFirstCellDelegate> delegate;
- (void) provideEvent: (EventObject*)event;
@end

@interface EventParticipantVotingCell: UITableViewCell
@property (nonatomic,assign) id <EventParticipantVotingCellDelegate> delegate;
@end
