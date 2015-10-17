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
#define EVENTS_TABLE_GENERIC_REUSE_IDENTIFIER  @"eventListGenericCell"

@interface EventsListVC ()

@property (nonatomic,strong)  UIButton* buttonAdd;

@property (nonatomic,strong)  UITableView*  table;

@property (nonatomic,strong) NSArray* yourEventsArray;
@property (nonatomic,strong) NSArray* incompleteEventsArray;
@property (nonatomic,strong) NSArray* curatedEventsArray;

@property (nonatomic,strong) NSArray* tableSectionNames;

@property (nonatomic,assign) BOOL doingTransition;

@end

@implementation EventsListVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= WHITE;
    
    _tableSectionNames= @[
                          @"YOUR EVENTS",
                          @"EVENTS YOU ARE CREATING",
                          @"OOMAMI EVENTS"
                          ];
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:LOCAL( @"EVENTS")
                           subHeader: nil];
    self.navTitle = nto;

    self.table= makeTable( self.view, self);
    [_table registerClass:[EventTVCell class] forCellReuseIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER];
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:EVENTS_TABLE_GENERIC_REUSE_IDENTIFIER];
    _table.sectionHeaderHeight= 55;
    _table.sectionFooterHeight= 10;
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber* userid= userInfo.userID;
    
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
        self.curatedEventsArray=  curated;
        
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
        });
        
    }
                               failure:^(NSError *e) {
                                   NSLog  (@"EVENT FETCHING FAILED  %@",e);
                               }
     ];
    
    [OOAPI getEventsForUser:[userid integerValue] success:^(NSArray *events) {
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
        
        self.yourEventsArray= your;
        self.incompleteEventsArray= incomplete;
        
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
        });
    }
                    failure:^(NSError *e) {
        NSLog  (@"YOUR EVENT FETCHING FAILED  %@",e);
    }
     ];
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
                                                     message: LOCAL(@"Enter a name for the new event")
                                                    delegate: self
                                           cancelButtonTitle: LOCAL(@"Cancel")
                                           otherButtonTitles: LOCAL(@"Create"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float y=  kGeomSpaceEdge;

//    _buttonAdd.frame=  CGRectMake( w-kGeomHeightButton-kGeomCancelButtonInteriorPadding,
//                                     y+kGeomCancelButtonInteriorPadding,
//                                     kGeomHeightButton,
//                                     kGeomHeightButton);
    
    _table.frame=  CGRectMake(kGeomSpaceEdge,y,w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
   
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
    
    if  (!events.count) {
        UITableViewCell* genericCell=[tableView dequeueReusableCellWithIdentifier:EVENTS_TABLE_GENERIC_REUSE_IDENTIFIER forIndexPath:indexPath];
//        genericCell.textLabel.text= ! events ?  LOCAL( @"Loading...") : LOCAL( @"None.");
//        genericCell.textLabel.textColor= !events ? BLUE : BLACK;
        
        OOStripHeader *nameHeader= [[OOStripHeader  alloc] init];
        [nameHeader setName: _tableSectionNames[section]];
        [genericCell  addSubview: nameHeader];
        
        float w=  self.table.bounds.size.width;
        nameHeader.frame = CGRectMake(0,(kGeomHeightButton-27)/2,w, 27);

        return  genericCell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];

    if (!row ) {
        cell.nameHeader= [[OOStripHeader  alloc] init];
        [cell.nameHeader setName: _tableSectionNames[section]];
        if ( section ==1) {
            [cell.nameHeader enableAddButtonWithTarget:self action:@selector(userPressedAdd:)];
        }
    }
    
    EventObject* e= events[row];
    [cell setEvent: e];

    cell.backgroundColor= WHITE;
    
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

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel * label= makeLabelLeft (nil,   @"",  10);
//    label.backgroundColor= RED;
    return  label;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section= indexPath.section;
    
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
    if (!events.count) {
        return kGeomHeightButton;
    }
    return kGeomHeightFeaturedCellHeight;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if  (_doingTransition ) {
        return;
    }

    NSInteger row= indexPath.row;
    NSInteger section= indexPath.section;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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
    
    if  (!events.count) {
        return;
    }
    
    EventObject *event = [events objectAtIndex: row];
    
    // RULE: Curated events are never editable.
    if ( section==2) {
        EventParticipantVC* vc= [[EventParticipantVC  alloc] init];
        [self.navigationController pushViewController:vc animated:YES ];
        return;
    }
    
    // Determine whether event can be edited by this user.
    // Then transition to the appropriate view controller.
    //
    __weak EventsListVC *weakSelf = self;
    self.doingTransition= YES;
    [OOAPI determineIfCurrentUserCanEditEvent:event
                                      success:^(bool allowed) {
                                          weakSelf.doingTransition= NO;
                                          
                                          if  (allowed ) {
                                              NSLog  (@"EDITING ALLOWED");
                                              
                                              APP.eventBeingEdited= event;
                                              EventCoordinatorVC* vc= [[EventCoordinatorVC  alloc] init];
                                              [weakSelf.navigationController pushViewController:vc animated:YES ];
                                              
                                          } else {
                                              NSLog  (@"EDITING PROHIBITED");
                                              APP.eventBeingEdited= event;
                                              EventParticipantVC* vc= [[EventParticipantVC  alloc] init];
                                              [weakSelf.navigationController pushViewController:vc animated:YES ];
                                              
                                          }
                                      } failure:^(NSError *e) {
                                          NSLog  (@" failure %@",e);
                                          weakSelf.doingTransition= NO;
                                          [weakSelf.table deselectRowAtIndexPath:indexPath animated:NO];
                                          message( @"Unable to contact the cloud.");
                                      }];
    
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n= 0;
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
            return 0;
    }
    return MAX(1, n );
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
                    
                    RestaurantObject *restaurant= [ [RestaurantObject  alloc] init];
                    restaurant.googleID=@"ChIJ513xa0-0j4ARmna-TypiV9w";
                    restaurant.restaurantID=  @"";
                    
                    // NOTE:  this is not implemented on the backend yet.
                    [OOAPI addRestaurant:restaurant toEvent:e  success:^(id response) {
                        
                        [weakSelf performSelectorOnMainThread:@selector(goToEventCoordinatorScreen:) withObject:string waitUntilDone:NO];
                        
                    } failure:^(NSError *error) {
                        NSLog (@" error=  %@", error);
                        [weakSelf performSelectorOnMainThread:@selector(goToEventCoordinatorScreen:) withObject:string waitUntilDone:NO];
                   }];
                    
                }
                failure:^(NSError *error) {
                    NSLog  (@"%@", error);
                    message( @"backend was unable to create a new event");
                    
//                    [weakSelf performSelectorOnMainThread:@selector(goToEventCoordinatorScreen:) withObject:string waitUntilDone:NO];
                }];
    }
}

- (void)goToEventCoordinatorScreen: (NSString*)name
{
    EventCoordinatorVC *vc= [[EventCoordinatorVC  alloc] init ];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
