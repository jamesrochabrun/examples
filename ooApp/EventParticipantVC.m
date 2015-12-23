//
//  EventParticipantVC.m E2 and E13
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
#import "EventWhenVC.h"
#import "ProfileVC.h"
#import "RestaurantVC.h"
#import "EventCoordinatorVC.h"
#import "LocationManager.h"

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
        _labelCentered.textColor= WHITE;
        self.backgroundColor= UIColorRGB(kColorOffBlack);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _labelCentered.frame= self.bounds;
}
@end

//==============================================================================

@interface EventParticipantFirstCell ()
@property (nonatomic,assign)  int mode;
@property (nonatomic, strong) UIButton *buttonSubmitVote;
@property (nonatomic, strong) UIButton *buttonAttendees;
@property (nonatomic, strong) UILabel *labelTimeLeft;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelDateTime;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic,strong)  UIView *viewOverlay;
@property (nonatomic, strong) EventObject *event;
@property (nonatomic, strong) NSTimer  *timerCountdown;
@property (nonatomic,strong) ParticipantsView* participantsView;
@property (nonatomic,assign) BOOL eventAlreadyStarted;
@end

@implementation  EventParticipantFirstCell

- (void)dealloc
{
    [self.timerCountdown  invalidate];
    self.timerCountdown= nil;
    
    self.delegate= nil;
}

- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super  initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.viewShadow= makeView( self, WHITE);
        addShadowTo (_viewShadow);
        
        self.clipsToBounds= NO;
        self.backgroundColor= CLEAR;
        
        self.viewOverlay=makeView(self, BLACK);
        _viewOverlay.alpha= kColorEventOverlayAlpha;
        
        self.backgroundImageView=  makeImageView( self,  @"background-image.jpg" );
        self.backgroundImageView.contentMode= UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds= YES;
        
        self.labelDateTime= makeLabel( self,nil, kGeomFontSizeSubheader);
        _labelDateTime.textColor= WHITE;
        _labelDateTime.font= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
        
        self.labelTitle= makeLabel( self, nil,
                                   kGeomEventHeadingFontSize);
        _labelTitle.textColor= WHITE;
        _labelTitle.font= [UIFont  fontWithName: kFontLatoBold size:kGeomEventHeadingFontSize];
        
        self.labelTimeLeft= makeLabel( self, nil, kGeomFontSizeSubheader);
        _labelTimeLeft.textColor= BLACK;
        _labelTimeLeft.backgroundColor= YELLOW;
        
        self.participantsView= [[ParticipantsView alloc] init];
        [self  addSubview: _participantsView];
        _participantsView.delegate= self;
        
        _buttonSubmitVote= makeButton(self,  @"SUBMIT VOTE", kGeomFontSizeSubheader,
                                      WHITE,  BLACK, self, @selector(doSubmitVote:), 0);
        _buttonSubmitVote.titleLabel.font= [UIFont fontWithName:kFontLatoBold
                                                           size:kGeomFontSizeSubheader];
        
        _buttonAttendees= makeButton(self,  @"WHO'S GOING", kGeomFontSizeSubheader,
                                         WHITE, BLACK,  self, @selector(userPressedToViewAttendees:) , 0);
        
        _buttonAttendees.titleLabel.font= [UIFont fontWithName:kFontLatoBold
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
    
    _viewOverlay.frame=_backgroundImageView.frame;
    [self bringSubviewToFront:_viewOverlay];
    
    float y;
    if  (self.mode  != VOTING_MODE_SHOW_RESULTS ) {
        y=   (h- kGeomEventParticipantButtonHeight -kGeomFaceBubbleDiameter
              - kGeomEventHeadingFontSize-kGeomFontSizeSubheader - 3*spacing)/2;
    } else {
        y=   (h- kGeomEventParticipantButtonHeight/2 -kGeomFaceBubbleDiameter
              - kGeomEventHeadingFontSize-kGeomFontSizeSubheader - 3*spacing)/2;
    }
    
    _labelTitle.frame = CGRectMake( margin,y,w-2*margin,kGeomEventHeadingFontSize);
    y += kGeomEventHeadingFontSize +spacing;
    _labelDateTime.frame = CGRectMake( margin,y,w-2*margin,kGeomFontSizeSubheader);
    y+= kGeomFontSizeSubheader +spacing;
    _participantsView.frame = CGRectMake(margin,y,w-2*margin, kGeomFaceBubbleDiameter);

    if  (self.mode  != VOTING_MODE_SHOW_RESULTS ) {
        float biggerButtonWidth= (w-2*margin)/3;
        
        _buttonSubmitVote.frame=  CGRectMake(  margin,
                                             h-kGeomEventParticipantButtonHeight,
                                             biggerButtonWidth,
                                             kGeomEventParticipantButtonHeight);
        _labelTimeLeft.frame = CGRectMake(  margin + biggerButtonWidth,
                                          h-kGeomEventParticipantButtonHeight,
                                          biggerButtonWidth,
                                          kGeomEventParticipantButtonHeight);
        _buttonAttendees.frame=  CGRectMake(  margin + 2*biggerButtonWidth,
                                            h-kGeomEventParticipantButtonHeight,
                                            biggerButtonWidth,
                                            kGeomEventParticipantButtonHeight);
    } else {
        float biggerButtonWidth= (w-2*margin)/2;
        
        _labelTimeLeft.frame = CGRectMake(margin,
                                          h-kGeomEventParticipantButtonHeight,
                                          biggerButtonWidth,
                                          kGeomEventParticipantButtonHeight);
        _buttonSubmitVote.alpha= 0;
        
        _buttonAttendees.frame=  CGRectMake(  margin +biggerButtonWidth,
                                            h-kGeomEventParticipantButtonHeight,
                                            biggerButtonWidth,
                                            kGeomEventParticipantButtonHeight);
    }
    [self bringSubviewToFront:_labelTitle];
    [self bringSubviewToFront:_labelDateTime];
    [self bringSubviewToFront:_labelTimeLeft];
    [self bringSubviewToFront:_buttonSubmitVote];
    [self bringSubviewToFront:_buttonAttendees];
    [self bringSubviewToFront:_participantsView];

    [self.participantsView setNeedsLayout];
}

