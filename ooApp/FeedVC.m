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
#import "OOFilterView.h"
#import "ProfileVC.h"
#import "RestaurantVC.h"

//------------------------------------------------------------------------------
@interface FeedCell()
@property (nonatomic,strong) FeedObject* feedObject;
@property (nonatomic,strong)  UIImageView *iconImageView;
@property (nonatomic,strong)  UILabel* labelVerb;
//@property (nonatomic,strong) UIButton* buttonObject;
@property (nonatomic,strong)  UILabel* labelDescription;
@property (nonatomic,strong) UIImageView* photoImageView;
@property (nonatomic,strong) UIButton* buttonIcon;
@property (nonatomic,strong) UIButton* buttonPhotoArea;
@property (nonatomic,strong) UIButton* buttonSubjectName;
@property (nonatomic,strong) UIButton* buttonIgnore;
@property (nonatomic,strong) UIButton* buttonAllow;
@property (nonatomic,strong) UIButton* buttonObjectName;
@property (nonatomic,strong) AFHTTPRequestOperation *restaurantImageOperation;
@property (nonatomic,strong) AFHTTPRequestOperation *userImageOperation;
@property (nonatomic,strong) AFHTTPRequestOperation *userObjectOperation;
@end

@implementation FeedCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=UIColorRGBA(kColorBlack);

        self.autoresizesSubviews= NO;
        self.iconImageView= makeImageView( self.contentView, APP.imageForNoProfileSilhouette);
        _iconImageView.backgroundColor= UIColorRGBA(kColorClear);
        self.labelVerb= makeLabelLeft(self.contentView, @"", kGeomFontSizeSubheader);
        _labelVerb.textColor= UIColorRGBA(kColorWhite);
        _labelVerb.font= [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeSubheader];
        self.labelDescription= makeLabelLeft(self.contentView, @"?", kGeomFontSizeSubheader);
        _labelDescription.textColor= UIColorRGBA(kColorWhite);
        self.selectionStyle= UITableViewCellSelectionStyleNone;
        
        self.photoImageView=makeImageView( self.contentView, nil);
        self.clipsToBounds= YES;
        _iconImageView.clipsToBounds= YES;
        _photoImageView.clipsToBounds= YES;
        _iconImageView.contentMode= UIViewContentModeScaleAspectFill;
        _photoImageView.contentMode= UIViewContentModeScaleAspectFill;
        
        self.buttonSubjectName= makeButton(self.contentView, @"", kGeomFontSizeSubheader, UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear), self, @selector(userTappedSubject:), 0);
        _buttonSubjectName.titleLabel.font= [UIFont fontWithName:kFontLatoBold size:kGeomFontSizeSubheader];
        _buttonSubjectName.titleLabel.textAlignment=NSTextAlignmentLeft;
        
        self.buttonIcon= makeButton(self.contentView, nil, 0, UIColorRGBA(kColorClear), UIColorRGBA(kColorClear), self, @selector(userTappedIcon:), 0);
        self.buttonPhotoArea= makeButton(self.contentView, nil, 0, UIColorRGBA(kColorClear), UIColorRGBA(kColorClear), self, @selector(userTappedPhotos:), 0);
        
        self.buttonObjectName=makeButton(self.contentView, @"", kGeomFontSizeSubheader, UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear), self, @selector(userTappedObject:), 0);
        _buttonObjectName.titleLabel.textAlignment=NSTextAlignmentLeft;
    }
    return self;
}

- (void)userTappedIcon: (id) sender
{
    if ( self.feedObject.subjectType==FEED_OBJECT_TYPE_USER) {
        [self.delegate userTappedOnUser: self.feedObject.subjectID];
    }
}

- (void)userTappedSubject: (id) sender
{
    if ( self.feedObject.subjectType==FEED_OBJECT_TYPE_USER) {
        [self.delegate userTappedOnUser: self.feedObject.subjectID];
    } else {
        [self.delegate userTappedOnEvent: self.feedObject.subjectID];
    }
}

