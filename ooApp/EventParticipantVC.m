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
#import "ProfileVC.h"
#import "RestaurantVC.h"

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

//==============================================================================

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
        _participantsView.delegate= self;
        
        self.backgroundImageView=  makeImageView( self,  @"background-image.jpg" );
        self.backgroundImageView.contentMode= UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds= YES;

        self.labelDateTime= makeLabel( self, expressLocalDateTime( self.event.date), kGeomFontSizeSubheader);
        _labelDateTime.textColor= WHITE;
        _labelDateTime.font= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
        
        self.labelTitle= makeLabel( self, self.event.name,
                                   kGeomEventHeadingFontSize);
        _labelTitle.textColor= WHITE;
        _labelTitle.font= [UIFont  fontWithName: kFontLatoBoldItalic size:kGeomEventHeadingFontSize];

        self.labelTimeLeft= makeLabel( self,  @"until voting closes", kGeomFontSizeSubheader);
        _labelTimeLeft.textColor= BLACK;
        _labelTimeLeft.backgroundColor= YELLOW;
        
        _buttonSubmitVote= makeButton(self,  @"SUBMIT VOTE", kGeomFontSizeSubheader,
                                      WHITE,  BLACK, self, @selector(doSubmitVote:), 0);
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
    
    float distanceBetweenButtons= 0;
    float biggerButtonWidth= (w-2*margin-distanceBetweenButtons)/2;

    _buttonSubmitVote.frame=  CGRectMake(  margin, h-kGeomEventParticipantButtonHeight, biggerButtonWidth,kGeomEventParticipantButtonHeight);
    
    _labelTimeLeft.frame = CGRectMake(  w/2+ distanceBetweenButtons/2,h-kGeomEventParticipantButtonHeight, biggerButtonWidth, kGeomEventParticipantButtonHeight);
    
    [self.participantsView setNeedsLayout];
}

- (void)userPressedButtonForProfile:(NSUInteger)userid
{
    [_delegate userPressedProfilePicture:userid];
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
                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    NSAttributedString* lowerString= attributedStringOf( @"\runtil voting closes", kGeomFontSizeDetail);

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

@interface EventParticipantVotingSubCell ()
@property (nonatomic,strong) UIButton* radioButton;
@property (nonatomic,strong) EventObject* event;
@property (nonatomic,assign)  int radioButtonState;
@property (nonatomic,assign) id <EventParticipantVotingSubCellDelegate>delegate;
@end

@implementation EventParticipantVotingSubCell

- (instancetype) initWithRadioButtonState:( int) value
{
    self = [super init ];
    if (self) {
        _radioButton= makeButton(self, kFontIconEmptyCircle, kGeomFontSizeDetail, BLACK, CLEAR, self, @selector(userPressedRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmark forState:UIControlStateSelected];
        _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
        
        _thumbnail= makeImageView(self, nil);
        _thumbnail.contentMode= UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds= YES;
        
        _labelName= makeLabelLeft( self,  @"", kGeomFontSizeHeader);

        _thumbnail.layer.borderColor= GRAY.CGColor;
        _thumbnail.layer.borderWidth= 1;
        
        self.clipsToBounds= YES;
        self.backgroundColor= CLEAR;
        [ self setRadioButtonState:_radioButton to:value];
    }
    return self;
}

- (void)setRadioButtonState: (UIButton*)button  to: (int)state
{
    switch (state) {
        case VOTE_STATE_DONT_CARE:
            [button setTitle: @"don't\rcare" forState:UIControlStateNormal];
            _radioButton.titleLabel.numberOfLines=0;
            _radioButton.titleLabel.font= [UIFont fontWithName:kFontLatoRegular size: 6];
            _radioButton.titleLabel.textAlignment= NSTextAlignmentCenter;
            _radioButton.layer.cornerRadius= kGeomButtonWidth/2;
            _radioButton.layer.borderWidth= 1;
            _radioButton.layer.borderColor= GRAY.CGColor;
            self.backgroundColor= WHITE;
            break;
        case VOTE_STATE_YES:
            [button setTitle: kFontIconCheckmark forState:UIControlStateNormal];
            _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
            self.backgroundColor= GREEN;
            _radioButton.layer.cornerRadius= 0;
            _radioButton.layer.borderWidth= 0;
            break;
        case VOTE_STATE_NO:
            [button setTitle: kFontIconRemove forState:UIControlStateNormal];
            _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
            self.backgroundColor= RED;
            _radioButton.layer.cornerRadius= 0;
            _radioButton.layer.borderWidth= 0;
            break;
    }
    _radioButtonState= state;
}

- (void)userPressedRadioButton: (id) sender
{
    [_delegate userPressedRadioButton:_radioButtonState];
}

- (void) layoutSubviews
{
    CGSize switchSize= CGSizeMake(kGeomHeightButton, kGeomHeightButton);
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    float x= kGeomSpaceEdge;
    h-= kGeomEventParticipantSeparatorHeight;
    
    _thumbnail.frame = CGRectMake(x,0,h,h);
    x += h+kGeomSpaceInter;
    _labelName.frame = CGRectMake(x,0,w-x-switchSize.width-2*kGeomSpaceInter,h);
    x += _labelName.frame.size.width;
    _radioButton.frame = CGRectMake(x,(h-switchSize.height)/2,switchSize.width,switchSize.height);
}

@end

//==============================================================================

@interface EventParticipantVotingCell ()
@property (nonatomic,strong)  AFHTTPRequestOperation *imageOperation;
@property (nonatomic,assign)  int   radioButtonState;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic,strong) EventObject* event;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSArray *subcells;
@property (nonatomic,strong)  UITapGestureRecognizer* gesture;
@end

@implementation EventParticipantVotingCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.scrollView= [UIScrollView new];
        [ self  addSubview: _scrollView];
        self.backgroundColor= WHITE;
        
        self.gesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (userTapped:)];
        [self addGestureRecognizer:_gesture];
        
        self.viewShadow= makeView( _scrollView, WHITE);
        _viewShadow.layer.shadowOffset= CGSizeMake ( 2, 2);
        _viewShadow.layer.shadowColor= BLACK.CGColor;
        _viewShadow.layer.shadowOpacity= .5;
        _viewShadow.layer.shadowRadius= 4;
        _viewShadow.clipsToBounds= NO;
        _viewShadow.layer.borderColor= GRAY.CGColor;
        _viewShadow.layer.borderWidth= .5;
        
        _subcells=@[
                    [[EventParticipantVotingSubCell alloc]initWithRadioButtonState:VOTE_STATE_NO],
                    [[EventParticipantVotingSubCell alloc]initWithRadioButtonState:VOTE_STATE_DONT_CARE],
                    [[EventParticipantVotingSubCell alloc]initWithRadioButtonState:VOTE_STATE_YES],
                    ];
        
        for (EventParticipantVotingSubCell *view in _subcells)  {
            [_scrollView  addSubview: view];
            view.delegate= self;
        }
        
        _scrollView.pagingEnabled= YES;
        _scrollView.delegate= self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        self.textLabel.hidden= YES;
        self.imageView.hidden= YES;
        
        self.clipsToBounds= NO;
        self.backgroundColor= CLEAR;
        
    }
    return self;
}

