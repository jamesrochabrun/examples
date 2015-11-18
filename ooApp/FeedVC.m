//
//  FeedVC.m
//  ooApp
//
//  Created by Zack Smith on 11/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "FeedVC.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "FeedObject.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
@interface FeedCell()
@property (nonatomic,strong)  UIImageView *iconImageView;
@property (nonatomic,strong)  UILabel* labelHeader;
@property (nonatomic,strong)  UILabel* labelSubheader;
@property (nonatomic,strong) UIImageView* photoImageView;
@end

@implementation FeedCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.iconImageView= makeImageView( self, APP.imageForNoProfileSilhouette);
        _iconImageView.backgroundColor= RED;
        
    }
    return self;
}

- (void)prepareForReuse
{
    _iconImageView.image= APP.imageForNoProfileSilhouette;
    _photoImageView.image= nil;
    _labelHeader.text=nil;
    _labelSubheader.text=nil;
}

- (void)layoutSubviews
{
    [ super layoutSubviews];
    
    CGFloat h = height(self);
    CGFloat w = width(self);
    _iconImageView.frame = CGRectMake(kGeomSpaceEdge,0,h,h);
    
}

- (void)dealloc
{
    self.iconImageView= nil;
    self.labelHeader= nil;
    self.labelSubheader= nil;
    self.photoImageView= nil;
    
}

@end

//------------------------------------------------------------------------------
@interface FeedVC ()
@property (nonatomic,strong) UIView* viewForButtons;
@property (nonatomic,strong) UIButton* buttonUpdates;
@property (nonatomic,strong) UIButton* buttonNotifications;
@property (nonatomic, strong) UITableView *tableViewUpdates;
@property (nonatomic, strong) UITableView *tableViewNotifications;
@property (nonatomic, strong) NSMutableOrderedSet *setOfUpdates;
@property (nonatomic, strong) NSMutableOrderedSet *setOfNotifications;
@property (nonatomic,assign)  time_t maximumTimestamp;
@end

static NSString * const FeedCellID = @"FeedCell";

@implementation FeedVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.setOfUpdates= [NSMutableOrderedSet new];
    self.setOfNotifications= [NSMutableOrderedSet new];
    FeedObject *item;
    item= [FeedObject feedObjectFromDictionary: @{
                                                   @"timestamp": @(1000000),
                                                   @"user_id": @(2),
                                                   @"description":  @"this is a test",
                                                   @"object_id":@( 300),
                                                   }];
    [_setOfUpdates addObject: item];
    
    self.viewForButtons= makeView(self.view, WHITE);
    
    self.buttonUpdates= makeButton( self.viewForButtons,  @"Updates",
                                   kGeomFontSizeHeader,
                                   YELLOW,  BLACK,
                                   self, @selector(userPressedUpdates:),
                                   0);
    [_buttonUpdates setTitleColor:WHITE forState:UIControlStateSelected];
    _buttonUpdates.selected= YES;
    
    self.buttonNotifications= makeButton( self.viewForButtons,  @"Notifications",
                                         kGeomFontSizeHeader,
                                         YELLOW,  BLACK,
                                         self, @selector(userPressedNotifications:),
                                         0);
    [_buttonNotifications setTitleColor:WHITE forState:UIControlStateSelected];
    
    self.tableViewUpdates = makeTable( self.view,  self);
    _tableViewUpdates.translatesAutoresizingMaskIntoConstraints = NO;
    //    _tableViewUpdates.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewUpdates.backgroundColor = GREEN;
    [_tableViewUpdates registerClass:[FeedCell class] forCellReuseIdentifier:FeedCellID];
    
    self.tableViewNotifications = makeTable( self.view,  self);
    _tableViewNotifications.translatesAutoresizingMaskIntoConstraints = NO;
    //    _tableViewNotifications.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewNotifications.backgroundColor = BLUE;
    [_tableViewNotifications registerClass:[FeedCell class] forCellReuseIdentifier:FeedCellID];
    
    _tableViewUpdates.opaque= YES;
    _tableViewNotifications.opaque= YES;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Feed" subHeader:@""];
    self.navTitle = nto;
}

