//
//  EventCoordinatorVC.m E3 and E3L.
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
#import "EventCoordinatorVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "TileCVCell.h"
#import "EventWhenVC.h"
#import "EventWhoVC.h"
#import "SearchVC.h"
#import "RestaurantVC.h"
#import "OOStripHeader.h"
#import "PieView.h"
#import "EventParticipantVC.h"
#import "ProfileVC.h"
#import "EmptyListVC.h"
#import "ParticipantsView.h"

#define kGeomSeparatorHeight 25

//------------------------------------------------------------------------------

@interface  PlusCell()
@property (nonatomic,strong)  UIButton* buttonAddRestaurant;

@end

@implementation PlusCell

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews= NO;
        self.buttonAddRestaurant=makeRoundIconButton(self.contentView, kFontIconAdd,
                                                     30, YELLOW, BLACK,
                                                     self, @selector(newRestaurant:),
                                                     0, kGeomHeightButton/2);
        
        [self addSubview:_buttonAddRestaurant];
    }
    return self;
}

- (void)layoutSubviews
{
    float w= self.bounds.size.width;
    float h= self.bounds.size.height;
    _buttonAddRestaurant.frame = CGRectMake((w-kGeomHeightButton)/2,(h-kGeomHeightButton)/2,kGeomHeightButton,kGeomHeightButton);
}

- (void) newRestaurant: (id) sender;
{
    [self.delegate userPressedNewRestaurant];
}

@end

//------------------------------------------------------------------------------

@interface EventCoordinatorNewCell()
@property (nonatomic,strong) UIButton*buttonAdd;
@property (nonatomic,strong) UILabel*labelMessage;
@end

@implementation EventCoordinatorNewCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.buttonAdd=  makeRoundIconButton(self.contentView, kFontIconAdd, 20,
                                             YELLOW, BLACK,
                                             self, @selector(userPressedAdd:), 0,
                                             kGeomHeightButton/2);
        _buttonAdd.enabled= NO;
        self.labelMessage= makeLabel(self.contentView, @"Tap Me", kGeomFontSizeSubheader);
        _labelMessage.clipsToBounds= NO;
        _labelMessage.textColor= WHITE;
        self.selectionStyle= UITableViewCellSelectionStyleNone;
        self.backgroundColor= UIColorRGBA( kColorCoordinatorBoxBackground);
    }
    return self;
}

- (void)userPressedAdd: (id) sender
{
    
    
}

- (void)setMessage: (NSString*)message
{
    _labelMessage.text= message;
}

- (void)layoutSubviews
{
    float w= self.bounds.size.width;
    float h= self.bounds.size.height;
    float y= ( h-kGeomHeightButton-kGeomSpaceInter-kGeomFontSizeSubheader )/2;
    _buttonAdd.frame = CGRectMake((w-kGeomHeightButton)/2, y,kGeomHeightButton,kGeomHeightButton);
    y+=kGeomHeightButton+kGeomSpaceInter;
    _labelMessage.frame = CGRectMake(0,y,w,kGeomFontSizeSubheader);
}

@end

//------------------------------------------------------------------------------

@interface EventCoordinatorCoverCell()
@property (nonatomic,strong)  UIButton* buttonSubmit;
@property (nonatomic,strong)  UIButton* buttonAccept;
@property (nonatomic,strong)  UIButton* buttonDecline;
@property (nonatomic,strong)  UIImageView *imageViewContainer1;
@property (nonatomic,strong)  UILabel *labelIcon;
@property (nonatomic,strong)  UILabel *labelTitle;
@property (nonatomic,strong)  UILabel *labelSubtitle;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@property (nonatomic,assign) BOOL userDidDecide;
@end

@implementation EventCoordinatorCoverCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews= NO;
        self.imageViewContainer1= makeImageView(self.contentView, nil);
        _imageViewContainer1.contentMode= UIViewContentModeScaleAspectFill;
        _imageViewContainer1.clipsToBounds= YES;
        
        self.labelTitle=makeAttributedLabel(self.contentView, self.eventBeingEdited.name ?: @"UNNAMED EVENT", kGeomEventHeadingFontSize);
        
        _labelTitle.textColor= WHITE;
        _labelTitle.shadowColor = BLACK;
        _labelTitle.shadowOffset = CGSizeMake(0, -1.0);
        _labelTitle.layer.shadowRadius= 4;
        
        self.clipsToBounds= NO;
        self.contentView.clipsToBounds= NO;
        
        if  (_inE3LMode ) {
            _buttonAccept= makeButton(self.contentView,  @"Accept",kGeomFontSizeHeader, YELLOW, BLACK, self, @selector(doAccept:), 0);
            _buttonDecline= makeButton(self.contentView,  @"Decline",kGeomFontSizeHeader, YELLOW, BLACK, self, @selector(doDecline:), 0);
        } else {
            NSString* submitButtonMessage;
            if  (self.eventBeingEdited.isComplete) {
                submitButtonMessage=@"EVENT SUBMITTED";
            } else {
                submitButtonMessage=@"SUBMIT EVENT";
            }
            
            _buttonSubmit= makeButton(self.contentView, submitButtonMessage,
                                      kGeomFontSizeHeader, YELLOW, BLACK, self, @selector(doSubmit:), 0);
            _buttonSubmit.titleLabel.numberOfLines= 0;
            _buttonSubmit.titleLabel.textAlignment= NSTextAlignmentCenter;
        }
        
        self.backgroundColor= UIColorRGBA( kColorCoordinatorBoxBackground);
        
    }
    return self;
}

- (void)prepareForReuse
{
    [_labelIcon  removeFromSuperview];
    [_labelSubtitle removeFromSuperview];
    self.labelIcon= nil;
    self.labelSubtitle= nil;
    self.labelTitle.text= nil;
    self.imageViewContainer1.image= nil;
}

