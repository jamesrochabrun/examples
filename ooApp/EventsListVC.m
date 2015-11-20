//
//  EventsListVC.m E1
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "EventObject.h"
#import "ListObject.h"
#import "EventsListVC.h"
#import "LocationManager.h"
#import "Settings.h"
#import "RestaurantTVCell.h"
#import "RestaurantVC.h"
#import "UserTVCell.h"
#import "ProfileVC.h"
#import "EventTVCell.h"
#import "EventCoordinatorVC.h"
#import "EventParticipantVC.h"
#import "OOStripHeader.h"

#define EVENTS_TABLE_REUSE_IDENTIFIER  @"eventListCell"

@interface EventsListVC ()

//@property (nonatomic, strong)  UIButton *buttonAdd;

@property (nonatomic, strong)  UITableView *table;

@property (nonatomic, strong) NSArray *yourEventsArray;
@property (nonatomic, strong) NSArray *incompleteEventsArray;
@property (nonatomic, strong) NSArray *curatedEventsArray;

@property (nonatomic, strong) NSArray *tableSectionNames;

@property (nonatomic, assign) BOOL doingTransition, didGetInitialResponse, needToRefreshEventList;
@property (nonatomic,strong)  NSTimer *refreshTimer;

@property (nonatomic, strong) UIButton *createEventButton;

@end

@implementation EventsListVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= UIColorRGBA(kColorBackgroundTheme);
    
    self.eventBeingEdited= nil;
    
    self.yourEventsArray= @[];
    self.curatedEventsArray= @[];
    self.incompleteEventsArray= @[];
    
    _tableSectionNames= @[
                          @"YOUR EVENTS",
                          @"INCOMPLETE EVENTS",
                          @"OOMAMI EVENTS"
                          ];
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:LOCAL( @"EVENTS")
                           subHeader: nil];
    self.navTitle = nto;

    self.table= makeTable( self.view, self);
    [_table registerClass:[EventTVCell class] forCellReuseIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER];
    _table.sectionHeaderHeight = 55;
    _table.sectionFooterHeight = 10;
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    _table.showsVerticalScrollIndicator= NO;
    _table.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _createEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createEventButton roundButtonWithIcon:kFontIconAdd fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:0 backgroundColor:kColorBlack target:self selector:@selector(userPressedAdd:)];
    [self.view addSubview:_createEventButton];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // RULE:  only re-fetch if it's the first time, or if the user altered an event.
    
    EventObject*e=self.eventBeingEdited;
    
    // NOTE: Currently the addition of restaurants to an event is not easily detected except using the boolean.
    if  (_needToRefreshEventList || !self.didGetInitialResponse || e.hasBeenAltered) {
        [self refetchEvents];
    }
    
    [self performSelector:@selector(startRefreshTimer)  withObject:nil afterDelay:30];
}

- (void)startRefreshTimer
{
    self.refreshTimer=[NSTimer scheduledTimerWithTimeInterval:60
                                                       target:self
                                                     selector:@selector(refetchEvents)
                                                     userInfo:nil repeats:YES];
}

