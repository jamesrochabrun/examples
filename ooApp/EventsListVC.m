//
//  EventsListVC.m
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "EventObject.h"
#import "ListObject.h"
#import "EventsListVC.h"
#import "LocationManager.h"
#import "Settings.h"
#import "RestaurantHTVCell.h"
#import "RestaurantVC.h"
#import "UserHTVCell.h"
#import "ProfileVC.h"
#import "EventHTVCell.h"
#import "EventCoordinatorVC.h"

#define EVENTS_TABLE_REUSE_IDENTIFIER  @"eventListCell"

@interface EventsListVC ()

@property (nonatomic,strong)  UIButton* buttonAdd;

@property (nonatomic,strong)  UITableView*  table;

@property (nonatomic,strong) NSArray* eventsArray;
@property (nonatomic,strong) NSArray* tableSectionNames;
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
                          @"  YOUR EVENTS",
                          @"  INCOMPLETE EVENTS",
                          @"  OOMAMI EVENTS"
                          ];
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:LOCAL( @"EVENT")
                           subHeader: nil];
    self.navTitle = nto;

	self.table= makeTable( self.view, self);
    [_table registerClass:[EventHTVCell class]
              forCellReuseIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER];
    _table.sectionHeaderHeight= kGeomHeightButton;
    _table.sectionFooterHeight= 10;
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    
    _buttonAdd=makeButton(self.view, kFontIconAdd, kGeomFontSizeHeader, WHITE,BLACK, self, @selector(userPressedAdd:), 0);
    _buttonAdd.titleLabel.font= [UIFont fontWithName:@"oomami-icons" size: kGeomFontSizeHeader];
    _buttonAdd.layer.cornerRadius=  kGeomHeightButton/2;
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber* userid= userInfo.userID;
    
    NSDate *now= [NSDate date];
    NSTimeInterval nowTime= [now timeIntervalSince1970];
    
    __weak EventsListVC *weakSelf = self;
    [OOAPI getEventsForUser:[userid integerValue] success:^(NSArray *events) {
        NSLog  (@"EVENT FETCHING SUCCEEDED %lu", ( unsigned long) events.count);
        
        NSMutableArray *finished= [NSMutableArray new];
        NSMutableArray *future= [NSMutableArray new];
        
        for (EventObject* eo in events) {
            if  (![eo isKindOfClass:[EventObject class]]) {
                continue;
            }
            
            NSTimeInterval startingTime= [eo.date timeIntervalSince1970];
            if  (nowTime < startingTime ) {
                [ future  addObject: eo];
            } else {
                // XX:  because of the way this is set up, events that have not yet finished will be listed as finished.
                //    that is, there is no category for events that are transpiring now.
                [ finished  addObject: eo];
            }
        }
        
        _eventsArray=  @[
                         future,
                         finished,
                         @[],
                         ];
        
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
        });
    } failure:^(NSError *e) {
        NSLog  (@"EVENT FETCHING FAILED  %@",e);
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
//    if (!_navigationController) {
//        return;
//    }
    
    UIAlertView* alert= [ [UIAlertView  alloc] initWithTitle:LOCAL(@"New Event")
                                                     message: LOCAL(@"Enter a name for the new event")
                                                    delegate:  self
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
    float y=  0;

    _buttonAdd.frame=  CGRectMake( w-kGeomHeightButton-kGeomCancelButtonInteriorPadding,
                                     y+kGeomCancelButtonInteriorPadding,
                                     kGeomHeightButton,
                                     kGeomHeightButton);
//    y += kGeomHeightButton;
    
    _table.frame=  CGRectMake(0,y,w, h-y);
   
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventHTVCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    NSInteger row= indexPath.row;
    NSInteger section= indexPath.section;
    if  (section>= _eventsArray.count ) {
        return cell;
    }
    NSArray* events= _eventsArray[section];
    if  (!events) {
        return cell;
    }
    if  (row >= events.count ) {
        return cell;
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
    return 3;
}

#if 0
//------------------------------------------------------------------------------
// Name:    titleForHeaderInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( section>= 3) {
        return  @"";
    }
    return _tableSectionNames[section ];
}
#endif

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *name=  _tableSectionNames[section ];
    UILabel * label= makeLabelLeft (nil,  name,  17);
    label.backgroundColor= CLEAR;
    return  label;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel * label= makeLabelLeft (nil,   @"",  10);
    label.backgroundColor= CLEAR;
    return  label;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightFeaturedCellHeight;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row= indexPath.row;
    NSInteger section= indexPath.section;
    if  (section>= _eventsArray.count ) {
        return;
    }
    NSArray* events= _eventsArray[section];
    if  (!events) {
        return;
    }
    if  (row >= events.count ) {
        return;
    }
    
    EventObject *eo = [events objectAtIndex:indexPath.row];
    BaseVC* vc= [[BaseVC  alloc] init];
    vc.view.backgroundColor= BLUE;
    [self.navigationController pushViewController:vc animated:YES ];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if  (section>= _eventsArray.count ) {
        return 0;
    }
    NSArray* events= _eventsArray[section];

    return  events.count;
}

//------------------------------------------------------------------------------
// Name:    clickedButtonAtIndex
// Purpose:
//------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (1==buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex: 0];
        NSString *string = trimString(textField.text);
        if  (string.length ) {
            string = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
        }
        
        [self performSelector:@selector (goToEventCoordinatorScreen:) withObject: string afterDelay: 0.5];
        
    }
}

- (void)goToEventCoordinatorScreen: (NSString*)name
{
    EventCoordinatorVC *vc= [[EventCoordinatorVC  alloc] init ];
    vc.eventName= name;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
