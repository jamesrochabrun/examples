//
//  EventParticipantVC.m E13
//  ooApp
//
//  Created by Zack Smith on 9/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "EventParticipantVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "ListTVCell.h"
#import "EventWhenVC.h"
#import "ParticipantsView.h"

#import  <QuartzCore/CALayer.h>

@interface EventParticipantEmptyCell()
@property (nonatomic,strong)  UILabel *labelCentered;
@end

@implementation EventParticipantEmptyCell
- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _labelCentered= makeLabel(self, @"This event has no restaurants.", kGeomFontSizeHeader);

    }
    return self;
}

- (void)layoutSubviews
{
    _labelCentered.frame= self.bounds;
}
@end

@interface EventParticipantFirstCell ()

@property (nonatomic, strong) UIButton *buttonSubmitVote;
@property (nonatomic, strong) UIButton *buttonGears;
@property (nonatomic, strong) UILabel *labelTimeLeft;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelDateTime;
@property (nonatomic, strong) UILabel *labelPersonIcon;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) EventObject *event;
@property (nonatomic, strong) NSTimer  *timerCountdown;
@property (nonatomic,strong) ParticipantsView* participantsView;
@end

@implementation  EventParticipantFirstCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super  initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.viewShadow= makeView( self, WHITE);
        addShadowTo (_viewShadow);

        self.clipsToBounds= NO;
        self.backgroundColor= CLEAR;
        
        self.participantsView= [[ParticipantsView alloc] init];
        [self  addSubview: _participantsView];
        
        self.backgroundImageView=  makeImageView( self,  @"background-image.jpg" );
        self.backgroundImageView.contentMode= UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds= YES;

        self.labelDateTime= makeLabel( self, expressLocalDateTime( APP.eventBeingEdited.date), kGeomFontSizeSubheader);
        _labelDateTime.textColor= WHITE;
        _labelDateTime.font= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
        
        self.labelTitle= makeLabel( self, APP.eventBeingEdited.name,
                                   kGeomEventHeadingFontSize);
        _labelTitle.textColor= WHITE;
        _labelTitle.font= [UIFont  fontWithName: kFontLatoBoldItalic size:kGeomEventHeadingFontSize];

        self.labelTimeLeft= makeLabel( self,  @"TIME UNTIL\rVOTING CLOSES", kGeomFontSizeSubheader);
        _labelTimeLeft.textColor= WHITE;
        _labelTimeLeft.backgroundColor= UIColorRGBA(0x80000000);
        
        _buttonSubmitVote= makeButton(self,  @"SUBMIT VOTE", kGeomFontSizeSubheader,
                                      YELLOW,  UIColorRGBA(0x80000000), self, @selector(doSubmitVote:), 0);
        _buttonSubmitVote.titleLabel.font= [UIFont fontWithName:kFontLatoBold
                                                           size:kGeomFontSizeSubheader];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float h=  self.bounds.size.height;
    float w=  self.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float spacing= 9;
    h-= kGeomEventParticipantSeparatorHeight;
    
    _backgroundImageView.frame = CGRectMake(margin,0,w-2*margin,h);
    _viewShadow.frame=  _backgroundImageView.frame;

#define kGeomEventParticipantButtonHeight 33
    
    float y= kGeomEventParticipantFirstBoxHeight- kGeomEventParticipantButtonHeight
        - kGeomEventHeadingFontSize-kGeomFontSizeSubheader-kGeomHeightButton - 3*spacing;
    _labelTitle.frame = CGRectMake(0,y,w,kGeomEventHeadingFontSize);
    y += kGeomEventHeadingFontSize +spacing;
    _labelDateTime.frame = CGRectMake(0,y,w,kGeomFontSizeSubheader);
    y+= kGeomFontSizeSubheader +spacing;
    _labelPersonIcon.frame = CGRectMake(0,y, w, kGeomHeightButton);
    
    float distanceBetweenButtons= 4;
    float biggerButtonWidth= (w-2*margin-distanceBetweenButtons)/2;

    _buttonSubmitVote.frame=  CGRectMake(  margin, h-kGeomEventParticipantButtonHeight, biggerButtonWidth,kGeomEventParticipantButtonHeight);
    
    _labelTimeLeft.frame = CGRectMake(  w/2+ distanceBetweenButtons/2,h-kGeomEventParticipantButtonHeight, biggerButtonWidth, kGeomEventParticipantButtonHeight);
    
    [self.participantsView setNeedsLayout];
}

