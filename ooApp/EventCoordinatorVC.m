//
//  EventCoordinatorVC.m E3
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

@interface EventCoordinatorVC ()
@property (nonatomic,strong)  UIButton* buttonSubmit;
@property (nonatomic,strong)  UIScrollView* scrollView;

@property (nonatomic,strong)  UIView *viewContainer1;
@property (nonatomic,strong)  UIImageView *imageViewContainer1;
@property (nonatomic,strong)  UILabel *labelEventCover;

@property (nonatomic,strong)  UIView *viewContainer2;
@property (nonatomic,strong)  UILabel *labelWhoPending;
@property (nonatomic,strong)  UILabel *labelWhoResponded;
@property (nonatomic,strong)  UILabel *labelWhoVoted;
@property (nonatomic,strong)  UILabel *labelPersonIcon;
@property (nonatomic,strong) UIView* viewVerticalLine1;
@property (nonatomic,strong) UIView* viewVerticalLine2;

@property (nonatomic,strong)  UIView *viewContainer3;
@property (nonatomic,strong)  UILabel *labelTime;
@property (nonatomic,strong)  UILabel *labelMonth;
@property (nonatomic,strong)  UILabel *labelDay0;
@property (nonatomic,strong)  UILabel *labelDay1;
@property (nonatomic,strong)  UILabel *labelDay2;
@property (nonatomic,strong)  UILabel *labelDay3;
@property (nonatomic,strong)  UILabel *labelDay4;
@property (nonatomic,strong)  UILabel *labelDay5;
@property (nonatomic,strong)  UILabel *labelDay6;
@property (nonatomic,strong)  UILabel *labelDate0;
@property (nonatomic,strong)  UILabel *labelDate1;
@property (nonatomic,strong)  UILabel *labelDate2;
@property (nonatomic,strong)  UILabel *labelDate3;
@property (nonatomic,strong)  UILabel *labelDate4;
@property (nonatomic,strong)  UILabel *labelDate5;
@property (nonatomic,strong)  UILabel *labelDate6;
@property (nonatomic,strong) UIView* viewTodayBubble;
@property (nonatomic,strong) UIView* viewhorizontalLine;
@property (nonatomic,strong) PieView *pieHour;
@property (nonatomic,strong)  UIView *viewContainer4;

@property (nonatomic,strong) OOStripHeader *headerWhere;
@property (nonatomic,strong) OOStripHeader *headerWho;
@property (nonatomic,strong) OOStripHeader *headerWhen;

@property (nonatomic,strong) UITapGestureRecognizer *tap1;
@property (nonatomic,strong) UITapGestureRecognizer *tap2;
@property (nonatomic,strong) UITapGestureRecognizer *tap3;
@property (nonatomic,strong) UITapGestureRecognizer *tap4;

@property (nonatomic,strong) UICollectionView *venuesCollectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *cvLayout;

@property (nonatomic,strong) NSTimer *timerForUpdating;
@property (nonatomic,assign) BOOL transitioning;

@property (nonatomic,strong) NSMutableArray* viewsForFaces;
@property (nonatomic,strong)  UILabel*labelEllipsis;
@end

@implementation EventCoordinatorVC
{
}

- (void)dealloc
{
    if  (_timerForUpdating ) {
        [_timerForUpdating invalidate];
    }
    [_viewContainer1 removeGestureRecognizer:_tap1];
    [_viewContainer2 removeGestureRecognizer:_tap2];
    [_viewContainer3 removeGestureRecognizer:_tap3];
    [_viewContainer4 removeGestureRecognizer:_tap4];
}

- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    NSString* eventName= APP.eventBeingEdited.name;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    _scrollView= makeScrollView(self.view, self);
    [_scrollView setCanCancelContentTouches:YES];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] init];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0, 0, kGeomWidthMenuButton, kGeomWidthMenuButton);
    moreButton.titleLabel.textAlignment= NSTextAlignmentRight;
    [moreButton withIcon:kFontIconMore fontSize:kGeomIconSize width:kGeomWidthMenuButton height:kGeomWidthMenuButton backgroundColor:kColorClear target:self selector:@selector(userPressedMenuButton:)];
    bbi.customView = moreButton;
    self.navigationItem.rightBarButtonItems = @[bbi];
    
    self.viewContainer4= makeView(self.scrollView, WHITE);
    _viewContainer4.layer.borderWidth= 1;
    _viewContainer4.layer.borderColor= GRAY.CGColor;
    _viewContainer4.tag=4;
    
    self.cvLayout= [[UICollectionViewFlowLayout alloc] init];
    self.cvLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGRect r = self.view.window.bounds;
    r.size.height=200;
    self.venuesCollectionView = [[UICollectionView alloc] initWithFrame: r collectionViewLayout: _cvLayout];
    _venuesCollectionView.delegate = self;
    _venuesCollectionView.dataSource = self;
    _venuesCollectionView.showsHorizontalScrollIndicator = NO;
    _venuesCollectionView.showsVerticalScrollIndicator = NO;
    _venuesCollectionView.alwaysBounceHorizontal = YES;
    _venuesCollectionView.allowsSelection = YES;
    _venuesCollectionView.backgroundColor= CLEAR;
    [_scrollView addSubview: _venuesCollectionView];
#define CV_CELL_REUSE_IDENTIFER @"E3_CV"
    [_venuesCollectionView registerClass:[TileCVCell class] forCellWithReuseIdentifier: CV_CELL_REUSE_IDENTIFER];
    
    self.viewContainer1= makeView(self.scrollView, WHITE);
    _imageViewContainer1= makeImageView(_viewContainer1,  @"background-image.jpg");
    _imageViewContainer1.contentMode= UIViewContentModeScaleAspectFill;
    _viewContainer1.clipsToBounds= YES;
    
    self.labelEventCover= makeLabel(self.viewContainer1, APP.eventBeingEdited.name ?: @"UNNAMED EVENT", kGeomEventHeadingFontSize);
    _labelEventCover.textColor= WHITE;
    _labelEventCover.font= [UIFont  fontWithName: kFontLatoBoldItalic size:kGeomEventHeadingFontSize];
    _viewContainer1.layer.borderWidth= 1;
    _viewContainer1.layer.borderColor= GRAY.CGColor;
    NSString* submitButtonMessage;
    if  (APP.eventBeingEdited.isComplete) {
        submitButtonMessage=@"EVENT SUBMITTED";
    } else {
        submitButtonMessage=@"SUBMIT EVENT";
    }
    _buttonSubmit= makeButton(self.viewContainer1, submitButtonMessage,
                              kGeomFontSizeHeader, YELLOW, UIColorRGBA(0xb0000000), self, @selector(doSubmit:), 0);
    _buttonSubmit.titleLabel.numberOfLines= 0;
    _buttonSubmit.titleLabel.textAlignment= NSTextAlignmentCenter;
    _buttonSubmit.enabled= NO;
    
    self.viewContainer2= makeView(self.scrollView, WHITE);
    self.labelWhoPending = makeAttributedLabel(self.viewContainer2, @"", kGeomFontSizeHeader);
    self.labelWhoResponded = makeAttributedLabel(self.viewContainer2, @"", kGeomFontSizeHeader);
    self.labelWhoVoted = makeAttributedLabel(self.viewContainer2, @"", kGeomFontSizeHeader);

    _viewContainer2.layer.borderWidth= 1;
    _viewContainer2.layer.borderColor= GRAY.CGColor;
    self.viewVerticalLine1= makeView(self.viewContainer2, BLACK);
    self.viewVerticalLine2= makeView(self.viewContainer2, BLACK);
    self.labelEllipsis= makeLabel(self.viewContainer2,  @"...", kGeomFontSizeHeader);

    self.viewContainer3= makeView(self.scrollView, WHITE);
