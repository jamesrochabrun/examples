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
#import "ParticipantsView.h"

@protocol EventParticipantFirstCellDelegate
- (void) userRequestToSubmit;
- (void) userPressedProfilePicture: (NSUInteger)userid;
@end

@protocol EventParticipantVotingCellDelegate
- (void) voteChanged:(VoteObject*) object;
- (void) userDidSelect: (NSUInteger) which;
@end

@interface EventParticipantVC : SubBaseVC <UITableViewDataSource, UITableViewDelegate,
                EventParticipantFirstCellDelegate,EventParticipantVotingCellDelegate>

@property (nonatomic,strong) NSString *eventName;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@end

@interface EventParticipantEmptyCell:UITableViewCell
@end

@interface EventParticipantFirstCell: UITableViewCell <ParticipantsViewDelegate>
@property (nonatomic,assign) id <EventParticipantFirstCellDelegate> delegate;
- (void) provideEvent: (EventObject*)event;
@end

@protocol EventParticipantVotingSubCellDelegate
- (void) userPressedRadioButton: (NSInteger)currentValue;
@end

@interface EventParticipantVotingSubCell : UIView

@property (nonatomic,strong)  UIImageView *thumbnail;
@property (nonatomic,strong)   UILabel *labelName;
@property (nonatomic,strong) VoteObject  *vote;
@end

@interface EventParticipantVotingCell: UITableViewCell <EventParticipantVotingSubCellDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) VoteObject  *vote;
@property (nonatomic,assign) id <EventParticipantVotingCellDelegate> delegate;

- (void) scrollToCurrentStateAnimated: (BOOL) animated;

@end