- (void) setPhoto: ( UIImage*)image;
{
    if (!image) {
        return;
    }
    self.imageViewContainer1.image=  image;
    [self doLayout];
}

- (void) coverHasImageNow;
{
    [_labelIcon  removeFromSuperview];
    [_labelSubtitle removeFromSuperview];
    self.labelIcon= nil;
    self.labelSubtitle= nil;
    self.labelTitle.text= self.eventBeingEdited.name;
}

- (void) coverDoesNotHaveImage
{
    [self.labelTitle removeFromSuperview];
    
    self.labelIcon=makeIconLabel(self.contentView, kFontIconPhoto, 20);
    self.labelTitle=makeAttributedLabel(self.contentView, @"UPLOAD A COVER PHOTO", kGeomFontSizeHeader);
    self.labelSubtitle=makeAttributedLabel(self.contentView, @"(think “tasty”)", kGeomFontSizeSubheader);
    _labelTitle.textColor= WHITE;
    _labelIcon.textColor= WHITE;
    _labelSubtitle.textColor= WHITE;
    
    _labelTitle.shadowColor = BLACK;
    _labelTitle.shadowOffset = CGSizeMake(0, -1.0);
    
    _labelIcon.shadowColor = BLACK;
    _labelIcon.shadowOffset = CGSizeMake(0, -1.0);
    
    _labelSubtitle.shadowColor = BLACK;
    _labelSubtitle.shadowOffset = CGSizeMake(0, -1.0);
    
    [self doLayout];
}

- (void) provideEvent: (EventObject*)e;
{
    self.eventBeingEdited= e;
    
    float w= self.frame.size.width;
    if  (!w) {
        w= [UIScreen  mainScreen ].bounds.size.width;
    }
    
    if  ([e totalVenues] || e.primaryImageURL ||  e.primaryVenueImageIdentifier) {
        [self  coverHasImageNow];
    } else {
        [self  coverDoesNotHaveImage];
    }
    
    UIImage* placeholder= [UIImage imageNamed:@"background-image.jpg"];
    //HERE
    if (e.primaryImageURL ) {
        [self.imageViewContainer1 setImageWithURL:[NSURL URLWithString:e.primaryImageURL]
                                 placeholderImage:placeholder];
        
    } else if  (e.primaryVenueImageIdentifier ) {
        __weak EventCoordinatorCoverCell *weakSelf = self;
        OOAPI *api = [[OOAPI alloc] init];
        
        [api getRestaurantImageWithImageRef: e.primaryVenueImageIdentifier
                                   maxWidth:w
                                  maxHeight:0
                                    success:^(NSString *link) {
                                        ON_MAIN_THREAD(  ^{
                                            [weakSelf.imageViewContainer1
                                             setImageWithURL:[NSURL URLWithString:link]
                                             placeholderImage:placeholder];
                                        });
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    }];
    }
}

//------------------------------------------------------------------------------
// Name:    doAccept
// Purpose:
//------------------------------------------------------------------------------
- (void)doAccept: (id) sender
{
    if ( _userDidDecide) {
        return;
    }
    
    EventObject* event= self.eventBeingEdited;
    
    _userDidDecide=YES;
    __weak EventCoordinatorCoverCell *weakSelf = self;
    
    [OOAPI setParticipationOf:nil inEvent:event
                           to:YES
                      success:^(NSInteger eventID) {
                          NSLog (@"USER DID ACCEPT EVENT");
                          
                          ON_MAIN_THREAD(^{
                              [UIView animateWithDuration: 0.4 animations:^{
                                  [ weakSelf  doLayout];
                                  [weakSelf.buttonAccept setTitle: @"Accepted" forState:UIControlStateNormal];
                              } completion:^(BOOL finished) {
                              }
                               ];
                          });
                          
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          weakSelf.userDidDecide= NO;
                          
                          NSLog (@"ERROR WHILE ACCEPTING: %@", error);
                      }];
}

- (void)layoutSubviews
{
    [self doLayout];
}

- (void)doLayout
{
    float w= self.bounds.size.width;
    float h= self.bounds.size.height;
    _imageViewContainer1.frame= CGRectMake(0, 0, w, h);
    
    float yButtons= h-kGeomHeightButton;
    if ( self.inE3LMode) {
        const  float separatorWidth= 2;
        if ( _userDidDecide) {
            _buttonAccept.frame = CGRectMake(0, yButtons,w, kGeomHeightButton);
            _buttonDecline.hidden=  YES;
        } else {
            _buttonDecline.hidden=  NO;
            _buttonAccept.frame = CGRectMake(0, yButtons,w/2-separatorWidth/2, kGeomHeightButton);
            _buttonDecline.frame = CGRectMake(w/2+separatorWidth/2, yButtons, w/2-separatorWidth/2, kGeomHeightButton);
        }
    } else {
        _buttonSubmit.frame=  CGRectMake(0, yButtons,w,kGeomHeightButton);
    }
    
    if ( _labelIcon) {
        float h1= _labelIcon.intrinsicContentSize.height;
        float h2= _labelTitle.intrinsicContentSize.height;
        float h3= _labelSubtitle.intrinsicContentSize.height;
        float y=(yButtons-h1-h2-h3)/2;
        _labelIcon.frame = CGRectMake(0,y,w,h1); y += h1;
        _labelTitle.frame = CGRectMake(0,y,w,h2); y+= h2;
        _labelSubtitle.frame = CGRectMake(0,y,w,h3);
        
    } else {
        _labelTitle.frame = CGRectMake(0,0,w, yButtons);
    }
    
    
}