- (void) provideEvent: (EventObject*)event;
{
    self.event= event;
 
    NSDate* dv=self.event.dateWhenVotingClosed;
    unsigned long votingEnds= [dv timeIntervalSince1970];
    if (!votingEnds) {
        _labelTimeLeft.attributedText=attributedStringOf( @"END OF VOTING\rDATE NOT SET", kGeomFontSizeSubheader);
        return;
    }
    
    unsigned long now= [[NSDate date ] timeIntervalSince1970];
    if  ( now < votingEnds) {
        self.timerCountdown= [ NSTimer  scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(callbackCountdown:)
                                                              userInfo:nil repeats:YES];

    }
    
    __weak EventParticipantFirstCell *weakSelf = self;

    if  (event.primaryImage) {
        self.backgroundImageView.image= event.primaryImage;
    }
    else if  (event.primaryVenueImageIdentifier ) {
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
                                                          } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                                          }];
        
    }
    
    [self refreshUsers];
}

- (void)callbackCountdown: ( NSTimer *) timer
{
     long votingEnds= [self.event.dateWhenVotingClosed timeIntervalSince1970];
     long now= [[NSDate date ] timeIntervalSince1970];
     long  timeRemaining= votingEnds-now;
    if ( timeRemaining <= 0) {
        _labelTimeLeft.attributedText=attributedStringOf( @"VOTING HAS ENDED", kGeomFontSizeHeader);
        [self.timerCountdown  invalidate];
        self.timerCountdown= nil;
        return;
    }
    
    unsigned long  hours= timeRemaining/3600;
    unsigned long  minutes=  (timeRemaining/60)% 60;
    unsigned long  seconds=  timeRemaining% 60;
    NSString* string= [NSString  stringWithFormat: @"%ld:%02ld:%02ld", hours, minutes, seconds];
    NSAttributedString* s= attributedStringOf(string, kGeomFontSizeHeader);
    NSMutableAttributedString *mas=[[NSMutableAttributedString  alloc] initWithAttributedString: s];
    NSAttributedString* lowerString= attributedStringOf( @"\rUNTIL VOTING CLOSES", kGeomFontSizeDetail);

    [mas  appendAttributedString:lowerString];
    _labelTimeLeft.attributedText= mas;
}

- (void) refreshUsers
{
    __weak EventParticipantFirstCell *weakSelf = self;
    
    [self.event refreshUsersFromServerWithSuccess:^{
        [weakSelf.participantsView setEvent: weakSelf.event];

    } failure:^{
        NSLog (@"UNABLE TO REFRESH PARTICIPANTS OF EVENT");
    }];
}

//------------------------------------------------------------------------------
// Name:    doSubmitVote
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmitVote: (id) sender
{
    [_delegate userRequestToSubmit];
}

- (void)prepareForReuse
{
    [_timerCountdown  invalidate];
    self.timerCountdown= nil;
    self.event= nil;
}
@end

//==============================================================================

@interface EventParticipantVotingCell ()
@property (nonatomic,strong) UIButton* radioButton;
@property (nonatomic,strong)  UIImageView *thumbnail;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic,strong)   UILabel *labelName;
@property (nonatomic,strong) EventObject* event;
@property (nonatomic,strong)  AFHTTPRequestOperation *imageOperation;

@end

@implementation EventParticipantVotingCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.viewShadow= makeView( self, WHITE);
        _viewShadow.layer.shadowOffset= CGSizeMake ( 2, 2);
        _viewShadow.layer.shadowColor= BLACK.CGColor;
        _viewShadow.layer.shadowOpacity= .5;
        _viewShadow.layer.shadowRadius= 4;
        _viewShadow.clipsToBounds= NO;
        _viewShadow.layer.borderColor= GRAY.CGColor;
        _viewShadow.layer.borderWidth= .5;
        
        self.clipsToBounds= NO;
        self.backgroundColor= CLEAR;
        
        _radioButton= makeButton(self, kFontIconEmptyCircle, kGeomFontSizeDetail, BLACK, CLEAR, self, @selector(userPressedRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmark forState:UIControlStateSelected];
        _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
        
        _thumbnail= makeImageView(self, nil);
        
        _labelName= makeLabelLeft( self,  @"", kGeomFontSizeHeader);
        self.textLabel.hidden= YES;
        self.imageView.hidden= YES;
        _thumbnail.layer.borderColor= GRAY.CGColor;
        _thumbnail.layer.borderWidth= 1;
        
    }
    return self;
}

- (void)userPressedRadioButton: (id) sender
{
    _radioButton.selected= !_radioButton.selected;
    self.vote.vote= _radioButton.selected  ? 1:0;
    if  ( self.delegate) {
        [self.delegate voteChanged:self.vote  ];
        
    }
}