- (void)dealloc
{
    [self  removeGestureRecognizer:_gesture];
    self.gesture= nil;
    
}

- (void) layoutSubviews
{
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    h-= kGeomEventParticipantSeparatorHeight;

    CGRect r = CGRectMake(0,0,w,h);
    _scrollView.frame= _viewShadow.frame= r ;
    
    ((EventParticipantVotingSubCell*)_subcells[0]).frame= r;
    r.origin.x= w;
    
    ((EventParticipantVotingSubCell*)_subcells[1]).frame= r;
    r.origin.x= w*2;
    
    ((EventParticipantVotingSubCell*)_subcells[2]).frame= r;
    
    _scrollView.contentSize= CGSizeMake(w*3, h);
    _scrollView.contentOffset= CGPointMake(w, 0);
    
    [self scrollToCurrentStateAnimated:NO];
}

- (void)userTapped: (id) gesture
{
    [self.delegate userDidSelect:self.tag];
}

- (void)provideVote: (VoteObject*)vote
{
    self.vote= vote;
    self.radioButtonState=  vote.vote;
}

- (void)prepareForReuse
{
    [_imageOperation cancel];
    self.imageOperation= nil;
    self.vote= nil;
    self.event= nil;
    
    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];
    for (EventParticipantVotingSubCell *view in _subcells)  {
        view.labelName.text= nil;
        view.thumbnail.image= placeholder;
    }
}

- (void)indicateMissingVoteFor: (RestaurantObject*)venue
{
    self.vote= [[VoteObject alloc] init];
    self.vote.venueID= venue.restaurantID;
}

- (void) userPressedRadioButton: (NSInteger)currentValue;
{
    switch (currentValue)  {
        case VOTE_STATE_DONT_CARE:
            self.radioButtonState= VOTE_STATE_YES;
            break;
        case VOTE_STATE_YES:
            self.radioButtonState= VOTE_STATE_NO;
            break;
        case VOTE_STATE_NO:
            self.radioButtonState= VOTE_STATE_YES;
            break;
    }
    [ self scrollToCurrentStateAnimated:YES ];
}