//------------------------------------------------------------------------------
// Name:    doDecline
// Purpose:
//------------------------------------------------------------------------------
- (void)doDecline: (id) sender
{
    if ( _userDidDecide) {
        return;
    }
    
    EventObject* event= self.eventBeingEdited;
    _userDidDecide=YES;
    
    UserObject *currentUser= [Settings sharedInstance].userObject;
    
    __weak EventCoordinatorCoverCell *weakSelf = self;
    
    [OOAPI setParticipationOf:currentUser inEvent:event
                           to:NO
                      success:^(NSInteger eventID) {
                          NSLog (@"USER DID REJECT EVENT");
                          [weakSelf.delegate userDidDeclineEvent];
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          ;
                      }];
}

//------------------------------------------------------------------------------
// Name:    doSubmit
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmit: (id) sender
{
    EventObject* event= self.eventBeingEdited;
    
    if (!event.date) {
        message( @"You need to specify a date and time when the event should take place.");
        return;
    }
    if  (!event.venues.count ) {
        message( @"You have not specified any restaurants.");
        return;
    }
    BOOL votingIsMandatory=  event.venues.count>1;
    if (!event.dateWhenVotingClosed  && votingIsMandatory) {
        message( @"You need to specify a date and time when voting should end (or a duration).");
        return;
    }
    NSDate* now= [NSDate date];
    if ( event.date.timeIntervalSince1970 < now.timeIntervalSince1970) {
        message( @"The event date and time is in the past.");
        return;
    }
    if (votingIsMandatory &&  event.dateWhenVotingClosed.timeIntervalSince1970 < now.timeIntervalSince1970) {
        message( @"The time when voting ends is in the past.");
        return;
    }
    if (votingIsMandatory &&  event.dateWhenVotingClosed.timeIntervalSince1970 >=  event.date.timeIntervalSince1970) {
        message( @"The time when voting ends is after the time when the event begins.");
        return;
    }
    
    __weak EventCoordinatorCoverCell *weakSelf = self;
    event.isComplete= YES;
    [OOAPI reviseEvent: event
               success:^(id responseObject) {
                   NSLog (@"REVISION SUCCESSFUL");
                   [ weakSelf.delegate userDidSubmitEvent];
                   
                   message( @"Event submitted.");
               } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                   NSLog (@"REVISION FAILED %@",e);
               }];
}

@end


//------------------------------------------------------------------------------

@interface EventCoordinatorWhoCell()
@property (nonatomic,strong) OOStripHeader *nameHeader;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@property (nonatomic,strong)  UILabel *labelWhoPending;
@property (nonatomic,strong)  UILabel *labelWhoResponded;
@property (nonatomic,strong)  UILabel *labelWhoVoted;
@property (nonatomic,strong)  UILabel *labelPersonIcon;
@property (nonatomic,strong) UIView* viewVerticalLine1;
@property (nonatomic,strong) UIView* viewVerticalLine2;
@property (nonatomic,strong) ParticipantsView *participantsView;
@end

@implementation EventCoordinatorWhoCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews= NO;
        
        self.labelWhoPending = makeAttributedLabel(self.contentView, @"", kGeomFontSizeHeader);
        self.labelWhoResponded = makeAttributedLabel(self.contentView, @"", kGeomFontSizeHeader);
        self.labelWhoVoted = makeAttributedLabel(self.contentView, @"", kGeomFontSizeHeader);
        _labelWhoPending.textColor= WHITE;
        _labelWhoResponded.textColor= WHITE;
        _labelWhoVoted.textColor= WHITE;
        
        self.clipsToBounds= YES;
        self.contentView.clipsToBounds= YES;
        
        self.viewVerticalLine1= makeView(self, BLACK);
        self.viewVerticalLine2= makeView(self, BLACK);
        self.participantsView= [[ ParticipantsView alloc] init];
        [self.contentView addSubview: _participantsView];
        _participantsView.delegate= self;
        
        //        self.nameHeader= [[OOStripHeader alloc] init];
        //        [self addSubview: _nameHeader];
        //        [self.nameHeader setName: @"WHO"];
        
        self.backgroundColor= UIColorRGBA( kColorCoordinatorBoxBackground);
    }
    return self;
    
}

- (void)userPressedButtonForProfile:(NSUInteger)userid
{
    [self.delegate userPressedButtonForProfile:userid];
}

- (void) provideEvent: (EventObject*)e;
{
    self.eventBeingEdited= e;
    [self updateWhoBox];
    [self initiateUpdateOfWhoBox];
}

- (void) initiateUpdateOfWhoBox
{
    EventObject* e= self.eventBeingEdited;
    [e refreshParticipantStatsFromServerWithSuccess:^{
        [self performSelectorOnMainThread:@selector(updateWhoBox) withObject:nil waitUntilDone:NO];
        
    }
                                            failure:^{
                                                NSLog (@"UNABLE TO REFRESH PARTICIPANTS STATS");
                                                
                                            }];
    
    [e refreshUsersFromServerWithSuccess:^{
        [self performSelectorOnMainThread:@selector(updateWhoBox) withObject:nil waitUntilDone:NO];
    } failure:^{
        NSLog (@"UNABLE TO REFRESH PARTICIPANTS OF EVENT");
    }];
    
}