- (void)userPressedButtonForProfile:(NSUInteger)userid
{
    [_delegate userPressedProfilePicture:userid];
}

- (void)userPressedToViewAttendees: (id) sender
{
    [self.delegate  userPressedWhosGoing: self.eventAlreadyStarted];
}


- (void) provideEvent: (EventObject*)event;
{
    self.event= event;
    self.labelTitle.text= event.name;
    
    NSDate* dv=self.event.dateWhenVotingClosed;
    NSTimeInterval votingEnds= [dv timeIntervalSince1970];
    NSTimeInterval eventDate= [self.event.date timeIntervalSince1970];
    
    if (!votingEnds) {
        _labelTimeLeft.attributedText=attributedStringOf( @"VOTING END\rNOT SET", kGeomFontSizeSubheader);
    } else {
        self.labelDateTime.text= event.date ? expressLocalDateTime( event.date) : @"Date not set.";
        
        unsigned long now= [[NSDate date ] timeIntervalSince1970];
        if  ( now < votingEnds) {
            self.timerCountdown= [ NSTimer  scheduledTimerWithTimeInterval:1
                                                                    target:self
                                                                  selector:@selector(callbackCountdown:)
                                                                  userInfo:nil repeats:YES];
            [ self callbackCountdown:nil];
        } else {
            // RULE: After the event has gotten under way, change the button text to the past tense.
            if (eventDate &&  now-eventDate >= ONE_HOUR/4) {
                [_buttonAttendees setTitle: @"WHO WENT" forState:UIControlStateNormal];
                self.eventAlreadyStarted= YES;
            }  else {
                self.eventAlreadyStarted= NO;
            }
        }
    }
    
    UIImage* placeholder= [UIImage imageNamed:@"background-image.jpg"];
    
    __weak EventParticipantFirstCell *weakSelf = self;
    if (event.primaryImageURL ) {
        [self.backgroundImageView setImageWithURL:[NSURL URLWithString: event.primaryImageURL]
                                 placeholderImage:placeholder];
        
    } else if  (event.primaryVenueImageIdentifier ) {
        OOAPI *api = [[OOAPI alloc] init];
        /* _imageOperation=*/ [api getRestaurantImageWithImageRef: event.primaryVenueImageIdentifier
                                                         maxWidth:self.frame.size.width
                                                        maxHeight:0
                                                          success:^(NSString *link) {
                                                              ON_MAIN_THREAD(  ^{
                                                                  [weakSelf.backgroundImageView
                                                                   setImageWithURL:[NSURL URLWithString:link]
                                                                   placeholderImage:placeholder];
                                                              });
                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          }];
        
    }
    
    [self refreshUsers];
}