//    self.labelWhen = makeAttributedLabel(self.viewContainer3, @"DATE\rTIME", kGeomFontSizeHeader);
    _viewContainer3.layer.borderWidth= 1;
    _viewContainer3.layer.borderColor= GRAY.CGColor;
    
    self.labelTime= makeLabel(self.viewContainer3,  @"", 18);
    self.labelTime.font= [UIFont  fontWithName: kFontLatoBold  size:18];
    
    self.pieHour= [[PieView alloc] init];
    [self.viewContainer3  addSubview: _pieHour];
    
    self.labelDay0= makeLabel(self.viewContainer3,  @"S", kGeomFontSizeHeader);
    self.labelDay1= makeLabel(self.viewContainer3,  @"M", kGeomFontSizeHeader);
    self.labelDay2= makeLabel(self.viewContainer3,  @"T", kGeomFontSizeHeader);
    self.labelDay3= makeLabel(self.viewContainer3,  @"W", kGeomFontSizeHeader);
    self.labelDay4= makeLabel(self.viewContainer3,  @"R", kGeomFontSizeHeader);
    self.labelDay5= makeLabel(self.viewContainer3,  @"F", kGeomFontSizeHeader);
    self.labelDay6= makeLabel(self.viewContainer3,  @"S", kGeomFontSizeHeader);
    _labelDay0.textColor= UIColorRGB(0xff808080);
    _labelDay1.textColor= UIColorRGB(0xff808080);
    _labelDay2.textColor= UIColorRGB(0xff808080);
    _labelDay3.textColor= UIColorRGB(0xff808080);
    _labelDay4.textColor= UIColorRGB(0xff808080);
    _labelDay5.textColor= UIColorRGB(0xff808080);
    _labelDay6.textColor= UIColorRGB(0xff808080);
    
    self.labelDate0.textColor= BLACK;
    self.labelDate1.textColor= BLACK;
    self.labelDate2.textColor= BLACK;
    self.labelDate3.textColor= BLACK;
    self.labelDate4.textColor= BLACK;
    self.labelDate5.textColor= BLACK;
    self.labelDate6.textColor= BLACK;
    
    self.labelDate0= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.labelDate1= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.labelDate2= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.labelDate3= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.labelDate4= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.labelDate5= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.labelDate6= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    self.viewTodayBubble= makeView(self.viewContainer3, BLACK);

    self.labelMonth= makeLabel(self.viewContainer3,  @"", kGeomFontSizeHeader);
    _labelMonth.font= [UIFont  fontWithName: kFontLatoBold  size:kGeomFontSizeHeader];
    
    self.viewhorizontalLine=makeView(self.viewContainer3, GRAY);
    _viewhorizontalLine.backgroundColor= UIColorRGB(0xff808080);
    
    self.headerWho= [[OOStripHeader alloc] init];
    self.headerWhen= [[OOStripHeader alloc] init];
    self.headerWhere= [[OOStripHeader alloc] init];
    
    [self.headerWho setName: @"WHO" ];
    [self.headerWhen setName: @"WHEN" ];
    [self.headerWhere setName: @"WHERE" ];
    [_scrollView addSubview: self.headerWho];
    [_scrollView addSubview: self.headerWhen];
    [_scrollView addSubview: self.headerWhere];

    [self.headerWhere enableAddButtonWithTarget: self action:@selector(userTappedWhereBox:)];
    
    UITapGestureRecognizer *tap2= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhoBox:)];
    [self.viewContainer2 addGestureRecognizer:tap2 ];
    UITapGestureRecognizer *tap3= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhenBox:)];
    [self.viewContainer3 addGestureRecognizer:tap3 ];
    UITapGestureRecognizer *tap4= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhereBox:)];
    [self.viewContainer4 addGestureRecognizer:tap4 ];
    
    addShadowTo (_viewContainer1);
    addShadowTo (_viewContainer2);
    addShadowTo (_viewContainer3);
    addShadowTo (_viewContainer4);
    _imageViewContainer1.clipsToBounds= YES;
    
    [self updateBoxes];
    
    EventObject* e= APP.eventBeingEdited;
    if  (e.primaryImage) {
        self.imageViewContainer1.image= e.primaryImage;
    }
    else if  (e.primaryVenueImageIdentifier ) {
        __weak EventCoordinatorVC *weakSelf = self;
        OOAPI *api = [[OOAPI alloc] init];
        /* _imageOperation=*/ [api getRestaurantImageWithImageRef: e.primaryVenueImageIdentifier
                                                         maxWidth:self.view.frame.size.width
                                                        maxHeight:0
                                                          success:^(NSString *link) {
                                                              UIImage* placeholder= [UIImage imageNamed:@"background-image.jpg"];
                                                              ON_MAIN_THREAD(  ^{
                                                                  [weakSelf.imageViewContainer1
                                                                   setImageWithURL:[NSURL URLWithString:link]
                                                                   placeholderImage:placeholder];
                                                              });
                                                          } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                                          }];
    }
}

- (void) userPressedMenuButton: (id) sender
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"Delete Event?")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes"
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     [self deleteEvent];
                                                 }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self presentViewController:a animated:YES completion:nil];
    
}