- (void)updateWhoBox
{
    EventObject* e= self.eventBeingEdited;
    NSInteger pending= e.numberOfPeople - e.numberOfPeopleResponded;
    NSInteger responded= e.numberOfPeopleResponded;
    NSInteger  voted= e.numberOfPeopleVoted;
    
    NSString *countsStringPending= [NSString stringWithFormat: @"%lu\r%@",
                                    (unsigned long) pending,  LOCAL( @"PENDING")
                                    ];
    
    NSString *countsStringResponded= [NSString stringWithFormat:  @"%lu\r%@",
                                      (unsigned long) responded,  LOCAL( @"RESPONDED")
                                      ];
    
    NSString *countsStringVoted= [NSString stringWithFormat:  @"%lu\r%@",
                                  (unsigned long)voted,  LOCAL( @"VOTED")
                                  ];
    _labelWhoPending.attributedText= attributedStringOf(countsStringPending,  kGeomFontSizeHeader);
    _labelWhoResponded.attributedText= attributedStringOf(countsStringResponded,  kGeomFontSizeHeader);
    _labelWhoVoted.attributedText= attributedStringOf(countsStringVoted,  kGeomFontSizeHeader);
    
    [self.participantsView setEvent:e];
}

- (void)layoutSubviews
{
    [self doLayout];
}

- (void)doLayout
{
    float w= self.bounds.size.width;
    float h= self.bounds.size.height;
    float margin= kGeomSpaceEdge;
    self.nameHeader.frame= CGRectMake(0, -kGeomStripHeaderHeight, w,kGeomStripHeaderHeight);
    
    float subBoxWidth= w/3;
    float subBoxHeight= 2*h/3;
    float x= 0;
    _labelWhoResponded.frame = CGRectMake(x,0,subBoxWidth,subBoxHeight);
    x+= subBoxWidth;
    _viewVerticalLine1.frame = CGRectMake(x,kGeomStripHeaderHeight/2,1,subBoxHeight-kGeomStripHeaderHeight);
    _labelWhoPending.frame = CGRectMake(x,0,subBoxWidth,subBoxHeight);
    x+= subBoxWidth;
    _viewVerticalLine2.frame = CGRectMake(x,kGeomStripHeaderHeight/2,1,subBoxHeight-kGeomStripHeaderHeight);
    _labelWhoVoted.frame = CGRectMake(x,0,subBoxWidth,subBoxHeight);
    
    _participantsView.frame = CGRectMake(0,subBoxHeight- margin,w,subBoxHeight/2);
}

@end


//------------------------------------------------------------------------------

@interface EventCoordinatorWhereCell()
@property (nonatomic,strong) OOStripHeader *nameHeader;
@property (nonatomic,strong) EventObject *eventBeingEdited;
@property (nonatomic,strong) UICollectionView *venuesCollectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *cvLayout;

@end

@implementation EventCoordinatorWhereCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews= NO;
        self.backgroundColor= UIColorRGBA( kColorCoordinatorBoxBackground);
        
        self.cvLayout= [[UICollectionViewFlowLayout alloc] init];
        self.cvLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _cvLayout.itemSize = CGSizeMake(110, 127);
        _cvLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _cvLayout.minimumInteritemSpacing = 0;
        _cvLayout.minimumLineSpacing = 0;
        
        self.venuesCollectionView = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout: _cvLayout];
        _venuesCollectionView.delegate = self;
        _venuesCollectionView.dataSource = self;
        _venuesCollectionView.showsHorizontalScrollIndicator = NO;
        _venuesCollectionView.showsVerticalScrollIndicator = NO;
        _venuesCollectionView.alwaysBounceHorizontal = YES;
        _venuesCollectionView.allowsSelection = YES;
        _venuesCollectionView.backgroundColor= CLEAR;
#define CV_CELL_REUSE_IDENTIFER @"E3_CV"
#define CV_CELL_REUSE_IDENTIFERP @"E3_CV_plus"
        [_venuesCollectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier: CV_CELL_REUSE_IDENTIFER];
        [_venuesCollectionView registerClass:[PlusCell class] forCellWithReuseIdentifier: CV_CELL_REUSE_IDENTIFERP];
        [self addSubview: _venuesCollectionView];
        
        //        self.nameHeader= [[OOStripHeader alloc] init];
        //        [self addSubview: _nameHeader];
        //        [self.nameHeader setName: @"WHERE"];
    }
    return self;
}

- (void) userPressedNewRestaurant;
{
    [self.delegate userPressedNewRestaurant];
}

- (void) provideEvent: (EventObject*)e;
{
    self.eventBeingEdited= e;
    [self updateWhereBox];
}

- (void)layoutSubviews
{
    [self doLayout];
}

- (void)doLayout
{
    float w = width(self);
    float h = height(self);
    _venuesCollectionView.frame = CGRectMake(0, 0, w, h);
}

- (void)updateWhereBox
{
    NSLog  (@"TOTAL VENUES %lu", (unsigned long)[self.eventBeingEdited  totalVenues]);
    [self.venuesCollectionView reloadData ];
}

#pragma mark - Collection View stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger total = [self.eventBeingEdited totalVenues];
    return 1+ total ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger total = [self.eventBeingEdited totalVenues];
    NSInteger row= indexPath.row;
    if (row== total ) {
        
        PlusCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:CV_CELL_REUSE_IDENTIFERP
                                                                  forIndexPath:indexPath];
        cvc.delegate=  self;
        
        return cvc;
    }
    
    TileCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:CV_CELL_REUSE_IDENTIFER
                                                                forIndexPath:indexPath];
    cvc.backgroundColor = GRAY;
    RestaurantObject *venue= [self.eventBeingEdited getNthVenue:row];
    cvc.restaurant = venue;
    return cvc;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    RestaurantObject *venue= [self.eventBeingEdited getNthVenue:row];
    
    [self.delegate userTappedOnVenue: venue];
}

@end

//------------------------------------------------------------------------------