- (void)setMode:(int)mode
{
    _mode= mode;
    
    switch ( mode) {
        case VOTING_MODE_ALLOW_VOTING:
            _buttonSubmitVote.enabled= YES;
            _buttonSubmitVote.alpha= 1;
            [_buttonSubmitVote setTitle: @"SUBMIT VOTE" forState:UIControlStateNormal];
            break;
            
        case VOTING_MODE_NO_VOTING:
            [self killTimer];
//            _buttonSubmitVote.enabled= NO;
            _buttonSubmitVote.alpha= 1;
            [_buttonSubmitVote setTitle: @"VOTE SUBMITTED" forState:UIControlStateNormal];
            break;
            
        case VOTING_MODE_SHOW_RESULTS:
            [self killTimer];
//            _buttonSubmitVote.enabled= NO;
            _buttonSubmitVote.alpha= 0;
            _labelTimeLeft.text=  @"voting has ended";
            break;
            
        default:
            break;
    }
    
    [self setNeedsLayout];
}

- (void)callbackCountdown: ( NSTimer *) timer
{
    long votingEnds= [self.event.dateWhenVotingClosed timeIntervalSince1970];
    long now= [[NSDate date ] timeIntervalSince1970];
    long  timeRemaining= votingEnds-now;
    if ( timeRemaining <= 0) {
        _labelTimeLeft.attributedText=attributedStringOf( @"VOTING ENDED", kGeomFontSizeHeader);
        [self.delegate votingEnded];

        if  (timeRemaining < -ONE_HOUR/4) {
            [_buttonAttendees setTitle: @"WHO WENT" forState:UIControlStateNormal];
            self.eventAlreadyStarted= YES;
            
            [self killTimer];
        }
        return;
    }
    
    unsigned long  hours= timeRemaining/ONE_HOUR;
    unsigned long  minutes=  (timeRemaining/60)% 60;
    unsigned long  seconds=  timeRemaining% 60;
    NSAttributedString* lowerString= attributedStringOf( @"\runtil voting closes", kGeomFontSizeDetail);

    if ( hours < 48) {
        NSString* string= [NSString  stringWithFormat: @"%ld:%02ld:%02ld", hours, minutes, seconds];
        NSAttributedString* s= attributedStringOf(string, kGeomFontSizeHeader);
        NSMutableAttributedString *mas=[[NSMutableAttributedString  alloc] initWithAttributedString: s];
        [mas  appendAttributedString:lowerString];
        _labelTimeLeft.attributedText= mas;
    } else {
        NSString* string= [NSString  stringWithFormat: @"%ld days", hours/24];
        NSAttributedString* s= attributedStringOf(string, kGeomFontSizeHeader);
        NSMutableAttributedString *mas=[[NSMutableAttributedString  alloc] initWithAttributedString: s];
        [mas  appendAttributedString:lowerString];
        _labelTimeLeft.attributedText= mas;
    }
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

- (void)killTimer
{
    [_timerCountdown  invalidate];
    self.timerCountdown= nil;
}

- (void)prepareForReuse
{
    [self killTimer];
    self.event= nil;
    self.eventAlreadyStarted= NO;

}
@end

//==============================================================================

@interface EventParticipantVotingSubCell ()

@property (nonatomic,strong)  UIImageView *thumbnail;
@property (nonatomic,strong)   UILabel *labelName;
@property (nonatomic,strong)   UILabel *labelDistance;

@property (nonatomic,assign)  int  mode;
@property (nonatomic,strong) UIView* viewOverlay;
@property (nonatomic,strong) UIView* radioButtonBacking;
@property (nonatomic,strong) UIButton* radioButton;
@property (nonatomic,strong) UIButton* buttonVoteYes;
@property (nonatomic,strong) UIButton* buttonVoteNo;
@property (nonatomic,strong) EventObject* event;
@property (nonatomic,strong) RestaurantObject*restaurant;
@property (nonatomic,assign) int radioButtonState;
@property (nonatomic,weak) id <EventParticipantVotingSubCellDelegate> delegate;
@end

@implementation EventParticipantVotingSubCell

- (instancetype) initWithRadioButtonState:( int) value
{
    self = [super init ];
    if (self) {
        self.thumbnail= makeImageView(self, nil);
        _thumbnail.contentMode= UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds= YES;
        
        self.viewOverlay= makeView( self, CLEAR);
        _viewOverlay.alpha=  kColorEventOverlayAlpha;
        
        _radioButtonBacking= makeView(self, BLACK);
        _radioButtonBacking.layer.cornerRadius= 11;
        _radioButtonBacking.frame = CGRectMake(0,0, 22 ,22);
        
        _buttonVoteYes=[UIButton buttonWithType:UIButtonTypeCustom];
        _buttonVoteNo=[UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonVoteYes addTarget:self action:@selector(userPressedVoteUp:) forControlEvents:UIControlEventTouchUpInside ];
        [_buttonVoteNo addTarget:self action:@selector(userPressedVoteDown:) forControlEvents:UIControlEventTouchUpInside ];
        [ self addSubview: _buttonVoteYes];
        [ self addSubview: _buttonVoteNo];
        UIImage*image=[UIImage  imageNamed: @"ThumbUp.png"];
        [_buttonVoteYes setImage: image forState:UIControlStateNormal];
        [_buttonVoteNo setImage: [UIImage  imageNamed: @"ThumbDown.png"] forState:UIControlStateNormal];
        
        _radioButton= makeIconButton (self, kFontIconEmptyCircle, kGeomFontSizeDetail,
                                      WHITE, CLEAR, self, @selector(userPressedRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmarkCircle forState:UIControlStateSelected];

        self.labelName= makeLabelLeft( self,  @"", kGeomFontSizeHeader);
        _labelName.font= [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        self.labelDistance= makeLabelLeft( self,  @"", kGeomFontSizeSubheader);
        _labelName.textColor= WHITE;
        _labelDistance.textColor= WHITE;
        
        [self applyThinBorder];
        self.clipsToBounds= YES;
        self.backgroundColor= UIColorRGBA(kColorOffBlack);

        [ self setRadioButtonState:_radioButton to:value];
        
    }
    return self;
}

- (void)removeThinBorder
{
    _thumbnail.layer.borderWidth= 0;
    
}
- (void)applyThinBorder
{
    _thumbnail.layer.borderWidth= 0.5;
    _thumbnail.layer.borderColor= GRAY.CGColor;
}

- (void)userPressedVoteUp: (id) sender
{
    [self.delegate  userPressedVoteUp];
}

- (void)userPressedVoteDown: (id) sender
{
    [self.delegate  userPressedVoteDown];
}

- (void)setRadioButtonState: (UIButton*)button  to: (int)state
{
    if  (_mode==VOTING_MODE_SHOW_RESULTS ) {
        _radioButton.titleLabel.font= [ UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader];
        NSString  * string= [NSString stringWithFormat: @"%ld", (long)self.tag];
        [_radioButton setTitle:string forState:UIControlStateNormal];
        return;
    }
    
    switch (state) {
        case VOTE_STATE_DONT_CARE:
            [button setTitle: kFontIconDontCare forState:UIControlStateNormal];
            self.viewOverlay.backgroundColor= BLACK;
            break;
        case VOTE_STATE_YES:
            [button setTitle: kFontIconCheckmarkCircle forState:UIControlStateNormal];
            self.viewOverlay.backgroundColor= GREEN;
            break;
        case VOTE_STATE_NO:
            [button setTitle: kFontIconRemove forState:UIControlStateNormal];
            self.viewOverlay.backgroundColor= RED;
            break;
    }
    _radioButtonState= state;
}

- (void)provideRestaurant:(RestaurantObject*)restaurant
{
    self.restaurant=  restaurant;
    self.labelName.text= restaurant.name;
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    self.labelDistance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];
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
    float x, margin= kGeomSpaceEdge;
    float spacer= kGeomSpaceInter;
    
    const float kGeomParticipantRestaurantHeaderHeight= 18;
    const float kGeomParticipantRestaurantSubheaderHeight= 16;
    _thumbnail.frame = CGRectMake( margin, margin,w- 2*margin,h-2*margin);
    
    x= 2*margin;
    float y=  (h-kGeomParticipantRestaurantHeaderHeight-2*kGeomParticipantRestaurantSubheaderHeight-2*spacer)/2;
    _labelName.frame = CGRectMake(x,y,w-x-switchSize.width-2*kGeomSpaceInter,kGeomParticipantRestaurantHeaderHeight);
    y+=kGeomParticipantRestaurantHeaderHeight+spacer;

    _labelDistance.frame = CGRectMake(x,y,w-x-switchSize.width-2*kGeomSpaceInter,kGeomParticipantRestaurantSubheaderHeight);
    
    x += _labelName.frame.size.width;
    
    _radioButton.frame = CGRectMake(x,(h-switchSize.height)/2,switchSize.width,switchSize.height);
    _radioButtonBacking.center= _radioButton.center;
    
    const  float kGeomParticipantRestaurantThumbSize = 25;
    spacer=kGeomParticipantRestaurantThumbSize;
    x= w/2 - kGeomParticipantRestaurantThumbSize -  spacer/2;
    y=h-kGeomParticipantRestaurantThumbSize-2*margin;
    _buttonVoteYes.frame = CGRectMake(x, y, kGeomParticipantRestaurantThumbSize, kGeomParticipantRestaurantThumbSize);
    x+= kGeomParticipantRestaurantThumbSize+ spacer;
    _buttonVoteNo.frame = CGRectMake(x, y, kGeomParticipantRestaurantThumbSize, kGeomParticipantRestaurantThumbSize);
    
    _viewOverlay.frame= self.bounds;
}

- (void)setMode:(int)mode
{
    _mode= mode;
    
    switch ( mode) {
        case VOTING_MODE_ALLOW_VOTING:
            _radioButton.hidden= NO;
            _radioButtonBacking.hidden=NO;
            _radioButton.enabled= YES;
            _buttonVoteYes.hidden= NO;
            _buttonVoteNo.hidden= NO;
            break;
            
        case VOTING_MODE_NO_VOTING:
            _radioButton.enabled= NO;
            _radioButton.hidden= YES;
            _radioButtonBacking.hidden=YES;
            _radioButton.layer.borderWidth= 0;
            _buttonVoteYes.hidden= YES;
            _buttonVoteNo.hidden= YES;
            [_radioButton setTitle: @"" forState:UIControlStateNormal];
            break;
            
        case VOTING_MODE_SHOW_RESULTS:
            _radioButton.enabled= NO;
            _radioButton.hidden= YES;
            _radioButtonBacking.hidden=YES;
            _radioButton.layer.borderWidth= 0;
            _buttonVoteYes.hidden= YES;
            _buttonVoteNo.hidden= YES;
            [_radioButton setTitle: @"" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    _radioButton.selected= NO;
}
             
@end

//==============================================================================

@interface EventParticipantVotingCell ()
@property (nonatomic,assign)  int  mode;
@property (nonatomic,strong)  AFHTTPRequestOperation *imageOperation;
@property (nonatomic,assign)  int   radioButtonState;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic,strong) EventObject* event;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSArray *subcells;
@property (nonatomic,strong)  UITapGestureRecognizer* gesture;
@property (nonatomic,assign) BOOL isWinner;

@end

@implementation EventParticipantVotingCell
- (instancetype)  initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.scrollView= [UIScrollView new];
        [ self  addSubview: _scrollView];
        self.backgroundColor= UIColorRGBA(kColorOffBlack);
        
        self.gesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (userTapped:)];
        [self addGestureRecognizer:_gesture];
      
        _subcells=@[
                    [[EventParticipantVotingSubCell alloc]initWithRadioButtonState:VOTE_STATE_YES ],
                    [[EventParticipantVotingSubCell alloc]initWithRadioButtonState:VOTE_STATE_DONT_CARE],
                    [[EventParticipantVotingSubCell alloc]initWithRadioButtonState:VOTE_STATE_NO],
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
        
    }
    return self;
}

- (void) declareWinner;
{
    _isWinner= YES;
    
    if (_subcells.count == 3) {
        EventParticipantVotingSubCell *view=  _subcells[1];
        
        view.layer.borderWidth= 5;
        view.layer.borderColor=  UIColorRGB(0xffff30).CGColor;
        view.clipsToBounds=NO;
        [view removeThinBorder];
    }
}

- (void)dealloc
{
    [self  removeGestureRecognizer:_gesture];
    self.gesture= nil;
    
}

- (void)setMode:(int)mode
{
    _mode= mode;
    float w= self.frame.size.width;
    
    for (EventParticipantVotingSubCell *view in _subcells)  {
        [view setMode:mode];
    }
    
    switch ( mode) {
        case VOTING_MODE_ALLOW_VOTING:
            [_scrollView setScrollEnabled:YES];
            break;
            
        case VOTING_MODE_NO_VOTING:
            [_scrollView scrollRectToVisible: CGRectMake(w, 0, w,1) animated:NO];
            [_scrollView setScrollEnabled:NO];
            break;
            
        case VOTING_MODE_SHOW_RESULTS:
            [_scrollView scrollRectToVisible: CGRectMake(w, 0, w,1) animated:NO];
            [_scrollView setScrollEnabled:NO];
            break;
            
        default:
            break;
    }
    
    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    float w= self.frame.size.width;
    float h= self.frame.size.height;
//    h-= kGeomEventParticipantSeparatorHeight;
    
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
    self.radioButtonState= (int) vote.vote;
}

- (void)prepareForReuse
{
    [_imageOperation cancel];
    self.imageOperation= nil;
    self.vote= nil;
    self.event= nil;
    _isWinner= NO;
    self.layer.borderWidth= 0;

    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];
    for (EventParticipantVotingSubCell *view in _subcells)  {
        view.labelName.text= nil;
        view.thumbnail.image= placeholder;
        [view applyThinBorder];
    }
}

