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
@property (nonatomic, strong) UILabel *labelPersonIcon;
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
        self.labelPersonIcon= makeIconLabel ( self,  kFontIconPerson, 25);
        
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
    _labelPersonIcon.frame = CGRectMake(w-kGeomButtonWidth- margin,h-kGeomHeightButton-margin, kGeomButtonWidth, kGeomHeightButton);
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
                                                          } failure:^(NSError *error) {
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
@property (nonatomic,strong)  AFHTTPRequestOperation *imageOperation;

@end

@implementation VotingResultsVotingCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumbnail= makeImageView(self, nil);
        _labelResult= makeLabel(self,  @"result", kGeomFontSizeHeader);

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
    float x= kGeomSpaceEdge;
    _thumbnail.frame = CGRectMake(x,0,h,h);
    x += h+kGeomSpaceInter;
    _labelName.frame = CGRectMake(x,0,w-x-kGeomButtonWidth-2*kGeomSpaceInter,h);
    x += _labelName.frame.size.width;
    _labelResult.frame = CGRectMake(x,(h-kGeomButtonWidth)/2,kGeomButtonWidth,h);
}

- (void)provideVote: (VoteObject*)vote
{
    self.vote= vote;
    _labelResult.text= [NSString stringWithFormat: @"%ld",vote. vote];
}

- (void)prepareForReuse
{
    [_imageOperation cancel];
    self.imageOperation= nil;
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

- (void) provideEvent: (EventObject*)event
{
    if  (!event) {
        return;
    }
    
    if  (!self.vote) {
        NSLog (@"MISSING VOTE INFORMATION");
        return;
    }
    
    self.event= event;
    NSInteger venueID= self.vote.venueID;
    RestaurantObject* venue = [event lookupVenueByID: venueID];

    self.vote.eventID= event.eventID;

    if  (!venue) {
        NSLog (@"VENUE ID %ld APPEARS TO BE BOGUS.",venueID);
        self.labelName.text=  @"Unknown restaurant.";
        self.thumbnail.image= nil;
    }
    else {
        self.labelName.text= venue.name;
        
        OOAPI *api = [[OOAPI alloc] init];
        UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];
        float h= self.frame.size.height;

        if  (event.primaryVenueImageIdentifier ) {
            __weak VotingResultsVotingCell *weakSelf = self;
            self.imageOperation= [api getRestaurantImageWithImageRef: event.primaryVenueImageIdentifier
                                                       maxWidth:0
                                                      maxHeight:h
                                                        success:^(NSString *link) {
                                                            ON_MAIN_THREAD(  ^{
                                                                [weakSelf.thumbnail
                                                                 setImageWithURL:[NSURL URLWithString:link]
                                                                 placeholderImage:placeholder];
                                                            });
                                                        } failure:^(NSError *error) {
                                                            [weakSelf.thumbnail setImage:placeholder];
                                                        }];
        }
    }
}


@end

//==============================================================================

@interface VotingResultsVC ()
@property (nonatomic,strong)  UITableView * table;
@property (nonatomic,strong) NSMutableArray* arrayOfVenues;
@end

@implementation VotingResultsVC
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    self.arrayOfVenues= [NSMutableArray new];
    
    NSString* eventName= APP.eventBeingEdited.name;
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _table= makeTable( self.view,  self);
#define TABLE_REUSE_IDENTIFIER  @"participantsCell"
#define TABLE_REUSE_FIRST_IDENTIFIER @"participantsCell1st"
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    
    [_table registerClass:[VotingResultsVotingCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    [_table registerClass:[VotingResultsFirstCell class] forCellReuseIdentifier:TABLE_REUSE_FIRST_IDENTIFIER];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    __weak VotingResultsVC *weakSelf = self;
    if (! [APP.eventBeingEdited totalVenues ]) {
        /* _venueOperation=*/ [APP.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
            [weakSelf.table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
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
    [OOAPI getVoteTalliesForEvent:APP.eventBeingEdited.eventID
                          success:^(NSArray *venues) {
                              [weakSelf.arrayOfVenues removeAllObjects];
                              [weakSelf.arrayOfVenues addObjectsFromArray:venues];
                              [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
                              
                          } failure:^(NSError *error) {
                              NSLog  (@"FAILED TO FETCH VOTE TALLIES.");
                              
                          }];
    
    
}

- (void) userPressedCancel: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES ];
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
    EventObject* event=APP.eventBeingEdited;
    
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

    RestaurantObject* venue= _arrayOfVenues[row-1];

    NSUInteger venueID = venue.restaurantID;
    VoteObject *voteForRow=[event lookupVoteByVenueID:venueID];

    if (voteForRow ) {
        [cell provideVote:voteForRow];
    } else {
        [cell indicateMissingVoteFor:venue ];
    }
    [cell provideEvent:event ];
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
    RestaurantObject* venue= _arrayOfVenues[row-1];
    RestaurantVC*vc= [[RestaurantVC alloc] init];
    vc.restaurant= venue;
    [self.navigationController  pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1+[_arrayOfVenues count];
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
