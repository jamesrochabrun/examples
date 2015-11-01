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
#import "VotingResultsVC.h"

#define EVENTS_TABLE_REUSE_IDENTIFIER  @"eventListCell"

@interface EventsListVC ()

@property (nonatomic,strong)  UIButton* buttonAdd;

@property (nonatomic,strong)  UITableView*  table;

@property (nonatomic,strong) NSArray* yourEventsArray;
@property (nonatomic,strong) NSArray* incompleteEventsArray;
@property (nonatomic,strong) NSArray* curatedEventsArray;

@property (nonatomic,strong) NSArray* tableSectionNames;

@property (nonatomic,assign) BOOL doingTransition, didGetInitialResponse;

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
    self.view.backgroundColor= WHITE;
    
    APP.eventBeingEdited= nil;
    
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
    _table.sectionHeaderHeight= 55;
    _table.sectionFooterHeight= 10;
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    
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
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    
    // RULE:  only re-fetch if it's the first time, or if the user altered an event.
    // XX:  need to add timer to periodically refresh the list.
    
    EventObject*e=APP.eventBeingEdited;
    BOOL currentEventWasAltered= e.hasBeenAltered;
    if  (!self.didGetInitialResponse || currentEventWasAltered) {
        
        __weak EventsListVC *weakSelf = self;
#if 0
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
            self.curatedEventsArray=  curated;
            
            ON_MAIN_THREAD(^(){
                [weakSelf.table  reloadData];
            });
            
        }
                                   failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                                       NSLog  (@"EVENT FETCHING FAILED  %@",e);
                                   }
         ];
#endif
        
        [OOAPI getEventsForUser:userid  success:^(NSArray *events) {
            NSLog  (@"YOUR EVENTS FETCH SUCCEEDED %lu", ( unsigned long) events.count);
            
            NSMutableArray *your= [NSMutableArray new];
            NSMutableArray * incomplete= [NSMutableArray new];
            
            for (EventObject* eo in events) {
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
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
- (void)userPressedAdd: (id) sender
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
    CGFloat h = self.view.bounds.size.height;
    CGFloat w = self.view.bounds.size.width;
    CGFloat y = kGeomSpaceEdge;

    _table.frame = CGRectMake(kGeomSpaceEdge, y, w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
   
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTVCell *cell;
    
    NSInteger row= indexPath.row;
    NSInteger section= indexPath.section;
    
    @synchronized(_yourEventsArray) {
        
        NSArray* events= nil;
        switch ( section) {
            case 0:
                events=  _yourEventsArray;
                break;
            case 1:
                events=  _incompleteEventsArray;
                break;
            case 2:
                events=  _curatedEventsArray;
                break;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.selectedBackgroundView= [UIView new];
        
        if (!events.count) {
            if (!_didGetInitialResponse) {
                [cell setMessageMode: @"Loading..."];
            } else {
                [cell setMessageMode: @"No events."];
            }
        } else {
            EventObject *e = events[row];
            [cell setEvent: e];
        }
        
        if (!row) {
            cell.nameHeader= [[OOStripHeader alloc] init];
            [cell.nameHeader setName:_tableSectionNames[section]];
            if (section == 0) {
                [cell.nameHeader enableAddButtonWithTarget:self action:@selector(userPressedAdd:)];
            }
            [cell setIsFirst];
        } else {
            cell.nameHeader= nil;
        }
    }
    
    cell.backgroundColor = WHITE;
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    numberOfSectionsInTableView
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
//    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 7;
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
    float extraSpaceForFirstRow= !indexPath.row ? 27 : 0;
    
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
            return kGeomHeightFeaturedCellHeight + extraSpaceForFirstRow;
        }
    }
    
    return kGeomHeightFeaturedCellHeight + extraSpaceForFirstRow;
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
        
        // RULE: Curated events are never editable.
        if (section == 2) {
            EventParticipantVC *vc= [[EventParticipantVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        EventTVCell *cell= [tableView cellForRowAtIndexPath:indexPath];
        [cell updateHighlighting:YES];
        RUN_AFTER(400, ^{
            [cell.nameHeader unHighlightButton];
        });
        
        // Determine whether event can be edited by this user.
        // Then transition to the appropriate view controller.
        //
        __weak EventsListVC *weakSelf = self;
        _doingTransition= YES;
        [OOAPI determineIfCurrentUserCanEditEvent:event
                                          success:^(bool allowed) {
                                              weakSelf.doingTransition= NO;
                                            
                                              NSDate *now= [NSDate date];
                                              NSDate *end= event.dateWhenVotingClosed;
//                                              allowed=0;
                                              if (allowed) {
                                                  NSLog(@"EDITING ALLOWED");
                                                  
                                                  APP.eventBeingEdited= event;
                                                  EventCoordinatorVC *vc= [[EventCoordinatorVC alloc] init];
                                                  [weakSelf.navigationController pushViewController:vc animated:YES ];
                                              } else {
                                                  NSLog(@"EDITING PROHIBITED");
                                                  
                                                  if (end && now.timeIntervalSince1970>end.timeIntervalSince1970 ) {
                                                      APP.eventBeingEdited= event;
                                                      VotingResultsVC* vc= [[VotingResultsVC  alloc] init];
                                                      [weakSelf.navigationController pushViewController:vc animated:YES ];

                                                  } else {
                                                      
                                                      APP.eventBeingEdited= event;
                                                      EventParticipantVC* vc= [[EventParticipantVC  alloc] init];
                                                      [weakSelf.navigationController pushViewController:vc animated:YES ];
                                                      
                                                  }
                                              }
                                          } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                                              weakSelf.doingTransition= NO;
                                              [weakSelf.table deselectRowAtIndexPath:indexPath animated:NO];
                                              message( @"Unable to contact the cloud.");
                                          }];
    }
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
        
        EventObject *e= [[EventObject  alloc] init];
        e.name=  string;
        e.numberOfPeople= 1;
        e.createdAt= [NSDate date];
        e.updatedAt= [NSDate date];
        e.eventType= EVENT_TYPE_USER;
        APP.eventBeingEdited= e;
        
        __weak EventsListVC* weakSelf= self;
        [OOAPI addEvent: e
                success:^(NSInteger eventID) {
                    NSLog  (@" EVENT CREATED");
                    APP.eventBeingEdited= e;
                    e.eventID= eventID;
                    
                    [weakSelf performSelectorOnMainThread:@selector(goToEventCoordinatorScreen:) withObject:string waitUntilDone:NO];
                    
                }
                failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                    NSLog  (@"%@", error);
                    message( @"backend was unable to create a new event");
                }];
    }
}

- (void)goToEventCoordinatorScreen: (NSString*)name
{
    EventCoordinatorVC *vc= [[EventCoordinatorVC  alloc] init ];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