- (void)indicateMissingVoteFor: (RestaurantObject*)venue
{
    self.vote= [[VoteObject alloc] init];
    self.vote.venueID= venue.restaurantID;
}

- (void) userPressedVoteUp;
{
    self.radioButtonState= VOTE_STATE_YES;
    [ self scrollToCurrentStateAnimated:YES ];
}

- (void) userPressedVoteDown;
{
    self.radioButtonState= VOTE_STATE_NO;
    [ self scrollToCurrentStateAnimated:YES ];
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
    if ( _mode != VOTING_MODE_ALLOW_VOTING) {
        return;
    }
    
    switch (_radioButtonState)  {
        case VOTE_STATE_YES:
            [_scrollView scrollRectToVisible: CGRectMake(0, 0, w,1) animated:animated];
            break;
            
        case VOTE_STATE_DONT_CARE:
            [_scrollView scrollRectToVisible: CGRectMake(w, 0, w,1) animated:animated];
            break;
            
        case VOTE_STATE_NO:
            [_scrollView scrollRectToVisible: CGRectMake(w*2, 0, w,1) animated:animated];
            break;
    }
    
    _vote.vote=_radioButtonState;
    [self.delegate voteChanged: _vote ];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog  (@" ended deceleration");
    float x= _scrollView.contentOffset.x;
    float w= self.frame.size.width;
    if ( w<1) {
        return;
    }
    int  which=  (int) floorf((x + 10)/w);
    switch (which)  {
        case 0: _radioButtonState=VOTE_STATE_YES; break;
        case 1: _radioButtonState=VOTE_STATE_DONT_CARE; break;
        case 2: _radioButtonState=VOTE_STATE_NO ; break;
    }
    
    _vote.vote=_radioButtonState;
    [self.delegate voteChanged: _vote ];
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
    
    NSInteger restaurantNumber= self.tag;
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
            [view provideRestaurant:venue];
            view.tag= self.tag;
            view.thumbnail.image= placeholder;
        }
    }
    else {
        for (EventParticipantVotingSubCell *view in _subcells)  {
            [view provideRestaurant:venue];
            view.thumbnail.image= placeholder;
            view.tag= self.tag;
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
@property (nonatomic,assign) int mode;
@property (nonatomic,strong) NSMutableArray* sortedArrayOfVenues;
@property (nonatomic,assign) BOOL coordinatorVCReportedEventChanged;
@property (nonatomic,strong)  UIImageView* imageViewBackground;
@property (nonatomic,assign) BOOL transitioning;
@end

@implementation EventParticipantVC

- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    NSString* eventName= self.eventBeingEdited.name;
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;

    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= UIColorRGBA(kColorOffBlack);
    
    self.sortedArrayOfVenues= [NSMutableArray new];
    
    self.imageViewBackground= makeImageView( self.view,  @"Gradient Background.png");
    
    _table= makeTable( self.view,  self);
#define TABLE_REUSE_IDENTIFIER  @"participantsCell"
#define TABLE_REUSE_FIRST_IDENTIFIER @"participantsCell1st"
#define TABLE_EMPTY_REUSE_IDENTIFIER  @"participantsEmpty"
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    [_table registerClass:[EventParticipantEmptyCell class] forCellReuseIdentifier:TABLE_EMPTY_REUSE_IDENTIFIER];
    [_table registerClass:[EventParticipantVotingCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    [_table registerClass:[EventParticipantFirstCell class] forCellReuseIdentifier:TABLE_REUSE_FIRST_IDENTIFIER];
    _table.showsVerticalScrollIndicator= NO;
    _table.backgroundColor= UIColorRGBA(kColorOffBlack);

    self.automaticallyAdjustsScrollViewInsets= NO;
   
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
    
    NSTimeInterval votingEnds= [self.eventBeingEdited.dateWhenVotingClosed timeIntervalSince1970];
    NSTimeInterval now= [[NSDate date ] timeIntervalSince1970];
    if (votingEnds &&  now >= votingEnds) {
        [self setRightNavWithIcon:@"" target:nil action:nil];
    } else {
        [self setRightNavWithIcon:kFontIconMore target:self action:@selector(userPressedMenuButton:)];
    }
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));

    __weak  EventParticipantVC *weakSelf = self;
    if ( self.coordinatorVCReportedEventChanged) {
        self.coordinatorVCReportedEventChanged= NO;
        
        [self.eventBeingEdited refreshWithSuccess:^{
            
            /* _venueOperation=*/ [weakSelf.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
                
                /* _voteOperation=*/ [weakSelf.eventBeingEdited refreshVotesFromServerWithSuccess:^{
                    
                    [weakSelf.table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
                } failure:^{
                    NSLog  (@"FAILED TO FETCH EVENT VOTES");
                }];
            } failure:^{
                NSLog (@"FAILED TO FETCH EVENT VENUES");
            }];
            
        } failure:^{
            NSLog (@"FAILED TO REFETCH EVENT");
        }];
    }
    else {
        
        /* _venueOperation=*/ [self.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
            
            /* _voteOperation=*/ [weakSelf.eventBeingEdited refreshVotesFromServerWithSuccess:^{
                
                [weakSelf.table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];
            } failure:^{
                NSLog  (@"FAILED TO FETCH EVENT VOTES");
            }];
        } failure:^{
            NSLog (@"FAILED TO FETCH EVENT VENUES");
        }];
    }
    
    self.transitioning = NO;
}