- (void)userTappedObject: (id) sender
{
    switch (self.feedObject.subjectType) {
        case FEED_OBJECT_TYPE_USER:
            [self.delegate userTappedOnUser: self.feedObject.subjectID];
            break;
            
        default:
            break;
    }
}

- (void)userTappedPhotos: (id) sender
{
    [self.delegate userTappedOnRestaurantPhoto:  self.feedObject.objectID];
}

- (void)provideFeedObject: (FeedObject*)feedItem
{
    self.feedObject= feedItem;
    
    NSString* verb= feedItem.translatedMessage ?: feedItem.verb;
    if  ([verb isEqualToString: @"follow"] ) {
        verb= @"followed";
        // NOTE: direct object is a person.
    }
    else if ([verb isEqualToString: @"update"]) {
        // NOTE: direct object is an event.
    }
    
    if (feedItem.subjectType==FEED_OBJECT_TYPE_USER ) {
        [self.buttonSubjectName setTitle: feedItem.subjectName.length ? concatenateStrings( @"@",feedItem.subjectName) : @"@unknown"
                             forState:UIControlStateNormal];
    } else {
        [self.buttonSubjectName setTitle: feedItem.subjectName.length ? feedItem.subjectName : @"@unknown event"
                             forState:UIControlStateNormal];
    }
    
    self.labelVerb.text= [NSString stringWithFormat:  @"%@",
                            verb ?:  nil];
    
    NSString *objectNameString= feedItem.objectName.length ? feedItem.objectName :  @"unknown";
    [_buttonObjectName setTitle:objectNameString forState:UIControlStateNormal];
    
    self.labelDescription.text=  @"";

    NSURLRequest* req= nil;
    __weak FeedCell *weakSelf = self;
    
    if ( feedItem.loadedImage) {
        self.photoImageView.image = feedItem.loadedImage;
    }
    else if  (feedItem.mediaItem.url.length  && (req= [NSURLRequest requestWithURL: [ NSURL URLWithString: feedItem.mediaItem.url]])) {
        
        [self.photoImageView setImageWithURLRequest:req
                                   placeholderImage:nil
                                            success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                                feedItem.loadedImage= image;
                                                
                                                ON_MAIN_THREAD(^ {
                                                    [weakSelf.delegate reloadCell: weakSelf.tag ];
                                                });
                                            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                feedItem.mediaItem.url= nil;
                                                
                                                ON_MAIN_THREAD(^ {
                                                    [weakSelf.delegate reloadCell: weakSelf.tag ];
                                                });
                                            }];
    }
    else if  (feedItem.mediaItem ) {
        OOAPI *api = [[OOAPI alloc] init];
        self.restaurantImageOperation= [api getRestaurantImageWithMediaItem: feedItem.mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            [_photoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                   placeholderImage:nil
                                            success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                                feedItem.loadedImage= image;
                                                
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
    
    NSUInteger  userid=  feedItem.subjectID;
    UserObject *currentUser= [Settings sharedInstance].userObject;
    UIImage *currentUserImage= nil;
    if (feedItem.subjectID==currentUser.userID  && (currentUserImage= [currentUser userProfilePhoto ])) {
        self.photoImageView.image = currentUserImage;
    }
    else {
        self.userObjectOperation= [OOAPI lookupUserByID: userid
                                                success:^(UserObject *user) {
                                                    if  (user.mediaItem.url ) {
                                                        NSString*  urlString=user.mediaItem.url;
                                                        [weakSelf.iconImageView setImageWithURL:[NSURL URLWithString:urlString]];
                                                    }
                                                    else if ( user.imageIdentifier) {
                                                        self.userImageOperation=  [OOAPI getUserImageWithImageID: user.imageIdentifier
                                                                                                        maxWidth: self.frame.size.height
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
    [self.userObjectOperation  cancel];
    self.userObjectOperation= nil;
    
    [_userImageOperation cancel];
    self.userImageOperation= nil;
    
    [_restaurantImageOperation cancel];
    self.restaurantImageOperation= nil;
    
    _iconImageView.image= APP.imageForNoProfileSilhouette;
    _photoImageView.image= nil;
    _labelVerb.text=nil;
    _labelDescription.text=nil;
    [_buttonSubjectName setTitle:@"" forState:UIControlStateNormal];
    [_buttonObjectName setTitle:@"" forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat h = height(self);
    CGFloat w = width(self);
    float labelHeight= _labelVerb.intrinsicContentSize.height;
    float  margin= kGeomSpaceEdge;

    // for testing
    float iconSize= kGeomHeightFeedWithoutImageTableCellHeight-2*margin;
    _iconImageView.frame = CGRectMake(margin,margin,iconSize,iconSize);
    _buttonIcon.frame = _iconImageView.frame;
    
    float x=  iconSize +2*margin, y=  margin;
    [_buttonSubjectName sizeToFit];
    float bw= _buttonSubjectName.intrinsicContentSize.width;
    _buttonSubjectName.frame = CGRectMake(x,y ,bw,labelHeight);
    _labelVerb.frame = CGRectMake(bw + kGeomSpaceInter +x,y ,w-x,labelHeight);
    y += labelHeight;
    
    [_buttonObjectName sizeToFit];
    bw= _buttonObjectName.intrinsicContentSize.width;
    _buttonObjectName.frame = CGRectMake(x,y,bw,labelHeight);

    float pictureHeight= self.feedObject.loadedImage ? h-kGeomHeightFeedWithoutImageTableCellHeight: 0;
    _photoImageView.frame = CGRectMake(0,kGeomHeightFeedWithoutImageTableCellHeight,w,pictureHeight);
    _buttonPhotoArea.frame=_photoImageView.frame;
    
    [self.contentView bringSubviewToFront: _buttonIcon];
    [self.contentView bringSubviewToFront: _buttonPhotoArea];

}

- (void)dealloc
{
    self.buttonIcon= nil;
    self.iconImageView= nil;
    self.labelVerb= nil;
    self.labelDescription= nil;
    self.photoImageView= nil;
    
}

@end

//------------------------------------------------------------------------------
@interface FeedVC ()
@property (nonatomic, strong) UITableView *tableViewUpdates;
@property (nonatomic, strong) UITableView *tableViewNotifications;
@property (nonatomic, strong) NSMutableOrderedSet *setOfUpdates;
@property (nonatomic, strong) NSMutableOrderedSet *setOfNotifications;
@property (nonatomic,assign)  time_t maximumTimestamp;
@property (nonatomic,strong) OOFilterView *filterView;
@property (nonatomic,assign) int currentFilter;

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
    
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [APP registerForPushNotifications];
    }
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    [self getFeed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.setOfUpdates= [NSMutableOrderedSet new];
    self.setOfNotifications= [NSMutableOrderedSet new];
    
    self.filterView= [[OOFilterView alloc] init];
    [ self.view addSubview:_filterView];
    [_filterView addFilter:LOCAL(@"Updates") target:self selector:@selector(userPressedUpdates:)];
    [_filterView addFilter:LOCAL(@"Notifications") target:self selector:@selector(userPressedNotifications:)];
    _currentFilter= 0;
    [_filterView setCurrent:0];
    
    self.tableViewUpdates = makeTable( self.view,  self);
//    _tableViewUpdates.translatesAutoresizingMaskIntoConstraints = NO;
        _tableViewUpdates.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewUpdates.backgroundColor = UIColorRGBA(kColorWhite);
    [_tableViewUpdates registerClass:[FeedCell class] forCellReuseIdentifier:FeedCellID];
    
    self.tableViewNotifications = makeTable( self.view,  self);
//    _tableViewNotifications.translatesAutoresizingMaskIntoConstraints = NO;
        _tableViewNotifications.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewNotifications.backgroundColor = UIColorRGBA(kColorOffWhite);
    [_tableViewNotifications registerClass:[FeedCell class] forCellReuseIdentifier:FeedCellID];
    
//    _tableViewUpdates.opaque= YES;
//    _tableViewNotifications.opaque= YES;
    _tableViewUpdates.delaysContentTouches= NO;
    _tableViewNotifications.delaysContentTouches= NO;
    _tableViewUpdates.showsVerticalScrollIndicator= NO;
    _tableViewNotifications.showsVerticalScrollIndicator= NO;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Feed" subHeader:@""];
    self.navTitle = nto;
}

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
    
    _filterView.frame = CGRectMake(kGeomSpaceEdge,y,w-2*kGeomSpaceEdge, kGeomHeightButton);
    y+=kGeomHeightButton;
    
    _tableViewUpdates.frame = CGRectMake(kGeomSpaceEdge, y, w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
    _tableViewNotifications.frame = CGRectMake(kGeomSpaceEdge, y, w-2*kGeomSpaceEdge, h-y-kGeomSpaceEdge);
    _tableViewUpdates.backgroundColor=UIColorRGBA(kColorBlack);
    _tableViewNotifications.backgroundColor=UIColorRGBA(kColorBlack);
    
    BOOL firstIsSelected= _currentFilter==0;
    _tableViewUpdates.userInteractionEnabled= firstIsSelected;
    _tableViewUpdates.alpha= firstIsSelected?1:0;
    _tableViewNotifications.userInteractionEnabled= !firstIsSelected;
    _tableViewNotifications.alpha= firstIsSelected?0:1;
}

- (void)userPressedUpdates: (id) sender
{
    if  (!_currentFilter) {
        return;
    }
    
    [UIView animateWithDuration:.4 animations:^{
        _currentFilter= 0;
        [  self doLayout];
    }];
    
    [_tableViewUpdates  reloadData];
}

- (void)userPressedNotifications: (id) sender
{
    if  (_currentFilter) {
        return;
    }
    
    [UIView animateWithDuration:.4 animations:^{
        _currentFilter= 1;
        [  self doLayout];
    }];
    
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
    if (!_currentFilter) {
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
    if ( !_currentFilter) {
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
    if ( !_currentFilter) {
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
    if ( !_currentFilter) {
        table= _tableViewUpdates;
    } else {
        table= _tableViewNotifications;
    }
    [table reloadRowsAtIndexPaths: @[ip]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) userTappedOnList:(NSUInteger)listID;
{
    NSLog  (@"USER TAPPED ON LIST THAT IS IN FEED");
}

- (void) userTappedOnUser:(NSUInteger)userid;
{
    __weak  FeedVC *weakSelf = self;
    [OOAPI lookupUserByID: userid
                  success:^(UserObject *user) {
                      ProfileVC*vc= [[ProfileVC alloc] init];
                      vc.userInfo= user;
                      vc.userID=  user.userID;
                      [weakSelf.navigationController  pushViewController:vc animated:YES];
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog (@"CANNOT FETCH USER w/ ID  %lu", (unsigned long) userid);
                  }
     ];
}

- (void) userTappedOnRestaurantPhoto:(NSUInteger)restaurantID;
{
    NSLog  (@"USER TAPPED ON PHOTO THAT IS IN FEED");

    RestaurantVC *vc = [[RestaurantVC alloc] init];
    RestaurantObject*object= [[RestaurantObject alloc] init];
     object.name= @"Not in feed yet";
    object.location= CLLocationCoordinate2DMake(37, -122);
    vc.restaurant = (RestaurantObject*) object;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) userTappedOnEvent:(NSUInteger)eventID;
{
    NSLog  (@"USER TAPPED ON EVENT THAT IS IN FEED");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