- (void)refetchEvents
{
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    __weak EventsListVC *weakSelf = self;

    [OOAPI getCuratedEventsWithSuccess:^(NSArray *events) {
        NSLog  (@"CURATED EVENTS FETCH SUCCEEDED %lu", ( unsigned long) events.count);
        
        NSMutableArray * curated= [NSMutableArray new];
        
        for (EventObject* eo in events) {
            if  (![eo isKindOfClass:[EventObject class]]) {
                continue;
            }
            
            if ( eo.eventType==EVENT_TYPE_CURATED &&  eo.isComplete) {
                [  curated  addObject: eo];
            }
        }

        _needToRefreshEventList= NO;
        self.curatedEventsArray=  curated;
        
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
        });
    }
                               failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                                   NSLog  (@"CURATED EVENT FETCHING FAILED  %@",e);
                               }
     ];
    
    [OOAPI getEventsForUser:userid  success:^(NSArray *events) {
        NSLog  (@"YOUR EVENTS FETCH SUCCEEDED %lu", ( unsigned long) events.count);
        
        NSMutableArray *your= [NSMutableArray new];
        NSMutableArray *incomplete= [NSMutableArray new];
        
        for (EventObject *eo in events) {
            if  (![eo isKindOfClass:[EventObject class]]) {
                continue;
            }
            
            if ( eo.eventType==EVENT_TYPE_USER) {
                if ( eo.isComplete) {
                    [  your  addObject: eo];
                } else {
                    [  incomplete  addObject: eo];
                }
            }
        }
        
        @synchronized(weakSelf.yourEventsArray) {
            weakSelf.yourEventsArray= your;
            weakSelf.incompleteEventsArray= incomplete;
        }
        
        weakSelf.didGetInitialResponse= YES;
        
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
        });
    }
                    failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                        NSLog  (@"YOUR EVENT FETCHING FAILED  %@",e);
                    }
     ];
    
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.refreshTimer invalidate];
    self.refreshTimer= nil;
}

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

//------------------------------------------------------------------------------
// Name:    userPressedAdd
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedAdd:(id)sender
{
    UIAlertView* alert= [ [UIAlertView  alloc] initWithTitle:LOCAL(@"New Event")
                                                     message:LOCAL(@"Enter a name for the new event")
                                                    delegate:self
                                           cancelButtonTitle:LOCAL(@"Cancel")
                                           otherButtonTitles:LOCAL(@"Create"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    CGFloat y = kGeomSpaceEdge;

    _table.frame = CGRectMake(kGeomSpaceEdge, y, w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
    
    CGRect frame  = _createEventButton.frame;
    frame.size = CGSizeMake(kGeomDimensionsIconButton, kGeomDimensionsIconButton);
    frame.origin = CGPointMake(self.view.bounds.size.width - kGeomDimensionsIconButton - 30, self.view.bounds.size.height - kGeomDimensionsIconButton - 30);
    _createEventButton.frame = frame;
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTVCell *cell;
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    @synchronized(_yourEventsArray) {
        
        NSArray *events= nil;
        switch ( section) {
            case 0:
                events = _yourEventsArray;
                break;
            case 1:
                events = _incompleteEventsArray;
                break;
            case 2:
                events = _curatedEventsArray;
                break;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.selectedBackgroundView = [UIView new];
        
        if (!events.count) {
            if (!_didGetInitialResponse) {
                [cell setMessageMode: @"Loading..."];
            } else {
                [cell setMessageMode: @"No events."];
            }
        } else {
            EventObject *e = events[row];
            [cell setEvent:e];
        }
        
        if (!row) {
            cell.nameHeader= [[OOStripHeader alloc] init];
            [cell.nameHeader setName:_tableSectionNames[section]];
//            if (section == 0) {
//                [cell.nameHeader enableAddButtonWithTarget:self action:@selector(userPressedAdd:)];
//            }
            [cell setIsFirst];
        } else {
            cell.nameHeader= nil;
        }
    }
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    numberOfSectionsInTableView
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *v = makeView(nil, CLEAR);
    return v;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section= indexPath.section;
    float extraSpaceForFirstRow= !indexPath.row ? kGeomStripHeaderHeight/2. : 0;
    
    @synchronized(_yourEventsArray) {
        
        NSArray *events= nil;
        switch (section) {
            case 0:
                events = _yourEventsArray;
                break;
            case 1:
                events = _incompleteEventsArray;
                break;
            case 2:
                events = _curatedEventsArray;
                break;
        }
        
        if (!events.count) {
            return kGeomHeightEventCellHeight + extraSpaceForFirstRow;
        }
    }
    
    return kGeomHeightEventCellHeight + extraSpaceForFirstRow;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger section= indexPath.section;
    NSInteger row = indexPath.row;
    @synchronized(_yourEventsArray) {
        
        NSArray *events= nil;
        switch (section) {
            case 0:
                events = _yourEventsArray;
                break;
            case 1:
                events = _incompleteEventsArray;
                break;
            case 2:
                events = _curatedEventsArray;
                // RULE: No one can delete curated events.
                return nil;
        }
        
        EventObject* event= events[ row];
        __weak EventsListVC *weakSelf = self;
        switch ( event.currentUserCanEdit) {
            case EVENT_USER_CAN_EDIT: {
                // RULE: If the user is the coordinator then they can delete the event.
                UITableViewRowAction *deleteAction =
                [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                   title:@"Delete"
                                                 handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                     [weakSelf verifyDeletionOfEvent: event];
                                                 }];
                deleteAction.backgroundColor = RED;
                return @[deleteAction];
            }
                break;
                
            case EVENT_USER_CANNOT_EDIT:  {
                // RULE: If the user is not the coordinator then they can only be removed from the event.
                UITableViewRowAction *leaveAction =
                [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                   title:@"Leave"
                                                 handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                     [weakSelf leaveEvent: event];
                                                 }];
                leaveAction.backgroundColor = BLUE;
                return @[leaveAction];
            }
                break;
                
            default:
                break;
        }
        
    }
    
    return nil;
}

- (void) verifyDeletionOfEvent:(EventObject*)event
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Really delete?")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                     }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self deleteEvent: event ];
                                                 }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self presentViewController:a animated:YES completion:nil];
}