- (void) userPressedMenuButton: (id) sender
{
    UserObject*user= [Settings sharedInstance].userObject;

    __weak EventParticipantVC *weakSelf = self;
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Options")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionMore= nil;
    if  ([self.eventBeingEdited userIsAdministrator: user.userID] ) {
        actionMore= [UIAlertAction actionWithTitle:@"Modify or Cancel Event"
                                             style:  UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [weakSelf transitionToE3];
                                           }];
        
    } else {
        actionMore= [UIAlertAction actionWithTitle:@"See Event Details"
                                             style: UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [weakSelf transitionToE3L];
                                           }];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         
                                                     }];
    [a addAction:actionMore];
    [a addAction:actionCancel];
    
    [self presentViewController:a animated:YES completion:nil];
}

- (void) transitionToE3
{
    EventCoordinatorVC*vc= [[EventCoordinatorVC alloc] init];
    vc.eventBeingEdited=  self.eventBeingEdited;
    vc.delegate=  self;
    [self.navigationController pushViewController:vc animated:YES ];
}

- (void) transitionToE3L
{
    EventCoordinatorVC*vc= [[EventCoordinatorVC alloc] init];
    [vc  enableE3LMode];
    vc.eventBeingEdited=  self.eventBeingEdited;
    vc.delegate=  self;
    [self.navigationController pushViewController:vc animated:YES ];
}

