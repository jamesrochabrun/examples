//
//  EventParticipantVC.h E2 and E13
//  ooApp
//
//  Created by Zack Smith on 9/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "VoteObject.h"
#import "ParticipantsView.h"
#import "EventCoordinatorVC.h"

@protocol EventParticipantFirstCellDelegate
- (void) userRequestToSubmit;
- (void) userPressedProfilePicture: (NSUInteger)userid;
- (void) votingEnded;
@end

@protocol EventParticipantVotingCellDelegate
- (void) voteChanged:(VoteObject*) object;
- (void) userDidSelect: (NSUInteger) which;
@end

@protocol EventParticipantVotingSubCellDelegate
- (void) userPressedRadioButton: (NSInteger)currentValue;
@end

//------------------------------------------------------------------------------

@interface EventParticipantVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate,
                EventParticipantFirstCellDelegate,EventParticipantVotingCellDelegate,EventCoordinatorVCDelegate>

- (void)setMode:(int)mode;
@property (nonatomic,assign) BOOL votingIsDone;
@property (nonatomic,strong) NSString *eventName;
@property (nonatomic,strong) UIViewController *previousVC;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@end

//------------------------------------------------------------------------------

@interface EventParticipantEmptyCell:UITableViewCell
@end

//------------------------------------------------------------------------------

@interface EventParticipantFirstCell: UITableViewCell <ParticipantsViewDelegate>
@property (nonatomic,weak) id <EventParticipantFirstCellDelegate> delegate;
- (void) provideEvent: (EventObject*)event;
@end

enum  {
    VOTING_MODE_ALLOW_VOTING= 0,
    VOTING_MODE_NO_VOTING= 1,
    VOTING_MODE_SHOW_RESULTS= 2,
};

//------------------------------------------------------------------------------

@interface EventParticipantVotingSubCell : UIView
@property (nonatomic,strong) VoteObject  *vote;
- (void)setMode:(int)mode;

@end

    //------------------------------------------------------------------------------

@interface EventParticipantVotingCell: UITableViewCell <EventParticipantVotingSubCellDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) VoteObject  *vote;
@property (nonatomic,weak) id <EventParticipantVotingCellDelegate> delegate;

- (void) scrollToCurrentStateAnimated: (BOOL) animated;
- (void)setMode:(int)mode;
@end

