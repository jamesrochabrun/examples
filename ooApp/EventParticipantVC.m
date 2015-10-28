//
//  EventParticipantVC.m
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
#import  <QuartzCore/CALayer.h>

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
        
        self.backgroundImageView=  makeImageView( self,  @"background-image.jpg" );
        self.backgroundImageView.contentMode= UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds= YES;

        self.labelDateTime= makeLabel( self, expressLocalDateTime( APP.eventBeingEdited.date), kGeomFontSizeSubheader);
        _labelDateTime.textColor= WHITE;
        _labelDateTime.font= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
        
        self.labelTitle= makeLabel( self, APP.eventBeingEdited.name,
                                   kGeomEventHeadingFontSize);
        _labelTitle.textColor= WHITE;
        _labelTitle.font= [UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomEventHeadingFontSize];
        
        self.labelTimeLeft= makeLabel( self,  @"00:00:??\rUNTIL VOTING CLOSES", kGeomFontSizeSubheader);
        _labelTimeLeft.textColor= WHITE;
        _labelTimeLeft.backgroundColor= UIColorRGBA(0x80000000);
        
        self.labelPersonIcon= makeIconLabel( self,  kFontIconPerson, kGeomFontSizeSubheader);
        _labelPersonIcon.textColor= GREEN;

        _buttonSubmitVote= makeButton(self,  @"SUBMIT VOTE", kGeomFontSizeSubheader,
                                      YELLOW,  UIColorRGBA(0x80000000), self, @selector(doSubmitVote:), 0);
        _buttonSubmitVote.titleLabel.font= [UIFont fontWithName:kFontLatoBold
                                                           size:kGeomFontSizeSubheader];
        
    }
    return self;
}

- (void)layoutSubviews
{
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
}

- (void) provideEvent: (EventObject*)event;
{
    self.event= event;
    
    if  (event.primaryVenueImageIdentifier ) {
        __weak EventParticipantFirstCell *weakSelf = self;
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
}

//------------------------------------------------------------------------------
// Name:    doSubmitVote
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmitVote: (id) sender
{
    [_delegate userRequestToSubmit];
}

@end

//==============================================================================

@interface EventParticipantVotingCell ()
@property (nonatomic,strong)  UISwitch *voteSwitch;
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
        
        _radioButton= makeButton(self, kFontIconRemove, kGeomFontSizeDetail, BLACK, CLEAR, self, @selector(userPressedRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmark forState:UIControlStateSelected];
        _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
        
        _thumbnail= makeImageView(self, nil);
        
//        _voteSwitch= [UISwitch new];
//        [self addSubview: _voteSwitch];
        
        _labelName= makeLabelLeft( self,  @"", kGeomFontSizeHeader);
        self.textLabel.hidden= YES;
        self.imageView.hidden= YES;
        _thumbnail.layer.borderColor= GRAY.CGColor;
        _thumbnail.layer.borderWidth= 1;
        
        [_voteSwitch addTarget: self action:@selector(switchChanged:)  forControlEvents:UIControlEventValueChanged];
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
//    CGSize switchSize= _voteSwitch.intrinsicContentSize;
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
//    _voteSwitch.frame = CGRectMake(x,(h-switchSize.height)/2,switchSize.width,switchSize.height);
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
//    _voteSwitch.on= vote.vote != 0;
    _radioButton.selected= vote.vote != 0;
}

- (void)prepareForReuse
{
    [_imageOperation cancel];
    self.imageOperation= nil;
//    self.voteSwitch.on= NO;
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
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _table= makeTable( self.view,  self);
#define TABLE_REUSE_IDENTIFIER  @"participantsCell"  
#define TABLE_REUSE_FIRST_IDENTIFIER @"participantsCell1st"
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;

    [_table registerClass:[EventParticipantVotingCell class] forCellReuseIdentifier:TABLE_REUSE_IDENTIFIER];
    [_table registerClass:[EventParticipantFirstCell class] forCellReuseIdentifier:TABLE_REUSE_FIRST_IDENTIFIER];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
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
        EventParticipantFirstCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_FIRST_IDENTIFIER forIndexPath:indexPath];
        cell.delegate= self;
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
       [cell provideEvent: event];
        return cell;
    }
    
    EventParticipantVotingCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.delegate= self;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;

    RestaurantObject* venue= [event getNthVenue:row];

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
    return [event totalVenues];
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
