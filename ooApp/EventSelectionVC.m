//
//  EventSelectionVC.m E1S
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
#import "EventSelectionVC.h"
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

#define EVENT_SELECT_TABLE_REUSE_IDENTIFIER  @"eventSelectionCell"

@interface EventSelectionVC ()

@property (nonatomic, strong)  UITableView *table;

@property (nonatomic, strong) NSArray *incompleteEventsArray;

@property (nonatomic, assign) BOOL doingTransition, didGetInitialResponse, needToRefreshEventList;

@end

@implementation EventSelectionVC

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

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
    
    if (!self.restaurantBeingAdded) {
        ANALYTICS_EVENT_ERROR(@"EventSelectionVC: No restaurant");
        return;
    }
    
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    
    self.incompleteEventsArray= @[];
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:LOCAL( @"SELECT AN EVENT")
                           subHeader: nil];
    self.navTitle = nto;
    
    self.table= makeTable( self.view, self);
    [_table registerClass:[EventTVCell class] forCellReuseIdentifier:EVENT_SELECT_TABLE_REUSE_IDENTIFIER];
    _table.sectionHeaderHeight = 55;
    _table.sectionFooterHeight = 10;
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    _table.showsVerticalScrollIndicator= NO;
    _table.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
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
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    
    // RULE:  only fetch if it's the first time.
    [self fetchEvents];
    
}

- (void) fetchEvents
{
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    __weak EventSelectionVC *weakSelf = self;
    
    [OOAPI getEventsForUser:userid  success:^(NSArray *events) {
        NSLog  (@"EVENTS FETCH SUCCEEDED #=%lu", ( unsigned long) events.count);
        
        NSMutableArray *incomplete= [NSMutableArray new];
        
        for (EventObject *eo in events) {
            if  (![eo isKindOfClass:[EventObject class]]) {
                continue;
            }
            
            if ( eo.eventType==EVENT_TYPE_USER) {
                if (! eo.isComplete) {
                    [  incomplete  addObject: eo];
                }
            }
        }
        
        @synchronized(weakSelf.incompleteEventsArray) {
            weakSelf.incompleteEventsArray= incomplete;
        }
        
        weakSelf.didGetInitialResponse= YES;
        
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
        });
    }
                    failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                        NSLog  (@"EVENT FETCHING FAILED  %@",e);
                    }
     ];
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
    
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTVCell *cell;
    
    NSInteger row = indexPath.row;
    
    @synchronized(_incompleteEventsArray) {
        NSArray *events= nil;
        events = _incompleteEventsArray;
        
        cell = [tableView dequeueReusableCellWithIdentifier:EVENT_SELECT_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.selectedBackgroundView = [UIView new];
        cell.delegate= self;
        
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
    }
    
    return cell;
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightEventCellHeight;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak EventSelectionVC *weakSelf = self;

    if (_doingTransition) {
        return;
    }
    _doingTransition=YES;
    
    NSInteger row = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @synchronized(_incompleteEventsArray) {
        
        NSArray *events = nil;
        events = _incompleteEventsArray;
        
        if ( row>=  events.count) {
            _doingTransition=NO;
            return;
        }
        
        EventObject *event = [events objectAtIndex:row];
        
        // RULE: Make sure that we really know what venues are in this event b/c the initial fetch did not obtain them.
        
        [event refreshVenuesFromServerWithSuccess:^{
            if([event alreadyHasVenue: self.restaurantBeingAdded]) {
                message(@"That event already has the restaurant.");
                weakSelf.doingTransition=NO;
                return;
            }
            
            NSUInteger eventID= event.eventID;
            [OOAPI getEventByID:eventID
                        success:^(EventObject *event) {
                            weakSelf.doingTransition=NO;
                            
                            [event addVenue: weakSelf.restaurantBeingAdded
                            completionBlock:^(BOOL result) {
                                messageWithTitleAndCompletionBlock(nil, result? @"Added." : @"Failed to add the restaurant.",
                                                                   ^(BOOL result) {
                                                                       ON_MAIN_THREAD(^{
                                                                           [weakSelf done:nil];
                                                                       });
                                                                   }, NO);
                                
                            }];
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog  (@"NETWORK APPEARS TO BE DOWN");
                            message( @"Cannot access the server.");
                            weakSelf.doingTransition=NO;
                        }
             ];

        } failure:^{
            message( @"Cannot access the server.");
            weakSelf.doingTransition=NO;
        }];
        
    } // @sync
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n= 0;
    
    @synchronized(_incompleteEventsArray) {
        
        n=  _incompleteEventsArray.count;
    }
    if  (!n) {
        return 1;// This is the "alas there are none" row.
    }
    return n ;
}

- (void)userDidAlterEvent
{
    self.needToRefreshEventList= YES;
}

@end