- (void)deleteEvent: (EventObject*)event
{
    __weak EventsListVC *weakSelf = self;
    [OOAPI deleteEvent: event.eventID
               success:^{
                   [weakSelf refetchEvents ];
               }
               failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                   message( @"Failed to delete event.");
                   NSLog (@"FAILED TO DELETE EVENT %@",error);
               }];
    
}

- (void)leaveEvent:(EventObject*)event
{
     __weak EventsListVC *weakSelf = self;
     UserObject* currentUser= [Settings sharedInstance].userObject;
    [OOAPI setParticipationOf: currentUser
                      inEvent: event
                           to:NO
                      success:^(NSInteger eventID) {
                          [weakSelf refetchEvents ];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog (@"FAILED TO LEAVE EVENT %@",error);
                      }];
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_doingTransition) {
        return;
    }
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @synchronized(_yourEventsArray) {
        
        NSArray *events = nil;
        switch (section) {
            case 0:
                events = _yourEventsArray;
                break;
            case 1:
                events = _incompleteEventsArray;
                break;
            case 2:
                events = _curatedEventsArray;
                break;
        }
        
        if  (!events.count) {
            return;
        }
        
        EventObject *event = [events objectAtIndex:row];
        _eventBeingEdited= event;
        
        // RULE: Curated events are never editable.
        if (section == 2) {
            EventParticipantVC *vc= [[EventParticipantVC alloc] init];
            vc.eventBeingEdited= self.eventBeingEdited;
            vc.previousVC=  self;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        EventTVCell *cell= [tableView cellForRowAtIndexPath:indexPath];
        [cell updateHighlighting:YES];
        RUN_AFTER(400, ^{
//            [cell.nameHeader unHighlightButton];
            [cell updateHighlighting:NO];
        });
        
        
        BOOL userDidSubmitVotes=  NO;// XX: ooapi callo
        
        // Determine whether event can be edited by this user.
        // Then transition to the appropriate view controller.
        // This requires fetching the full and complete the event,
        // which getEventsForUser does not provide.
        //
        __weak EventsListVC *weakSelf = self;
        NSUInteger eventID= event.eventID;
        [OOAPI getEventByID:eventID
                    success:^(EventObject *event) {
                        _doingTransition= YES;
                        [OOAPI determineIfCurrentUserCanEditEvent:event
                                                          success:^(bool allowed) {
                                                              weakSelf.doingTransition= NO;
                                                              
                                                              NSDate *now= [NSDate date];
                                                              NSDate *end= event.dateWhenVotingClosed;
                                                              BOOL isSubmitted = event.isComplete;
                                                              BOOL votingIsDone=end && now.timeIntervalSince1970>end.timeIntervalSince1970;
                                                              
                                                              if (!isSubmitted && allowed && !votingIsDone) {
                                                                  NSLog(@"EDITING ALLOWED");
                                                                  
                                                                  EventCoordinatorVC *vc= [[EventCoordinatorVC alloc] init];
                                                                  vc.eventBeingEdited= event;
                                                                  vc.delegate= weakSelf;
                                                                  [weakSelf.navigationController pushViewController:vc animated:YES ];
                                                              } else {
                                                                  NSLog(@"EDITING PROHIBITED");
                                                                  
                                                                  EventParticipantVC* vc= [[EventParticipantVC  alloc] init];
                                                                  vc.eventBeingEdited= event;
                                                                  vc.previousVC=  self;
                                                                  if ( votingIsDone) {
                                                                      [vc setMode: VOTING_MODE_SHOW_RESULTS];
                                                                  } else {
                                                                      if (userDidSubmitVotes ) {
                                                                          [vc setMode: VOTING_MODE_NO_VOTING];
                                                                      } else {
                                                                          [vc setMode: VOTING_MODE_ALLOW_VOTING];
                                                                      }
                                                                  }
                                                                  [weakSelf.navigationController pushViewController:vc animated:YES ];
                                                                  
                                                              }
                                                              
                                                              [weakSelf.table deselectRowAtIndexPath:indexPath animated:NO];
                                                          }
                                                          failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                              weakSelf.doingTransition= NO;
                                                              [weakSelf.table deselectRowAtIndexPath:indexPath animated:NO];
                                                              message( @"Unable to contact the cloud.");
                                                          }
                         ];
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog  (@"NETWORK APPEARS TO BE DOWN");
                        message( @"Cannot access the server.");
                    }
         ];
    } // @sync
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n= 0;
    
    @synchronized(_yourEventsArray) {
        
        switch ( section) {
            case 0:
                n=  _yourEventsArray.count;
                break;
            case 1:
                n=  _incompleteEventsArray.count;
                break;
            case 2:
                n=  _curatedEventsArray.count;
                break;
                
            default:
                return 1;
        }
    }
    if  (!n) {
        return 1;
    }
    return n ;
}