@interface EventCoordinatorWhenCell()
@property (nonatomic, strong) OOStripHeader *nameHeader;
@property (nonatomic, strong) EventObject *eventBeingEdited;
@property (nonatomic, strong) UILabel *labelTime;
@property (nonatomic, strong) UILabel *labelMonth;
@property (nonatomic, strong) UILabel *labelDay0;
@property (nonatomic, strong) UILabel *labelDay1;
@property (nonatomic, strong) UILabel *labelDay2;
@property (nonatomic, strong) UILabel *labelDay3;
@property (nonatomic, strong) UILabel *labelDay4;
@property (nonatomic, strong) UILabel *labelDay5;
@property (nonatomic, strong) UILabel *labelDay6;
@property (nonatomic, strong) UILabel *labelDate0;
@property (nonatomic, strong) UILabel *labelDate1;
@property (nonatomic, strong) UILabel *labelDate2;
@property (nonatomic, strong) UILabel *labelDate3;
@property (nonatomic, strong) UILabel *labelDate4;
@property (nonatomic, strong) UILabel *labelDate5;
@property (nonatomic, strong) UILabel *labelDate6;
@property (nonatomic, strong) UIView *viewTodayBubble;
@property (nonatomic, strong) UIView *viewhorizontalLine;
@property (nonatomic, strong) PieView *pieHour;
@end

@implementation EventCoordinatorWhenCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizesSubviews= NO;
        self.backgroundColor= UIColorRGBA( kColorCoordinatorBoxBackground);
        
        self.clipsToBounds= NO;
        
        self.labelTime= makeLabel(self,  @"", 18);
        self.labelTime.font= [UIFont  fontWithName: kFontLatoBold  size:18];
        _labelTime.textColor= WHITE;
        
        self.pieHour= [[PieView alloc] init];
        [self  addSubview: _pieHour];
        
        self.labelDay0 = makeLabel(self, @"S", kGeomFontSizeHeader);
        self.labelDay1 = makeLabel(self, @"M", kGeomFontSizeHeader);
        self.labelDay2 = makeLabel(self, @"T", kGeomFontSizeHeader);
        self.labelDay3 = makeLabel(self, @"W", kGeomFontSizeHeader);
        self.labelDay4 = makeLabel(self, @"R", kGeomFontSizeHeader);
        self.labelDay5 = makeLabel(self, @"F", kGeomFontSizeHeader);
        self.labelDay6 = makeLabel(self, @"S", kGeomFontSizeHeader);
        _labelDay0.textColor = GRAY;
        _labelDay1.textColor = GRAY;
        _labelDay2.textColor = GRAY;
        _labelDay3.textColor = GRAY;
        _labelDay4.textColor = GRAY;
        _labelDay5.textColor = GRAY;
        _labelDay6.textColor = GRAY;
        
        self.labelDate0= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.labelDate1= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.labelDate2= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.labelDate3= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.labelDate4= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.labelDate5= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.labelDate6= makeLabel(self,  @"", kGeomFontSizeHeader);
        self.viewTodayBubble= makeView(self, BLACK);
        
        self.labelMonth= makeLabel(self,  @"", kGeomFontSizeHeader);
        _labelMonth.font= [UIFont  fontWithName: kFontLatoBold  size:kGeomFontSizeHeader];
        _labelMonth.textColor= WHITE;
        
        self.viewhorizontalLine=makeView(self, GRAY);
        _viewhorizontalLine.backgroundColor= GRAY;
        
        //        self.nameHeader= [[OOStripHeader alloc] init];
        //        [self.contentView addSubview: _nameHeader];
        //        [self.nameHeader setName: @"WHEN"];
    }
    
    return self;
}

- (void) provideEvent: (EventObject*)e;
{
    self.eventBeingEdited= e;
    [self updateWhenBox];
}

- (void)layoutSubviews
{
    [self doLayout];
}

