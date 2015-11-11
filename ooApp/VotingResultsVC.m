//
//  VotingResultsVC.m
//  ooApp
//
//  Created by Zack Smith on 10/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "VotingResultsVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "ListTVCell.h"
#import "EventWhenVC.h"
#import "RestaurantVC.h"

@interface VotingResultsFirstCell ()

@property (nonatomic, strong) UIButton *buttonSubmitVote;
@property (nonatomic, strong) UIButton *buttonGears;
@property (nonatomic, strong) UILabel *labelTimeLeft;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) EventObject *event;

@end

@implementation  VotingResultsFirstCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super  initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor= GRAY;
        self.backgroundImageView=  makeImageView( self,  @"background-image.jpg" );
        self.backgroundImageView.contentMode= UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds= YES;
        self.labelTimeLeft= makeLabel( self,  @"00:00", 17);
        _labelTimeLeft.textColor= WHITE;
        _labelTimeLeft.layer.borderWidth= 1;
        _labelTimeLeft.layer.borderColor= WHITE.CGColor;
        
        _buttonSubmitVote= makeButton(self,  @"VOTES SUBMITTED", kGeomFontSizeHeader,
                                      WHITE, CLEAR, self, @selector(doSubmitVote:), 1);
    }
    
    return self;
}

- (void)layoutSubviews
{
    float h=  self.bounds.size.height;
    float w=  self.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    
    _backgroundImageView.frame= self.bounds;
    
#define kGeomVotingResultsBoxHeight 175
#define kGeomVotingResultsRestaurantHeight 100
    float biggerButtonWidth=w/2-3*margin/2;

    _buttonSubmitVote.frame=  CGRectMake( margin,h-kGeomHeightButton-margin, biggerButtonWidth,kGeomHeightButton);
    
    float x=  _buttonSubmitVote.frame.origin.x  + _buttonSubmitVote.frame.size.width;
    x += kGeomSpaceInter;
    _labelTimeLeft.frame = CGRectMake(w/2+ margin/2,h-kGeomHeightButton- margin, biggerButtonWidth, kGeomHeightButton);
}

- (void) provideEvent: (EventObject*)event;
{
    self.event= event;
    
    if  (event.primaryVenueImageIdentifier ) {
        __weak VotingResultsFirstCell *weakSelf = self;
        OOAPI *api = [[OOAPI alloc] init];
        /* _imageOperation=*/ [api getRestaurantImageWithImageRef: event.primaryVenueImageIdentifier
                                                         maxWidth:self.frame.size.width
                                                        maxHeight:0
                                                          success:^(NSString *link) {
                                                              ON_MAIN_THREAD(  ^{
                                                                  [weakSelf.backgroundImageView
                                                                   setImageWithURL:[NSURL URLWithString:link]
                                                                   placeholderImage:nil];
                                                              });
                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          }];

    }
}

//------------------------------------------------------------------------------
// Name:    doSubmitVote
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmitVote: (id) sender
{
//    [_delegate userRequestToSubmit];
}

@end

//==============================================================================

@interface VotingResultsVotingCell ()
@property (nonatomic,strong)  UILabel *labelResult;
@property (nonatomic,strong)  UIImageView *thumbnail;
@property (nonatomic,strong)   UILabel *labelName;
@property (nonatomic,strong) EventObject* event;
@property (nonatomic,assign) BOOL showOnlyMessage;
@property (nonatomic,strong)  AFHTTPRequestOperation *imageOperation;

@end

@implementation VotingResultsVotingCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumbnail= makeImageView(self, nil);
        _thumbnail.contentMode= UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds= YES;
        
        _labelResult= makeLabel(self,  @"", kGeomFontSizeHeader);

        _labelName= makeLabelLeft( self,  @"", kGeomFontSizeHeader);
        self.textLabel.hidden= YES;
        self.imageView.hidden= YES;
        _thumbnail.layer.borderColor= GRAY.CGColor;
        _thumbnail.layer.borderWidth= 1;
        
    }
    return self;
}

- (void) layoutSubviews
{
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    
    if  (_showOnlyMessage ) {
        _thumbnail.hidden= YES;
        _labelResult.hidden= YES;
        _labelName.frame = CGRectMake(0,0,w,h);
        _labelName.textAlignment= NSTextAlignmentCenter;
    } else {
        float x= kGeomSpaceEdge;
        _thumbnail.frame = CGRectMake(x,0,h,h);
        x += h+kGeomSpaceInter;
        _labelName.frame = CGRectMake(x,0,w-x-kGeomButtonWidth-2*kGeomSpaceInter,h);
        x += _labelName.frame.size.width;
        _labelResult.frame = CGRectMake(x,(h-kGeomHeightButton)/2,kGeomButtonWidth,kGeomHeightButton);
        _labelName.textAlignment= NSTextAlignmentLeft;

        _thumbnail.hidden= NO;
        _labelResult.hidden= NO;
    }
}

- (void)prepareForReuse
{
    [_imageOperation cancel];
    self.imageOperation= nil;
    _showOnlyMessage= NO;
    _labelResult.text= nil;
    self.labelName.text= nil;
    self.thumbnail.image= nil;
    self.vote= nil;
    self.event= nil;
}

- (void)indicateMissingVoteFor: (RestaurantObject*)venue
{
    self.vote= [[VoteObject alloc] init];
    self.vote.venueID= venue.restaurantID;
}


