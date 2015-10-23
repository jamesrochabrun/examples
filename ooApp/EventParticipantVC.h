//
//  EventParticipantVC.h E2
//  ooApp
//
//  Created by Zack Smith on 9/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "VoteObject.h"

@protocol EventParticipantFirstCellDelegate
- (void) userRequestToSubmit;
@end

@protocol EventParticipantVotingCellDelegate
- (void) voteChanged:(VoteObject*) object;
@end

@interface EventParticipantVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate,
                EventParticipantFirstCellDelegate,EventParticipantVotingCellDelegate>

@property (nonatomic,strong) NSString *eventName;

@end

@interface EventParticipantFirstCell: UITableViewCell
@property (nonatomic,assign) id <EventParticipantFirstCellDelegate> delegate;
- (void) provideEvent: (EventObject*)event;
- (void)indicateMissingVoteFor: (RestaurantObject*)venue;
- (void)provideVote: (VoteObject*)vote;
@end

@interface EventParticipantVotingCell: UITableViewCell 
@property (nonatomic,strong) VoteObject  *vote;
@property (nonatomic,assign) id <EventParticipantVotingCellDelegate> delegate;
@end