//------------------------------------------------------------------------------
// Name:    clickedButtonAtIndex
// Purpose:
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (1==buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex: 0];
        [textField resignFirstResponder];
        
        NSString *string = trimString(textField.text);
        if  (string.length ) {
            string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
        }
        
        NSUInteger userid= [Settings sharedInstance].userObject.userID;
        EventObject *e= [[EventObject alloc] init];
        e.name=  string;
        e.numberOfPeople= 1;
        e.createdAt= [NSDate date];
        e.creatorID= userid;
        e.updatedAt= [NSDate date];
        e.eventType= EVENT_TYPE_USER;
        self.eventBeingEdited= e;
        
        __weak EventsListVC* weakSelf= self;
        [OOAPI addEvent: e
                success:^(NSInteger eventID) {
                    NSLog  (@"EVENT %lu CREATED FOR USER %lu", (unsigned long)eventID, ( unsigned long)userid);
                    self.eventBeingEdited= e;
                    e.eventID= eventID;
                    
                    weakSelf.needToRefreshEventList= YES;
                    [weakSelf performSelectorOnMainThread:@selector(goToEventCoordinatorScreen:) withObject:string waitUntilDone:NO];
                    
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog  (@"%@", error);
                    message( @"backend was unable to create a new event");
                }];
    }
}

- (void)goToEventCoordinatorScreen: (NSString*)name
{
    EventCoordinatorVC *vc= [[EventCoordinatorVC  alloc] init ];
    vc.delegate= self;
    vc.isNewEvent= YES;
    vc.eventBeingEdited= self.eventBeingEdited;
   [self.navigationController pushViewController:vc animated:YES];
}

- (void)userDidAlterEvent
{
    self.needToRefreshEventList= YES;
}
@end