- (void)doLayout
{
    float w = width(self);
    float h = height(self);
    self.nameHeader.frame= CGRectMake(0, -kGeomStripHeaderHeight, w,kGeomStripHeaderHeight);
    
    _pieHour.frame = CGRectMake(2*w/3 + w/6 - kGeomEventCoordinatorPieDiameter/2,
                                kGeomStripHeaderHeight/2+ kGeomEventCoordinatorBoxHeight/4 - kGeomEventCoordinatorPieDiameter/2,
                                kGeomEventCoordinatorPieDiameter, kGeomEventCoordinatorPieDiameter);
    
    _labelTime.frame = CGRectMake(2*w/3,  h/2,
                                  w/3, h/2);
    _labelMonth.frame = CGRectMake(0,0,w,h);
    float dayCellWidth =  floorf((2*w/3-2*kGeomSpaceEdge)/7 );
    if  (dayCellWidth> 40 ) {
        dayCellWidth= 40;
    }
    float dayCellHeight=  floorf((h-kGeomStripHeaderHeight/2-2*kGeomSpaceEdge)/3);
    float requiredWidth= dayCellWidth * 7;
    float x0=  (2*w/3 - requiredWidth)/2;
    float x=x0;
    float y= kGeomStripHeaderHeight/2;
    
    self.labelMonth.frame = CGRectMake(x0,y,requiredWidth,dayCellHeight);
    y+= dayCellHeight;
    self.viewhorizontalLine.frame = CGRectMake(x0,y,requiredWidth,1);
    y += 5;
    self.labelDay0.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDay1.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDay2.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDay3.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDay4.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDay5.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDay6.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight);
    x=x0;
    y+= dayCellHeight;
    self.labelDate0.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDate1.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDate2.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDate3.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDate4.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDate5.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight); x += dayCellWidth;
    self.labelDate6.frame = CGRectMake(x,y,dayCellWidth,dayCellHeight);
    
    NSDate* dateToDisplay= self.eventBeingEdited.date ?: [NSDate date];
    
    NSInteger dayNumber= getLocalDayNumber(dateToDisplay);
    const float bubbleDiameter=dayCellWidth-5;
    self.viewTodayBubble.frame = CGRectMake(0,0,bubbleDiameter,bubbleDiameter);
    [self sendSubviewToBack: self.viewTodayBubble ];
    _viewTodayBubble.layer.cornerRadius= bubbleDiameter/2;
    switch (dayNumber) {
        case 0:[_viewTodayBubble setCenter:_labelDate0.center];  break;
        case 1:[_viewTodayBubble setCenter:_labelDate1.center];  break;
        case 2:[_viewTodayBubble setCenter:_labelDate2.center];  break;
        case 3:[_viewTodayBubble setCenter:_labelDate3.center];  break;
        case 4:[_viewTodayBubble setCenter:_labelDate4.center];  break;
        case 5:[_viewTodayBubble setCenter:_labelDate5.center];  break;
        case 6:[_viewTodayBubble setCenter:_labelDate6.center];  break;
            
    }
    
    [self.pieHour setHour: getLocalHour(dateToDisplay)];
    
    NSUInteger u= [dateToDisplay timeIntervalSince1970];
    if (dayNumber>0 ) {
        u-= 24*60*60*dayNumber;
    }
    
    UIColor *inactiveColor= GRAY;
    UIColor *activeColor= YELLOW;
    
    for (int i=0; i < 7; i++) {
        NSDate *date= [NSDate dateWithTimeIntervalSince1970:u];
        NSInteger day= getLocalDayOfMonth( date);
        
        switch (i) {
            case 0:
                self.labelDate0.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate0.textColor= i==dayNumber ? activeColor : inactiveColor;
                break;
            case 1:
                self.labelDate1.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate1.textColor= i==dayNumber ? activeColor: inactiveColor;
                break;
            case 2:
                self.labelDate2.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate2.textColor= i==dayNumber ? activeColor: inactiveColor;
                break;
            case 3:
                self.labelDate3.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate3.textColor= i==dayNumber ? activeColor: inactiveColor;
                break;
            case 4:
                self.labelDate4.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate4.textColor= i==dayNumber ? activeColor: inactiveColor;
                break;
            case 5:
                self.labelDate5.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate5.textColor= i==dayNumber ? activeColor: inactiveColor;
                break;
            case 6:
                self.labelDate6.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                self.labelDate6.textColor= i==dayNumber ? activeColor: inactiveColor;
                break;
            default:
                break;
        }
        u += 24 *3600;
    }
    if ( !self.eventBeingEdited.date) {
        self.viewTodayBubble.hidden= YES;
        self.pieHour.hidden= YES;
        _labelMonth.text= expressLocalMonth( [NSDate date]);
        _labelTime.text=  @"Tap to\rset date.";
        _labelTime.frame= CGRectMake(_labelTime.frame.origin.x,0,
                                     _labelTime.frame.size.width,h);
    } else {
        self.viewTodayBubble.hidden= NO;
        self.pieHour.hidden= NO;
    }
    
}

- (void) updateWhenBox
{
    NSString *string=nil;
    
    EventObject* event= self.eventBeingEdited;
    if  (event.date ) {
        string=[NSString stringWithFormat:  @"%@", expressLocalDateTime(event.date)];
    } else {
        string= [NSString stringWithFormat: @"%@",
                 LOCAL( @"TAP TO SELECT A DATE AND TIME")
                 ];
    }
    
    _labelTime.text= [expressLocalTime(self.eventBeingEdited.date) lowercaseString ];
    _labelMonth.text= expressLocalMonth( _eventBeingEdited.date);
}

@end

//------------------------------------------------------------------------------
@interface EventCoordinatorVC ()
@property (nonatomic,strong)  UITableView* table;

@property (nonatomic,strong) NSTimer *timerForUpdating;
@property (nonatomic,assign) BOOL transitioning;

@property (nonatomic,assign) BOOL inE3LMode;
@end

@implementation EventCoordinatorVC

- (void)dealloc
{
    if  (_timerForUpdating ) {
        [_timerForUpdating invalidate];
    }
}

- (void) enableE3LMode;
{
    _inE3LMode= YES;
}

- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    NSString* eventName= self.eventBeingEdited.name;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= BLACK;
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    self.table= makeTable(  self.view, self);
    _table.separatorStyle=  UITableViewCellSeparatorStyleNone;
    _table.sectionHeaderHeight= kGeomSeparatorHeight;
    _table.backgroundColor= BLACK;
    _table.delaysContentTouches= YES;
    
#define TABLE_REUSE_COVER_IDENTIFIER @"e1cover"
#define TABLE_REUSE_WHO_IDENTIFIER @"e1who"
#define TABLE_REUSE_WHERE_IDENTIFIER @"e1where"
#define TABLE_REUSE_WHEN_IDENTIFIER @"e1when"
#define TABLE_REUSE_NEW_IDENTIFIER @"e1new"
    
    [_table  registerClass:[ EventCoordinatorNewCell class] forCellReuseIdentifier:TABLE_REUSE_NEW_IDENTIFIER];
    [_table  registerClass:[ EventCoordinatorCoverCell class] forCellReuseIdentifier:TABLE_REUSE_COVER_IDENTIFIER];
    [_table  registerClass:[ EventCoordinatorWhoCell class] forCellReuseIdentifier:TABLE_REUSE_WHO_IDENTIFIER];
    [_table  registerClass:[ EventCoordinatorWhereCell class] forCellReuseIdentifier:TABLE_REUSE_WHERE_IDENTIFIER];
    [_table  registerClass:[ EventCoordinatorWhenCell class] forCellReuseIdentifier:TABLE_REUSE_WHEN_IDENTIFIER];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] init];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0, 0, kGeomWidthMenuButton, kGeomWidthMenuButton);
    moreButton.titleLabel.textAlignment= NSTextAlignmentRight;
    [moreButton withIcon:kFontIconMore fontSize:kGeomIconSize width:kGeomWidthMenuButton height:kGeomWidthMenuButton backgroundColor:kColorClear target:self selector:@selector(userPressedMenuButton:)];
    bbi.customView = moreButton;
    [moreButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[bbi];
    
    [self updateBoxes];
    
}