- (void)userDidDeclineEvent
{
    self.eventBeingEdited.hasBeenAltered= YES;// XX:  kludge done to force a reload of the event list
    
    [self.navigationController popToViewController: self.previousVC animated:YES ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventObject* event=self.eventBeingEdited;
    
    NSInteger row=  indexPath.row;
    if  (!row) {
        EventParticipantFirstCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_FIRST_IDENTIFIER forIndexPath:indexPath];
        [cell setMode:_mode];
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
    
    row--;
    
    EventParticipantVotingCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell setMode:_mode];
    cell.delegate= self;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    cell.tag=  row;
    
    if ( _mode == VOTING_MODE_SHOW_RESULTS && row==0) {
        [cell  declareWinner];
    }
    
    RestaurantObject* venue= nil;
    if ( _mode == VOTING_MODE_SHOW_RESULTS) {
        venue= self.sortedArrayOfVenues[row];
    } else {
        venue = [event getNthVenue:row];
    }
    
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
//        if ( _mode == VOTING_MODE_SHOW_RESULTS) {
//            return  kGeomEventParticipantFirstBoxHeight+kGeomEventParticipantSeparatorHeight-kGeomHeightButton;
//        }
        return  kGeomEventParticipantFirstBoxHeight+kGeomEventParticipantSeparatorHeight;
    }
    if ( _mode == VOTING_MODE_SHOW_RESULTS && row==1) {
        return 200;
    }
    return kGeomEventParticipantRestaurantHeight +kGeomEventParticipantSeparatorHeight;
}