- (void) scrollToCurrentStateAnimated: (BOOL) animated
{
    float w= self.frame.size.width;
    
    switch (_radioButtonState)  {
        case VOTE_STATE_YES:
            [_scrollView scrollRectToVisible: CGRectMake(w*2, 0, w,1) animated:animated];
            break;
            
        case VOTE_STATE_DONT_CARE:
            [_scrollView scrollRectToVisible: CGRectMake(w, 0, w,1) animated:animated];
            break;

        case VOTE_STATE_NO:
            [_scrollView scrollRectToVisible: CGRectMake(0, 0, w,1) animated:animated];
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog  (@" ended deceleration");
    float x= _scrollView.contentOffset.x;
    float w= self.frame.size.width;
    if ( w<320) {
        return;
    }
    int  which=  (int) floorf((x + 10)/w);
    switch (which)  {
        case 0: _radioButtonState=VOTE_STATE_NO; break;
        case 1: _radioButtonState=VOTE_STATE_DONT_CARE; break;
        case 2: _radioButtonState=VOTE_STATE_YES; break;
    }
    
//    if ( _vote.vote  != _radioButtonState) {
        _vote.vote=_radioButtonState;
        [self.delegate voteChanged: _vote ];
//    }
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
    RestaurantObject* venue =nil;
    
    int restaurantNumber= self.tag;
    if  (event.venues.count > restaurantNumber) {
        venue= event.venues[restaurantNumber];
    } else {
        venue= [event lookupVenueByID: venueID];
    }
    
    self.vote.eventID= event.eventID;
    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];

    if  (!venue  || !venue.mediaItems.count) {
        NSLog (@"VENUE ID %ld HAS NO IMAGES.",(long)venueID);
        
        for (EventParticipantVotingSubCell *view in _subcells)  {
            view.labelName.text= venue.name;

            view.thumbnail.image= placeholder;
        }
    }
    else {
        for (EventParticipantVotingSubCell *view in _subcells)  {
            view.labelName.text= venue.name;
            view.thumbnail.image= placeholder;
        }
        
        OOAPI *api = [[OOAPI alloc] init];
        float h= self.frame.size.height;
        
        MediaItemObject* media= venue.mediaItems[0];
        if  (media.reference) {
            __weak EventParticipantVotingCell *weakSelf = self;
            self.imageOperation= [api getRestaurantImageWithImageRef: media.reference
                                                            maxWidth:0
                                                           maxHeight:h
                                                             success:^(NSString *link) {
                                                                 for (EventParticipantVotingSubCell *view in weakSelf.subcells)  {
                                                                     ON_MAIN_THREAD( ^{
                                                                         [view.thumbnail
                                                                          setImageWithURL:[NSURL URLWithString:link]
                                                                          placeholderImage:placeholder];
                                                                     });
                                                                 }
                                                             }
                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 
                                                                 for (EventParticipantVotingSubCell *view in weakSelf.subcells)  {
                                                                     ON_MAIN_THREAD( ^{
                                                                         view.thumbnail.image= placeholder;
                                                                     });
                                                                 }
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
    
    NSString* eventName= self.eventBeingEdited.name;
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
    _table.showsVerticalScrollIndicator= NO;

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
    
    if (! [self.eventBeingEdited totalVenues ]) {
        /* _venueOperation=*/ [self.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
            [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
        } failure:^{
            NSLog (@"FAILED TO FETCH VENUES");
        }];
    }
    
    /* _voteOperation=*/ [self.eventBeingEdited refreshVotesFromServerWithSuccess:^{
        [_table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
    } failure:^{
        NSLog  (@"FAILED TO FETCH VOTES");
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventObject* event=self.eventBeingEdited;
    
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
    cell.tag=  row-1;
    
    RestaurantObject* venue= [event getNthVenue:row-1];

    NSUInteger venueID = venue.restaurantID;
    VoteObject *voteForRow=[event lookupVoteByVenueID:venueID];

    NSLog (@"VOTE FOR VENUE  %lu =  %lu",(unsigned long)venueID, (unsigned long)voteForRow.vote);
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

- (void) userDidSelect: (NSUInteger) which;
{
    RestaurantVC* vc= [[RestaurantVC  alloc] init];
    
    RestaurantObject *venue= [self.eventBeingEdited getNthVenue:which];
    vc.restaurant= venue;

    [self.navigationController  pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
// Only the first row responds to tapping.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EventObject* event=self.eventBeingEdited;
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
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)userPressedProfilePicture: (NSUInteger)userid
{
    __weak EventParticipantVC *weakSelf = self;

    [OOAPI lookupUserByID: userid
                  success:^(UserObject *user) {
                      if ( user) {
                         ProfileVC* vc= [[ProfileVC alloc] init];
                         vc.userInfo= user;
                         vc.userID= userid;
                         [weakSelf.navigationController  pushViewController:vc animated:YES];
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     
                 }];
}

@end