- (void)deleteEvent
{
    [OOAPI deleteEvent:APP.eventBeingEdited.eventID
               success:^{
                    [self dismissViewControllerAnimated:YES
                                              completion:^{
                                                  // XX:  need to force event list to reload
                                              }];
                    }
                    failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                        message( @"Failed to delete event.");
                    }];
                   
}

- (void)updateBoxes
{
    if  (!_timerForUpdating) {
        // RULE: Initially just display the basic information.
        self.timerForUpdating= [NSTimer scheduledTimerWithTimeInterval:30 target: self
                                                              selector: @selector (updateBoxes)
                                                              userInfo:nil repeats:YES];
    }
    [self updateWhenBox];
    [self initiateUpdateOfWhoBox];
    [self initiateUpdateOfWhereBox];
}

- (void)datesChanged
{
    [APP.eventBeingEdited sendDatesToServer];
}

- (void) updateWhenBox
{
//    NSAttributedString *title= attributedStringOf(LOCAL( @"WHEN"),  kGeomEventHeadingFontSize);
//    NSMutableAttributedString* a= [[NSMutableAttributedString alloc] initWithAttributedString: title];
    NSString *string=nil;
    
    EventObject* event= APP.eventBeingEdited;
    if  (event.date ) {
        string=[NSString stringWithFormat:  @"%@", expressLocalDateTime(event.date)];
    } else {
        string= [NSString stringWithFormat: @"%@",
                 LOCAL( @"TAP TO SELECT A DATE AND TIME")
                 ];
    }
    
    _labelTime.text= [expressLocalTime(event.date) lowercaseString ];
    _labelMonth.text= expressLocalMonth( event.date);
}

