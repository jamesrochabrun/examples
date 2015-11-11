//
//  VotingResultsVC.h E13
//  ooApp
//
//  Created by Zack Smith on 10/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "VoteObject.h"

@protocol VotingResultsFirstCellDelegate
//- (void) userRequestToSubmit;
@end

@protocol VotingResultsVotingCellDelegate
@end

@interface VotingResultsVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate,
                VotingResultsFirstCellDelegate,VotingResultsVotingCellDelegate>
@property (nonatomic,strong) EventObject *eventBeingEdited;

@end

@interface VotingResultsFirstCell: UITableViewCell
@property (nonatomic,assign) id <VotingResultsFirstCellDelegate> delegate;
- (void) provideEvent: (EventObject*)event;
//- (void)indicateMissingVoteFor: (RestaurantObject*)venue;
//- (void)provideVote: (VoteObject*)vote;
@end

@interface VotingResultsVotingCell: UITableViewCell 
@property (nonatomic,strong) VoteObject  *vote;
@property (nonatomic,assign) id <VotingResultsVotingCellDelegate> delegate;
@end
