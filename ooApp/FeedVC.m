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
#import "TTTAttributedLabel.h"
#import "Settings.h"

//------------------------------------------------------------------------------
@interface FeedCell()
@property (nonatomic,strong) FeedObject* feedObject;
@property (nonatomic,strong)  UIImageView *iconImageView;
@property (nonatomic,strong)  UILabel* labelHeader;
//@property (nonatomic,strong)  TTTAttributedLabel* labelSubheader;
@property (nonatomic,strong)  UILabel* labelSubheader;
@property (nonatomic,strong) UIImageView* photoImageView;
@property (nonatomic,strong) UIButton* buttonIgnore;
@property (nonatomic,strong) UIButton* buttonAllow;

@end

@implementation FeedCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews= NO;
        self.iconImageView= makeImageView( self.contentView, APP.imageForNoProfileSilhouette);
        _iconImageView.backgroundColor= RED;
        self.labelHeader= makeLabelLeft(self.contentView, @"", kGeomFontSizeHeader);
        _labelHeader.font= [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        self.labelSubheader= makeLabelLeft(self.contentView, @"", kGeomFontSizeSubheader);
        
//        self.labelSubheader=  [[TTTAttributedLabel alloc] initWithFrame: CGRectMake(0, 0, 100, 30)];
//        [_labelSubheader withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:0 backgroundColor:0xff];
//        [self.contentView addSubview: _labelSubheader];
        
        self.photoImageView=makeImageView( self.contentView, nil);
        self.clipsToBounds= YES;
        _iconImageView.clipsToBounds= YES;
        _photoImageView.clipsToBounds= YES;
        _iconImageView.contentMode= UIViewContentModeScaleAspectFill;
        _photoImageView.contentMode= UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)provideFeedObject: (FeedObject*)object
{
    self.feedObject= object;
    
    NSString* verb= nil;
    NSString* message= object.message;
    if  ([message isEqualToString: @"follow"] ) {
         verb= @"followed";
    }
    else if ([message isEqualToString: @"follow"]) {
        
    }
    
    self.labelHeader.text= [NSString stringWithFormat:  @"@%@ %@",
                            object.publisherUsername.length ? object.publisherUsername :  @"unknown",
                            verb ?:  message];
    
    self.labelSubheader.text= [NSString stringWithFormat:  @"%@",
                               object.parameters.length ? object.parameters :  @"unknown"];

    NSURLRequest* req= nil;
    __weak FeedCell *weakSelf = self;

    if ( object.loadedImage) {
        self.photoImageView.image = object.loadedImage;
    }
    else if  (object.mediaItem.url.length  && (req= [NSURLRequest requestWithURL: [ NSURL URLWithString:object.mediaItem.url]])) {
        
        [self.photoImageView setImageWithURLRequest:req
                                   placeholderImage:nil
                                            success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                                object.loadedImage= image;
                                                
                                                ON_MAIN_THREAD(^ {
                                                    [weakSelf.delegate reloadCell: weakSelf.tag ];
                                                });
                                            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                object.mediaItem.url= nil;
                                                
                                                ON_MAIN_THREAD(^ {
                                                    [weakSelf.delegate reloadCell: weakSelf.tag ];
                                                });
                                            }];
    }
    else if  (object.mediaItem ) {
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantImageWithMediaItem:object.mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            [_photoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                   placeholderImage:nil
                                            success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                                object.loadedImage= image;
                                                
                                                ON_MAIN_THREAD(^ {
                                                    [weakSelf.delegate reloadCell: weakSelf.tag ];
                                                });
                                            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                NSLog  (@"UNABLE TO FETCH IMAGE.");
                                            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ON_MAIN_THREAD(^{
            });
        }];
    }
    
    NSUInteger  userid=  object.publisherID;
    UserObject* currentUser= [Settings sharedInstance].userObject;
    if  (userid== currentUser.userID) {
        UIImage* image= [currentUser userProfilePhoto];
        if ( image) {
            _iconImageView.image=image;
        }
    } else {
        [OOAPI lookupUserByID:userid
                      success:^(UserObject *user) {
                          if  (user.mediaItem ) {
                              NSString*  urlString=user.mediaItem.url;
                              [weakSelf.iconImageView setImageWithURL:[NSURL URLWithString:urlString]];
// XX: 
                          } else  if ( user.imageIdentifier) {
                              /* self.requestOperation =*/ [OOAPI getUserImageWithImageID: user.imageIdentifier
                                                                                 maxWidth:self.frame.size.height
                                                                                maxHeight:0
                                                                                  success:^(NSString *link) {
                                                                                      ON_MAIN_THREAD( ^{
                                                                                          [weakSelf.iconImageView setImageWithURL:[NSURL URLWithString:link]];
                                                                                      });
                                                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                      NSLog (@"CANNOT FETCH IMAGE FOR USER w/ ID  %lu", (unsigned long) userid);
                                                                                  }];
                              
                          } else {
                              NSLog (@"USER %lu HAS NO IMAGE", (unsigned long) userid);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog (@"CANNOT FETCH USER w/ ID  %lu", (unsigned long) userid);
                      }
         ];
        
    }
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
    CGFloat h = height(self);
    CGFloat w = width(self);
    float labelHeight= _labelHeader.intrinsicContentSize.height;
    float  margin= kGeomSpaceEdge;

    // for testing
    float iconSize= kGeomHeightFeedWithoutImageTableCellHeight-2*margin;
    _iconImageView.frame = CGRectMake(margin,margin,iconSize,iconSize);
    
    float x=  iconSize +2*margin, y=  margin;
    _labelHeader.frame = CGRectMake(x,y ,w-x,labelHeight);
    y += labelHeight;
    _labelSubheader.frame = CGRectMake(x,y,w-x,h/2);
    y += labelHeight;

    float pictureHeight= self.feedObject.loadedImage ? h-kGeomHeightFeedWithoutImageTableCellHeight: 0;
    _photoImageView.frame = CGRectMake(0,kGeomHeightFeedWithoutImageTableCellHeight,w,pictureHeight);
    
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

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    [self getFeed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.setOfUpdates= [NSMutableOrderedSet new];
    self.setOfNotifications= [NSMutableOrderedSet new];
    
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
//    _tableViewUpdates.translatesAutoresizingMaskIntoConstraints = NO;
        _tableViewUpdates.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewUpdates.backgroundColor = WHITE;
    [_tableViewUpdates registerClass:[FeedCell class] forCellReuseIdentifier:FeedCellID];
    
    self.tableViewNotifications = makeTable( self.view,  self);
//    _tableViewNotifications.translatesAutoresizingMaskIntoConstraints = NO;
        _tableViewNotifications.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewNotifications.backgroundColor = GRAY;
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
    [OOAPI getFeedItemsWithSuccess:^(NSArray *feedItems) {
        if  (!feedItems.count) {
            return;
        }
        unsigned long total= 0;
        for (FeedObject* item  in  feedItems) {
            if  (!item.isNotification ) {
                [weakSelf.setOfUpdates addObject: item];
            } else {
                [weakSelf.setOfNotifications addObject: item];
            }
            total ++;
            time_t t=  [item.publishedAt timeIntervalSince1970 ];
            if ( t>weakSelf.maximumTimestamp) {
                weakSelf.maximumTimestamp= t;
            }
        }
        NSLog  (@"REQUEST FOR FEED SUCCEEDED,  total=  %lu",total);
        
        ON_MAIN_THREAD(^ {
            [weakSelf.tableViewUpdates reloadData];
            [weakSelf.tableViewNotifications reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"REQUEST FOR FEED FAILED.");
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
    NSUInteger  row=  indexPath.row;
    cell.tag= row;
    cell.delegate=  self;

    FeedObject*object;
    if ( _buttonUpdates.selected) {
        object= [self.setOfUpdates  objectAtIndex:row];
    } else {
        object= [self.setOfNotifications  objectAtIndex:row];
    }
    [ cell provideFeedObject: object];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger  row=  indexPath.row;
    
    FeedObject*object;
    if ( _buttonUpdates.selected) {
        object= [self.setOfUpdates  objectAtIndex:row];
    } else {
        object= [self.setOfNotifications  objectAtIndex:row];
    }
    
    if ( object.loadedImage) {
        return kGeomHeightFeedWithImageTableCellHeight;
    } else {
        return kGeomHeightFeedWithoutImageTableCellHeight;
    }
}

- (void)reloadCell:(NSUInteger)which
{
    NSIndexPath* ip = [NSIndexPath indexPathForRow:which inSection:0];

    UITableView* table;
    if ( _buttonUpdates.selected) {
        table= _tableViewUpdates;
    } else {
        table= _tableViewNotifications;
    }
    [table reloadRowsAtIndexPaths: @[ip]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