#if 0
- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"heightFilters":@(kGeomHeightFilters), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"overallHeight" : @((height(self.view)-kGeomHeightNavBarStatusBar)/2)};
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableViewUpdates,_tableViewNotifications,
                                                         _buttonUpdates,_buttonNotifications,
                                                         _viewForButtons);
    
    _tableViewUpdates.userInteractionEnabled= _buttonUpdates.selected;
    _tableViewUpdates.alpha= _buttonUpdates.selected?1:0;
    _tableViewNotifications.userInteractionEnabled= !_buttonUpdates.selected;
    _tableViewNotifications.alpha= _buttonUpdates.selected?0:1;
    _buttonNotifications.selected= !_buttonUpdates.selected;
    
    [self.viewForButtons addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonUpdates][_buttonNotifications(==_buttonUpdates)]|"
                                                                                options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                metrics:metrics
                                                                                  views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_viewForButtons]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:metrics
                                                                        views:views]];
    
    if ( _buttonUpdates.selected) {
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_viewForButtons(40)][_tableViewUpdates]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableViewUpdates]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_viewForButtons(40)][_tableViewNotifications]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableViewNotifications]|"
                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:metrics
                                                                            views:views]];
        
    }
}
#endif

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    CGFloat y = 0;
    
    _viewForButtons.frame = CGRectMake(kGeomSpaceEdge,y,w-2*kGeomSpaceEdge, kGeomHeightButton);
    _buttonUpdates.frame = CGRectMake(0,0, (w-2*kGeomSpaceEdge)/2, kGeomHeightButton);
    _buttonNotifications.frame = CGRectMake(_buttonUpdates.frame.size.width,0, (w-2*kGeomSpaceEdge)/2, kGeomHeightButton);
    y+=kGeomHeightButton;
    
    _tableViewUpdates.frame = CGRectMake(kGeomSpaceEdge, y, w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
    _tableViewNotifications.frame = CGRectMake(kGeomSpaceEdge, y, w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
    
    _tableViewUpdates.userInteractionEnabled= _buttonUpdates.selected;
    _tableViewUpdates.alpha= _buttonUpdates.selected?1:0;
    _tableViewNotifications.userInteractionEnabled= !_buttonUpdates.selected;
    _tableViewNotifications.alpha= _buttonUpdates.selected?0:1;
}

- (void)userPressedUpdates: (id) sender
{
    if  ( self.buttonUpdates.selected) {
        return;
    }
    self.buttonUpdates.selected= YES;
    self.buttonNotifications.selected= NO;
    [  self doLayout];
    [_tableViewUpdates  reloadData];
}

- (void)userPressedNotifications: (id) sender
{
    if  ( !self.buttonUpdates.selected) {
        return;
    }
    
    self.buttonUpdates.selected= NO;
    self.buttonNotifications.selected= YES;
    [  self doLayout];
    [_tableViewNotifications  reloadData];
}

- (void) getFeed
{
    __weak FeedVC *weakSelf = self;
    [OOAPI getFeedItemsNewerThan:  _maximumTimestamp-1
                         success:^(NSArray *feedItems) {
                             if  (!feedItems.count) {
                                 return;
                             }
                             
                             for (FeedObject* item  in  feedItems) {
                                 if  (!item.isNotification ) {
                                     [weakSelf.setOfUpdates addObject: item];
                                 } else {
                                     [weakSelf.setOfNotifications addObject: item];
                                 }
                                 
                                 time_t t=  item.timestamp;
                                 if ( t>weakSelf.maximumTimestamp) {
                                     weakSelf.maximumTimestamp= t;
                                 }
                             }
                             
                             ON_MAIN_THREAD(^ {
                                 [weakSelf.tableViewUpdates reloadData];
                                 [weakSelf.tableViewNotifications reloadData];
                             });
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             ;
                         }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( _buttonUpdates.selected) {
        return [_setOfUpdates count];
    } else {
        return [_setOfNotifications count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:FeedCellID forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightEventWhoTableCellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