- (void) initiateUpdateOfWhoBox
{
    EventObject* e= APP.eventBeingEdited;
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

- (void)initiateUpdateOfWhereBox
{
    EventObject* e= APP.eventBeingEdited;
    [e refreshVenuesFromServerWithSuccess:^{
        [self performSelectorOnMainThread:@selector(updateWhereBoxAnimated:) withObject:@1 waitUntilDone:NO];
    } failure:^{
        NSLog (@"UNABLE TO REFRESH VENUES");
    }];
    
}

- (void)updateWhoBox
{
    EventObject* e= APP.eventBeingEdited;
    NSInteger pending= e.numberOfPeople - e.numberOfPeopleResponded;
    NSInteger responded= e.numberOfPeopleResponded;
    NSInteger  voted= e.numberOfPeopleVoted;
    
//    _labelPersonIcon.attributedText= createPeopleIconString(totalPeople);
    
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
    
    if  (e.users.count ) {
        if (_viewsForFaces ) {
            for (UIView* v  in  _viewsForFaces) {
                [v removeFromSuperview];
            }
            [self.viewsForFaces removeAllObjects];
        }
        NSInteger nBubbles=  ([UIScreen  mainScreen].bounds.size.width -2*kGeomSpaceEdge)/(kGeomFaceBubbleDiameter +kGeomFaceBubbleSpacing);
        self.viewsForFaces= makeImageViewsForUsers(_viewContainer2, e.users, nBubbles);
        [self doLayout];
    }
}

- (void) updateWhereBoxAnimated:(id)animated
{
//    EventObject *event=APP.eventBeingEdited;
    
    [self.venuesCollectionView reloadData ];
    if  (animated ) {
        __weak EventCoordinatorVC *weakSelf = self;
        [UIView animateWithDuration:.4
                         animations:^{
                             [weakSelf doLayout];
                         }
                         completion:^(BOOL finished) {
                         }];
    }else {
        [self doLayout];
    }
    
    [self.view bringSubviewToFront:self.headerWho];
    [self.view bringSubviewToFront:self.headerWhere];
    [self.view bringSubviewToFront:self.headerWhen];

    // RULE: Do not allow submitting before we have all the restaurant information.
    _buttonSubmit.enabled= YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateBoxes];
    
    // RULE: After basic info is displayed, fetch what's on the backend.
    __weak EventCoordinatorVC *weakSelf = self;
    [APP.eventBeingEdited refreshVenuesFromServerWithSuccess:^{
        NSInteger numberOfVenues= APP.eventBeingEdited.numberOfVenues;
        if (numberOfVenues != [APP.eventBeingEdited totalVenues ] ) {
            
            NSLog  (@"VENUES FOR EVENT DID CHANGE.  (total=  %ld)", ( unsigned long)[APP.eventBeingEdited totalVenues ]);
            ON_MAIN_THREAD(^(){
                [weakSelf updateWhereBoxAnimated: @""];
            });
        }
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
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userTappedWhereBox: (UITapGestureRecognizer*) sender
{
    if  (_transitioning ) {
        return;
    }
    _transitioning= YES;
    
    SearchVC* vc= [[SearchVC alloc] init];
    vc.addingRestaurantsToEvent= YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    doSubmit
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmit: (id) sender
{
    EventObject* event= APP.eventBeingEdited;

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
    
    event.isComplete= YES;
    [OOAPI reviseEvent: event
               success:^(id responseObject) {
                   NSLog (@"REVISION SUCCESSFUL");
               } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                   NSLog (@"REVISION FAILED %@",e);
               }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateWhoBox];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float vspacing= 25;

    _scrollView.frame=  self.view.bounds;
    float boxWidth=w-2*margin;
    
    float x=  margin, y=  margin;
    _viewContainer1.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeightTopmost);
    _imageViewContainer1.frame= CGRectMake(0, 0, boxWidth, kGeomEventCoordinatorBoxHeightTopmost);
    y += kGeomEventCoordinatorBoxHeightTopmost + vspacing;
    
    _viewContainer2.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    self.headerWho.frame= CGRectMake(x, y-13, boxWidth, 27);
    y += kGeomEventCoordinatorBoxHeight + vspacing;
    
    _viewContainer3.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    self.headerWhen.frame= CGRectMake(x, y-13, boxWidth, 27);
    y += kGeomEventCoordinatorBoxHeight + vspacing;
    
    _viewContainer4.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    self.headerWhere.frame= CGRectMake(x, y-13, boxWidth, 27);
    y += kGeomEventCoordinatorBoxHeight + vspacing;
    
    [self.view bringSubviewToFront:self.headerWho];
    [self.view bringSubviewToFront:self.headerWhere];
    [self.view bringSubviewToFront:self.headerWhen];

    _scrollView.contentSize= CGSizeMake(w-1, y);
    
    y=  0;
    _buttonSubmit.frame=  CGRectMake(0, _viewContainer1.frame.size.height-kGeomHeightButton,
                                     boxWidth,kGeomHeightButton);
    _labelEventCover.frame = CGRectMake(0,0,boxWidth,_buttonSubmit.frame.origin.y);
    
    float subBoxWidth= boxWidth/3;
    float subBoxHeight= 2*kGeomEventCoordinatorBoxHeight/3;
    x= 0;
    _labelWhoResponded.frame = CGRectMake(x,0,subBoxWidth,subBoxHeight);
    x+= subBoxWidth;
    _viewVerticalLine1.frame = CGRectMake(x,kGeomStripHeaderHeight/2,1,subBoxHeight-kGeomStripHeaderHeight);
    _labelWhoPending.frame = CGRectMake(x,0,subBoxWidth,subBoxHeight);
    x+= subBoxWidth;
    _viewVerticalLine2.frame = CGRectMake(x,kGeomStripHeaderHeight/2,1,subBoxHeight-kGeomStripHeaderHeight);
    _labelWhoVoted.frame = CGRectMake(x,0,subBoxWidth,subBoxHeight);

    _pieHour.frame = CGRectMake(2*boxWidth/3 + boxWidth/6 - kGeomEventCoordinatorPieDiameter/2,
                               kGeomStripHeaderHeight/2+ kGeomEventCoordinatorBoxHeight/4 - kGeomEventCoordinatorPieDiameter/2,
                                  kGeomEventCoordinatorPieDiameter, kGeomEventCoordinatorPieDiameter);

    _labelTime.frame = CGRectMake(2*boxWidth/3,  kGeomEventCoordinatorBoxHeight/2,
                                  boxWidth/3, kGeomEventCoordinatorBoxHeight/2);
    _labelMonth.frame = CGRectMake(0,0,boxWidth,kGeomEventCoordinatorBoxHeight);
    float dayCellWidth =  floorf((2*boxWidth/3-2*kGeomSpaceEdge)/7 );
    if  (dayCellWidth> 40 ) {
        dayCellWidth= 40;
    }
    float dayCellHeight=  floorf((kGeomEventCoordinatorBoxHeight-kGeomStripHeaderHeight/2-2*kGeomSpaceEdge)/3);
    float requiredWidth= dayCellWidth * 7;
    float x0=  (2*boxWidth/3 - requiredWidth)/2;
    x=x0;
    y= kGeomStripHeaderHeight/2;

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
    
    NSInteger dayNumber= getLocalDayNumber(APP.eventBeingEdited.date);
    const float bubbleDiameter=dayCellWidth-5;
    self.viewTodayBubble.frame = CGRectMake(0,0,bubbleDiameter,bubbleDiameter);
    [self.viewContainer3 sendSubviewToBack: self.viewTodayBubble ];
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

    [self.pieHour setHour: getLocalHour(APP.eventBeingEdited.date)];
    
    NSUInteger u= [APP.eventBeingEdited.date timeIntervalSince1970];
    if (dayNumber>0 ) {
        u-= 24*60*60*dayNumber;
    }
    for (int i=0; i < 7; i++) {
        NSDate *date= [NSDate dateWithTimeIntervalSince1970:u];
        NSInteger day= getLocalDayOfMonth( date);
        switch (i) {
            case 0:
                self.labelDate0.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate0.textColor= YELLOW;
                break;
            case 1:
                self.labelDate1.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate1.textColor= YELLOW;
                break;
            case 2:
                self.labelDate2.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate2.textColor= YELLOW;
                break;
            case 3:
                self.labelDate3.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate3.textColor= YELLOW;
                break;
            case 4:
                self.labelDate4.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate4.textColor= YELLOW;
                break;
            case 5:
                self.labelDate5.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate5.textColor= YELLOW;
                break;
            case 6:
                self.labelDate6.text= [NSString stringWithFormat: @"%ld",  (long) day ];
                if  (i==dayNumber ) self.labelDate6.textColor= YELLOW;
                break;
            default:
                break;
        }
        u += 24 *3600;
    }
    
    // RULE: If no restaurants have been added then did label should take up the entire height.
    float x2=_viewContainer4.frame.origin.x;
    float y2=_viewContainer4.frame.origin.y;
    _venuesCollectionView.frame = CGRectMake(x2,y2 ,boxWidth,kGeomEventCoordinatorBoxHeight);
    
    if ( self.viewsForFaces.count) {
        NSUInteger count=self.viewsForFaces.count;
        NSUInteger totalPeople=  [APP.eventBeingEdited totalUsers ];
        y=subBoxHeight+kGeomEventCoordinatorBoxHeight/6-kGeomFaceBubbleDiameter/2-kGeomStripHeaderHeight/2;
        x= (boxWidth-count*kGeomFaceBubbleDiameter-(count-1)*kGeomFaceBubbleSpacing)/2;
        NSInteger i= 0;
        for (UIImageView*iv  in self.viewsForFaces) {
            if  (i >= _viewsForFaces.count-1  && _viewsForFaces.count < totalPeople  ) {
                _labelEllipsis.frame=CGRectMake(x, y, kGeomFaceBubbleDiameter, kGeomFaceBubbleDiameter);
                iv.frame= CGRectZero;
            } else {
                iv.frame= CGRectMake(x, y, kGeomFaceBubbleDiameter, kGeomFaceBubbleDiameter);
                _labelEllipsis.frame=CGRectZero;
            }
            x+= kGeomFaceBubbleDiameter+kGeomFaceBubbleSpacing;
            i++;
        }
    }
}

#pragma mark - Collection View stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger total= [APP.eventBeingEdited totalVenues ];
    return total ;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kGeomEventCoordinatorRestaurantHeight, kGeomEventCoordinatorRestaurantHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TileCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:CV_CELL_REUSE_IDENTIFER
                                                                forIndexPath:indexPath];
    cvc.backgroundColor = GRAY;
    NSInteger  row= indexPath.row;
    RestaurantObject *venue= [APP.eventBeingEdited getNthVenue:row];
    cvc.restaurant = venue;
    CGRect r= cvc.frame;
    r.size=  CGSizeMake(kGeomEventCoordinatorRestaurantHeight, kGeomEventCoordinatorRestaurantHeight);
    cvc.frame= r;
    
    return cvc;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger  row= indexPath.row;
    RestaurantObject *venue= [APP.eventBeingEdited getNthVenue:row];
    RestaurantVC*vc= [[RestaurantVC alloc] init];
    vc.restaurant= venue;
    [self.navigationController pushViewController:vc animated:YES ];
}

@end