- (void) layoutSubviews
{
    CGSize switchSize= CGSizeMake(kGeomHeightButton, kGeomHeightButton);
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    float x= kGeomSpaceEdge;
    h-= kGeomEventParticipantSeparatorHeight;

    _viewShadow.frame = CGRectMake(x,0,w-2*kGeomSpaceEdge,h);
    
    _thumbnail.frame = CGRectMake(x,0,h,h);
    x += h+kGeomSpaceInter;
    _labelName.frame = CGRectMake(x,0,w-x-switchSize.width-2*kGeomSpaceInter,h);
    x += _labelName.frame.size.width;
    _radioButton.frame = CGRectMake(x,(h-switchSize.height)/2,switchSize.width,switchSize.height);
}

- (void)switchChanged: (UISwitch*)theSwitch
{
    self.vote.vote= theSwitch.on? 1:0;
    if  ( self.delegate) {
        [self.delegate voteChanged:self.vote  ];

    }
}

- (void)provideVote: (VoteObject*)vote
{
    self.vote= vote;
    _radioButton.selected= vote.vote != 0;
}

- (void)prepareForReuse
{
    [_imageOperation cancel];
    self.imageOperation= nil;
    self.radioButton.selected= NO;
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
            __weak EventParticipantVotingCell *weakSelf = self;
            self.imageOperation= [api getRestaurantImageWithImageRef: event.primaryVenueImageIdentifier
                                                       maxWidth:0
                                                      maxHeight:h
                                                        success:^(NSString *link) {
                                                            ON_MAIN_THREAD(  ^{
                                                                [weakSelf.thumbnail
                                                                 setImageWithURL:[NSURL URLWithString:link]
                                                                 placeholderImage:placeholder];
                                                            });
                                                        } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                                            [weakSelf.thumbnail setImage:placeholder];
                                                        }];
        }
    }
}

@end

//==============================================================================

@interface EventParticipantVC ()
@property (nonatomic,strong)  UITableView * table;
@end

@implementation EventParticipantVC
{
}

- (void)viewDidLoad
{
    ENTRY;
   [super viewDidLoad];
    
    NSString* eventName= APP.eventBeingEdited.name;
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;
    
    self.navigationController.navigationItem.rightBarButtonItem= nil;
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= [UIColor lightGrayColor];
    
    _table= makeTable( self.view,  self);
#define TABLE_REUSE_IDENTIFIER  @"participantsCell"  
#define TABLE_REUSE_FIRST_IDENTIFIER @"participantsCell1st"
#define TABLE_EMPTY_REUSE_IDENTIFIER  @"participantsEmpty"
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;

    [_table registerClass:[EventParticipantEmptyCell class] forCellReuseIdentifier:TABLE_EMPTY_REUSE_IDENTIFIER];
    [_table registerClass:[EventParticipantVotingCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    [_table registerClass:[EventParticipantFirstCell class] forCellReuseIdentifier:TABLE_REUSE_FIRST_IDENTIFIER];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_table reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (! [APP.eventBeingEdited totalVenues ]) {
        /* _venueOperation=*/ [APP.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
            [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
        } failure:^{
            NSLog (@"FAILED TO FETCH VENUES");
        }];
    }
    
    /* _voteOperation=*/ [APP.eventBeingEdited refreshVotesFromServerWithSuccess:^{
        [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
    } failure:^{
        NSLog  (@"FAILED TO FETCH VOTES");
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventObject* event=APP.eventBeingEdited;
    
    NSInteger row=  indexPath.row;
    if  (!row) {
        EventParticipantFirstCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_FIRST_IDENTIFIER forIndexPath:indexPath];
        cell.delegate= self;
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
       [cell provideEvent: event];
        return cell;
    }
    
    if (![event totalVenues]) {
        EventParticipantEmptyCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier: TABLE_EMPTY_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    EventParticipantVotingCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.delegate= self;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;

    RestaurantObject* venue= [event getNthVenue:row-1];

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
        return  kGeomEventParticipantFirstBoxHeight+kGeomEventParticipantSeparatorHeight;
    }
    return kGeomEventParticipantRestaurantHeight +kGeomEventParticipantSeparatorHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EventObject* event=APP.eventBeingEdited;
    NSInteger total= [event totalVenues];
    if (!total) {
        return 2;
    }
    return 1+total ;
}

- (void) voteChanged:(VoteObject*) object;
{
    if  (!object) {
        return;
    }
    
    [OOAPI setVoteTo: object.vote
            forEvent: object.eventID
       andRestaurant: object.venueID
             success:^(NSInteger eventID) {
                 NSLog  (@"DID SAVE VOTE.");
             } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                 NSLog  (@"CANNOT SAVE VOTE.");
             }
     ];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    _table.frame=  self.view.bounds;
}

- (void) userRequestToSubmit;
{
    message( @"you pressed submit.");

}

@end