- (void) userDidAlterEvent
{
    self.coordinatorVCReportedEventChanged= YES;
}


- (void) userDidSelect: (NSUInteger) which;
{
    if ( self.transitioning) {
        return;
    }
    _transitioning= YES;
    
    RestaurantVC* vc= [[RestaurantVC  alloc] init];
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-EventParticipant");
    
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
    switch (_mode) {
        case VOTING_MODE_ALLOW_VOTING:
        case VOTING_MODE_NO_VOTING:{
            EventObject* event=self.eventBeingEdited;
            NSInteger total= [event totalVenues];
            if (!total) {
                return 2;
            }
            return 1+total ;
        }
            
        case VOTING_MODE_SHOW_RESULTS: {
            NSUInteger  total= [self.sortedArrayOfVenues  count];
            return 1+total ;
        }
    }
    return 1;
}

- (void) voteChanged:(VoteObject*) object;
{
    if  (!object) {
        return;
    }
    
    if ( self.votingIsDone) {
        return;
    }
    
    [OOAPI setVoteTo: object.vote
            forEvent: object.eventID
       andRestaurant: object.venueID
             success:^(NSInteger eventID) {
                 NSLog  (@"DID SAVE VOTE AS %d.", object.vote);
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
    float margin= kGeomSpaceEdge;
    float w= self.view.bounds.size.width;
    float h= self.view.bounds.size.height;
    _table.frame= CGRectMake(margin, margin,w-2* margin,h-2*margin);
    _imageViewBackground.frame= self.view.bounds;
}

- (void) userRequestToSubmit;
{
    [self.navigationController popViewControllerAnimated:YES ];
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

- (void)votingEnded
{
    [self setRightNavWithIcon:@"" target:nil action:nil];

    [self setMode: VOTING_MODE_SHOW_RESULTS];
}

- (void)setMode:(int)mode
{
    _mode=  mode;
    
    switch ( mode) {
        case VOTING_MODE_ALLOW_VOTING:
            [self.table  reloadData ];
            break;
            
        case VOTING_MODE_NO_VOTING:
            [self.table  reloadData ];
            break;
            
        case VOTING_MODE_SHOW_RESULTS:
            [self fetchTallies];
            break;
    }
}

- (void)fetchTallies
{
    __weak EventParticipantVC *weakSelf = self;
    
    for (RestaurantObject* venue  in  self.eventBeingEdited.venues ) {
        venue.totalVotes= 0;
    }
    
    [OOAPI getVoteTalliesForEvent: self.eventBeingEdited.eventID
                          success:^(NSArray *venues) {
                              
                              [weakSelf.sortedArrayOfVenues removeAllObjects];
                              for (RestaurantObject* venue in venues) {
                                  [weakSelf.sortedArrayOfVenues addObject: venue];
                              }
                              [weakSelf.sortedArrayOfVenues sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
                              [weakSelf.table performSelectorOnMainThread:@selector(reloadData)  withObject:nil waitUntilDone:NO];

                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              NSLog  (@"FAILED TO FETCH VOTE TALLIES.");
                          }];
}

- (void) userPressedWhosGoing:(BOOL)eventAlreadyStarted;
{
    EventWhoVC*vc= [[EventWhoVC alloc] init];
    [vc setEditable:NO];
    vc.eventBeingEdited= self.eventBeingEdited;
    vc.eventAlreadyStarted= eventAlreadyStarted;

    [self.navigationController pushViewController:vc animated:YES];
}
@end