- (void) userPressedNewRestaurant;
{
    [self userTappedWhereBox:nil];
}

- (void)userTappedPhotoBox: (id) sender
{
    [self  presentPhotoGallery];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventObject* event=self.eventBeingEdited;
    NSInteger section = indexPath.section;
    
    switch (section) {
        case 0: {
            EventCoordinatorCoverCell *cell;
            cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_COVER_IDENTIFIER forIndexPath:indexPath];
            cell.inE3LMode=self.inE3LMode;
            cell.delegate= self;
            cell.selectionStyle= UITableViewCellSelectionStyleNone;
            [cell provideEvent: event];
            return cell;
        }
            
        case 1:{
            if (! [self.eventBeingEdited totalUsers]) {
                EventCoordinatorNewCell* cell=[tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_NEW_IDENTIFIER forIndexPath:indexPath];
                [ cell setMessage: @"Tap to invite people"];
                return cell;
            }
            EventCoordinatorWhoCell *cell;
            cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_WHO_IDENTIFIER forIndexPath:indexPath];
            cell.inE3LMode=self.inE3LMode;
            cell.delegate= self;
            cell.selectionStyle= UITableViewCellSelectionStyleNone;
            [cell provideEvent: event];
            return cell;
        }
            
        case 2:{
            if (!self.eventBeingEdited.date && !self.eventBeingEdited.dateWhenVotingClosed) {
                EventCoordinatorNewCell* cell=[tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_NEW_IDENTIFIER forIndexPath:indexPath];
                [ cell setMessage: @"Tap to pick a time"];
                return cell;
            }
            EventCoordinatorWhenCell *cell;
            cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_WHEN_IDENTIFIER forIndexPath:indexPath];
            cell.inE3LMode=self.inE3LMode;
            cell.delegate= self;
            cell.selectionStyle= UITableViewCellSelectionStyleNone;
            [cell provideEvent: event];
            return cell;
        }
            
        case 3:{
            if (! [self.eventBeingEdited totalVenues]) {
                EventCoordinatorNewCell* cell=[tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_NEW_IDENTIFIER forIndexPath:indexPath];
                [ cell setMessage: @"Tap to select places"];
                return cell;
            }
            EventCoordinatorWhereCell *cell;
            cell = [tableView dequeueReusableCellWithIdentifier: TABLE_REUSE_WHERE_IDENTIFIER forIndexPath:indexPath];
            cell.inE3LMode=self.inE3LMode;
            cell.delegate= self;
            cell.selectionStyle= UITableViewCellSelectionStyleNone;
            [cell provideEvent: event];
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if  (!section) {
        return  kGeomEventCoordinatorBoxHeightTopmost;
    }
    return kGeomEventCoordinatorBoxHeight ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if  (!section) {
        return 0;
    }
    return kGeomSeparatorHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionString= nil;
    switch ( section) {
        case 0:  {
            UILabel *sectionHeader= [[UILabel alloc] initWithFrame: CGRectZero];
            return sectionHeader;
        }
        case 1: sectionString=   @" WHO";break;
        case 2: sectionString=   @" WHEN";break;
        case 3: sectionString=   @" WHERE";break;
            
    }
    
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame: CGRectNull];
    sectionHeader.backgroundColor = CLEAR;
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeStripHeader];
    sectionHeader.textColor = WHITE;
    sectionHeader.text = sectionString;
    return sectionHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog (@"USER TAPPED %ld",(long)row);   
    
    switch (section) {
        case 0:
            [self  userTappedPhotoBox:nil];
            break;
        case 1:
            [self  userTappedWhoBox:nil];
            break;
        case 2:
            [self  userTappedWhenBox:nil];
            break;
        case 3:
            [self  userTappedWhereBox: nil];
            break;
        default:
            break;
    }
    
    // RULE: We stop showing the central + after the user has transitioned to at least one other screen.
    self.isNewEvent= NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//------------------------------------------------------------------------------
// Name:    presentPhotoGallery
// Purpose:
//------------------------------------------------------------------------------
- (void)presentPhotoGallery
{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        return;
    }
    
    UIImagePickerController *ic = [[UIImagePickerController alloc] init];
    [ic setAllowsEditing: YES];
    [ic setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    [ic setDelegate: self];
    [ self presentViewController: ic animated: YES completion: NULL];
}

//------------------------------------------------------------------------------
// Name:    didFinishPickingMediaWithInfo
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image=  info[ @"UIImagePickerControllerEditedImage"];
    if (!image) {
        image= info[ @"UIImagePickerControllerEditedImage"];
    }
    
    EventCoordinatorCoverCell *cell= [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    __weak  EventCoordinatorVC *weakSelf = self;
    [OOAPI uploadPhoto:image
             forObject:self.eventBeingEdited success:^{
                 NSLog (@" upload of image for event successful.");
                 [OOAPI getEventByID:weakSelf.eventBeingEdited.eventID
                             success:^(EventObject *event) {
                                 weakSelf.eventBeingEdited=event;
                                 [weakSelf.delegate userDidAlterEvent];
                                 ON_MAIN_THREAD(^{
                                     [cell setPhoto: image];
                                     [cell provideEvent: event];
                                 });
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog (@" upload of image succeeded but refetch of event NOT successful.");
                                 
                             }];
             } failure:^(NSError *error) {
                 NSLog (@" upload of image for event NOT successful.");
             }];
    
    [self  dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------------------------------------------------
// Name:    imagePickerControllerDidCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self  dismissViewControllerAnimated:YES completion:nil];
}

- (void)userPressedButtonForProfile:(NSUInteger)userid
{
    __weak EventCoordinatorVC *weakSelf = self;
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

- (void) verifyDeletion
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Really delete?")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                     }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self deleteEvent];
                                                     [self.navigationController  popViewControllerAnimated:YES];
                                                 }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self presentViewController:a animated:YES completion:nil];
}

