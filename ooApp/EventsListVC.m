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

#define EVENTS_TABLE_REUSE_IDENTIFIER  @"eventListCell"

@implementation  EventListTableCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.textLabel.text= nil;
    self.backgroundColor= CLEAR;
}
@end


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
                          @"YOUR EVENTS",
                          @"INCOMPLETE EVENTS",
                          @"OOMAMI EVENTS"
                          ];
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:LOCAL( @"EVENT")
                           subHeader: nil];
    self.navTitle = nto;

	self.table= makeTable( self.view, self);
    
    [_table registerClass:[EventListTableCell class]
              forCellReuseIdentifier:EVENTS_TABLE_REUSE_IDENTIFIER];
    
    _buttonAdd=makeButton(self.view, kFontIconAdd, kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(userPressedAdd:), .5);
    _buttonAdd.titleLabel.font= [UIFont fontWithName:@"oomami-icons" size: kGeomFontSizeHeader];
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSNumber* userid= userInfo.userID;
    
    __weak EventsListVC *weakSelf = self;
    [OOAPI getEventsForUser:[userid integerValue] success:^(NSArray *events) {
        NSLog  (@"EVENT FETCHING SUCCEEDED %lu", ( unsigned long) events.count);
        
        // XX  need to separate out different kinds of events.
        
        _eventsArray=  @[
                         events,
                          @[],
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
    message( @"You pressed add.");
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

    _buttonAdd.frame=  CGRectMake( w-kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     y+kGeomCancelButtonInteriorPadding,
                                     kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     kGeomHeightButton-2*kGeomCancelButtonInteriorPadding);
    y += kGeomHeightButton;
    
    _table.frame=  CGRectMake(0,y,w, h-y);
   
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventListTableCell *cell;
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
    
    cell.backgroundColor= GREEN;
    cell.textLabel.text= e.name;
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

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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

@end