- (void)provideVenue: (RestaurantObject*) venue
{
    _labelResult.text= [NSString stringWithFormat: @"%ld point%c",(  long) venue.totalVotes,venue.totalVotes != 1 ?'s':0];

    NSInteger venueID= self.vote.venueID;

    if  (!venue) {
        NSLog (@"VENUE ID %lu APPEARS TO BE BOGUS.",( unsigned long)venueID);
        self.labelName.text=  @"";
        self.thumbnail.image= nil;
        return;
    }
    
    self.labelName.text= venue.name;
    
    OOAPI *api = [[OOAPI alloc] init];
    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];
    float h= self.frame.size.height;
    
    if  (venue.mediaItems.count ) {
        __weak VotingResultsVotingCell *weakSelf = self;
        self.imageOperation= [api getRestaurantImageWithImageRef:   ( (MediaItemObject*)venue.mediaItems[0]).reference
                                                        maxWidth:0
                                                       maxHeight:h
                                                         success:^(NSString *link) {
                                                             ON_MAIN_THREAD(  ^{
                                                                 [weakSelf.thumbnail
                                                                  setImageWithURL:[NSURL URLWithString:link]
                                                                  placeholderImage:placeholder];
                                                             });
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             [weakSelf.thumbnail setImage:placeholder];
                                                         }];
    } else {
        self.thumbnail.image= placeholder;
    }
}


@end

//==============================================================================

@interface VotingResultsVC ()
@property (nonatomic,strong)  UITableView * table;
@property (nonatomic,strong) NSMutableArray* sortedArrayOfVenues;
@end

@implementation VotingResultsVC
{
}

- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= [UIColor lightGrayColor];

    self.sortedArrayOfVenues= [NSMutableArray new];
    
    NSString* eventName= self.eventBeingEdited.name;
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;
    
    _table= makeTable( self.view,  self);
#define TABLE_REUSE_IDENTIFIER  @"participantsCell"
#define TABLE_REUSE_FIRST_IDENTIFIER @"participantsCell1st"
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    
    [_table registerClass:[VotingResultsVotingCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    [_table registerClass:[VotingResultsFirstCell class] forCellReuseIdentifier:TABLE_REUSE_FIRST_IDENTIFIER];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    __weak VotingResultsVC *weakSelf = self;
    if (! [self.eventBeingEdited totalVenues ]) {
        /* _venueOperation=*/ [self.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
            [weakSelf fetchTallies];
        }
                                                                               failure:^{
                                                                                   NSLog (@"FAILED TO FETCH VENUES");
                                                                               }];
    } else {
        [self fetchTallies];
    }
    
}

- (void)fetchTallies
{
    __weak VotingResultsVC *weakSelf = self;
    
    for (RestaurantObject* venue  in  self.eventBeingEdited.venues ) {
        venue.totalVotes= 0;
    }
 
    [self.eventBeingEdited refreshVotesFromServerWithSuccess:^{
        NSMutableDictionary *dictionary= [NSMutableDictionary  new];
        for (RestaurantObject* venue in weakSelf.eventBeingEdited.venues) {
            [dictionary setObject: venue forKey:[NSString stringWithFormat: @"%lu", (unsigned long) venue.restaurantID] ];
        }
        
        for (VoteObject* vote  in weakSelf.eventBeingEdited.votes) {
            NSString *index= [NSString stringWithFormat: @"%lu", (unsigned long)vote.venueID ];
            RestaurantObject*venue= dictionary[ index];
            venue.totalVotes += vote.vote;
        }
        [self.sortedArrayOfVenues removeAllObjects];
        for (RestaurantObject* venue in weakSelf.eventBeingEdited.venues) {
            [_sortedArrayOfVenues addObject: venue];
        }
        [_sortedArrayOfVenues sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            RestaurantObject*r1= obj1;
            RestaurantObject*r2= obj2;
            if ( r1.totalVotes > r2.totalVotes) {
                return NSOrderedAscending;
            } else if ( r1.totalVotes  < r2.totalVotes) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
    } failure:^{
        NSLog  (@"FAILED TO FETCH VOTE TALLIES.");
        [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
    }];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventObject* event=self.eventBeingEdited;
    
    NSInteger row=  indexPath.row;
    if  (!row) {
        VotingResultsFirstCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_FIRST_IDENTIFIER forIndexPath:indexPath];
        cell.delegate= self;
        [cell provideEvent: event];
        return cell;
    }
    
    VotingResultsVotingCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.delegate= self;
    
    NSUInteger count=_sortedArrayOfVenues.count;
    if  (!count  && !event.numberOfVenues) {
        cell.showOnlyMessage= YES;
        cell.labelName.text=  @"This event has no restaurants.";
        return cell;
    }
    row--;
    
    if ( row  < count) {
        RestaurantObject* venue= _sortedArrayOfVenues[row];
        [cell provideVenue: venue ];
        
        NSLog  (@"ROW %d HAS VOTE %d",row,venue.totalVotes);
    } else {
        [cell provideVenue: nil ];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if  (!row) {
        return  120;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row=  indexPath.row;
    if  (!row) {
        return;
    }
    RestaurantObject* venue= _sortedArrayOfVenues[row-1];
    RestaurantVC*vc= [[RestaurantVC alloc] init];
    vc.restaurant= venue;
    vc.eventBeingEdited= self.eventBeingEdited;
    [self.navigationController  pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count=[self.eventBeingEdited  totalVenues ];
    if  (!count  && !self.eventBeingEdited.numberOfVenues) {
        return 2;
    }
    return 1+count;
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    _table.frame=  self.view.bounds;
}

@end