- (void)castVote
{
    NSDate *now= [NSDate date];
    NSDate *end= self.eventBeingEdited.dateWhenVotingClosed;
    BOOL votingIsDone=end && now.timeIntervalSince1970>end.timeIntervalSince1970;
    EventObject *event= self.eventBeingEdited;
    
    EventParticipantVC* vc= [[EventParticipantVC  alloc] init];
    vc.eventBeingEdited= event;
    vc.votingIsDone= votingIsDone;
    [self.navigationController pushViewController:vc animated:YES ];
}

- (void) userPressedMenuButton: (id) sender
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Options")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete event"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * action) {
                                                       [self verifyDeletion];
                                                   }];
    
    UIAlertAction *vote = [UIAlertAction actionWithTitle:@"Cast vote"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self castVote];
                                                 }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                         
                                                     }];
    [a addAction:delete];
    [a addAction:vote];
    [a addAction:cancel];
    
    [self presentViewController:a animated:YES completion:nil];
    
}

- (void)deleteEvent
{
    [self.delegate userDidAlterEvent];
    [OOAPI deleteEvent:self.eventBeingEdited.eventID
               success:^{
                   [self dismissViewControllerAnimated:YES
                                            completion:^{
                                                // XX:  need to force event list to reload
                                            }];
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   message( @"Failed to delete event.");
               }];
    
}

- (void)updateBoxes
{
    if  (!_timerForUpdating) {
        // RULE: Initially just display the basic information.
        self.timerForUpdating= [NSTimer scheduledTimerWithTimeInterval:30 target: self.table
                                                              selector: @selector ( reloadData)
                                                              userInfo:nil repeats:YES];
    }
    
}

- (void)userDidAlterEventParticipants
{
    [self.delegate userDidAlterEvent];
}

- (void)datesChanged
{
    [self.eventBeingEdited sendDatesToServer];
    [self.delegate userDidAlterEvent];
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
    
    __weak EventCoordinatorVC *weakSelf = self;
    
    [self updateBoxes];
    
    if ( self.eventBeingEdited.hasBeenAltered) {
        [self.delegate userDidAlterEvent];
    }
    
    [self.eventBeingEdited refreshParticipantStatsFromServerWithSuccess:^{
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
            
        });
    }
                                                                failure:^{
                                                                    NSLog (@"UNABLE TO REFRESH PARTICIPANTS STATS");
                                                                    
                                                                }];
    
    [self.eventBeingEdited refreshUsersFromServerWithSuccess:^{
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
            
        });    } failure:^{
            NSLog (@"UNABLE TO REFRESH PARTICIPANTS OF EVENT");
        }];
    
    // RULE: After basic info is displayed, fetch what's on the backend.
    [self.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
        NSInteger numberOfVenues= self.eventBeingEdited.numberOfVenues;
        NSLog  (@"# VENUES FOR EVENT %ld", ( unsigned long)numberOfVenues);
        ON_MAIN_THREAD(^(){
            [weakSelf.table  reloadData];
            
        });
        
    } failure:^{
        NSLog (@"UNABLE TO REFRESH VENUES FOR EVENT.");
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _transitioning= NO;
    
    if  (_timerForUpdating ) {
        [_timerForUpdating invalidate];
        self.timerForUpdating= nil;
    }
    [super viewDidDisappear:animated];
}

- (void)userTappedWhoBox: (id) sender
{
    if  (_transitioning ) {
        return;
    }
    _transitioning= YES;
    
    EventWhoVC* vc= [[EventWhoVC alloc] init];
    vc.delegate= self;
    vc.editable= !self.inE3LMode;
    vc.eventBeingEdited= self.eventBeingEdited;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)userTappedWhenBox: (id) sender
{
    if  (_transitioning ) {
        return;
    }
    _transitioning= YES;
    
    EventWhenVC* vc= [[EventWhenVC alloc] init];
    vc.delegate= self;
    vc.editable= !self.inE3LMode;
    vc.eventBeingEdited= self.eventBeingEdited;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userTappedWhereBox: (UITapGestureRecognizer*) sender
{
    if  (_transitioning ) {
        return;
    }
    _transitioning= YES;
    
    EmptyListVC* vc= [[EmptyListVC alloc] init];
    vc.eventBeingEdited= self.eventBeingEdited;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) userTappedOnVenue:(RestaurantObject*)venue;
{
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    vc.restaurant = venue;
    ANALYTICS_EVENT_UI(@"RestaurantVC-from-EventCoordinator");
    
    // RULE: If we are in the E3L mode, the user cannot remove the restaurant from the event.
    if  (!self.inE3LMode) {
        vc.eventBeingEdited= self.eventBeingEdited;
    }
    
    [self.navigationController pushViewController:vc animated:YES ];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.table  reloadData];
}

- (void)userDidSubmitEvent
{
    [self.delegate userDidAlterEvent];
    [self.navigationController  popViewControllerAnimated:YES];
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
}

@end
