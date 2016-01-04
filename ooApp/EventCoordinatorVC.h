//
//  EventCoordinatorVC.h E3
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBaseVC.h"
#import "EventWhenVC.h"
#import "ParticipantsView.h"
#import "EventWhoVC.h"
#import "EventObject.h"
#import "ObjectTVCell.h"
#import "RestaurantObject.h"

@protocol EventCoordinatorVCDelegate
- (void) userDidAlterEvent;
@optional
- (void) userDidDeclineEvent;
@end

@protocol EventCoordinatorCoverCellDelegate
@optional
- (void) userDidAlterEvent;
- (void) userDidSubmitEvent;
- (void) userDidDeclineEvent;
@end

@protocol EventCoordinatorWhoCellDelegate
- (void)userPressedButtonForProfile:(NSUInteger)userid;
@end

@protocol EventCoordinatorWhenCellDelegate
@optional
@end

@protocol EventCoordinatorWhereCellDelegate
- (void) userTappedOnVenue:(RestaurantObject*)venue;
- (void) userPressedNewRestaurant;
@end

@protocol PlusCellDelegate
- (void) userPressedNewRestaurant;
@end

//------------------------------------------------------------------------------

@interface PlusCell: UICollectionViewCell
@property (nonatomic,weak) NSObject<PlusCellDelegate>* delegate;

@end

@interface EventCoordinatorNewCell: UITableViewCell
- (void)setMessage: (NSString*)message;
@end

@interface EventCoordinatorWhoCell: UITableViewCell <ParticipantsViewDelegate>
@property (nonatomic,assign) BOOL inE3LMode;
- (void) provideEvent: (EventObject*)event;
@property (nonatomic,weak) NSObject<EventCoordinatorWhoCellDelegate>* delegate;
@end

@interface EventCoordinatorWhenCell: UITableViewCell
@property (nonatomic,assign) BOOL inE3LMode;
- (void) provideEvent: (EventObject*)event;
@property (nonatomic,weak) NSObject<EventCoordinatorWhenCellDelegate>* delegate;
@end

@interface EventCoordinatorWhereCell: UITableViewCell  <PlusCellDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,assign) BOOL inE3LMode;
- (void) provideEvent: (EventObject*)event;
@property (nonatomic,weak) NSObject<EventCoordinatorWhereCellDelegate>* delegate;
@end

@interface EventCoordinatorCoverCell: UITableViewCell
@property (nonatomic,assign) BOOL inE3LMode;
- (void) provideEvent: (EventObject*)event;
- (void) setPhoto: ( UIImage*)image;
- (void) coverHasImageNow;
- (void) coverDoesNotHaveImage;
@property (nonatomic,weak) NSObject<EventCoordinatorCoverCellDelegate>* delegate;
@end

@interface EventCoordinatorVC : SubBaseVC <UIImagePickerControllerDelegate, UIScrollViewDelegate, 
    EventWhenVCDelegate, ParticipantsViewDelegate, EventWhoVCDelegate,EventCoordinatorWhereCellDelegate,
    EventCoordinatorWhenCellDelegate,EventCoordinatorWhoCellDelegate,
UINavigationControllerDelegate>
@property (nonatomic,weak) id <EventCoordinatorVCDelegate> delegate;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@property (nonatomic,assign) BOOL isNewEvent;

- (void) enableE3LMode;

@end

