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
#import "RestaurantMainCVCell.h"
#import "EventWhenVC.h"
#import "EventWhoVC.h"
#import "SearchVC.h"
#import "RestaurantVC.h"

@interface EventCoordinatorVC ()
@property (nonatomic,strong)  UIButton* buttonSubmit;
@property (nonatomic,strong)  UIScrollView* scrollView;

@property (nonatomic,strong)  UIView *viewContainer1;
@property (nonatomic,strong)  UILabel *labelEventCover;

@property (nonatomic,strong)  UIView *viewContainer2;
@property (nonatomic,strong)  UILabel *labelWho;
@property (nonatomic,strong)  UILabel *labelPersonIcon;

@property (nonatomic,strong)  UIView *viewContainer3;
@property (nonatomic,strong)  UILabel *labelWhen;

@property (nonatomic,strong)  UIView *viewContainer4;
@property (nonatomic,strong)  UILabel *labelWhere;

@property (nonatomic,strong) UITapGestureRecognizer *tap1;
@property (nonatomic,strong) UITapGestureRecognizer *tap2;
@property (nonatomic,strong) UITapGestureRecognizer *tap3;
@property (nonatomic,strong) UITapGestureRecognizer *tap4;

@property (nonatomic,strong) UICollectionView *venuesCollectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *cvLayout;

@property (nonatomic,strong) NSTimer *timerForUpdating;
@property (nonatomic,assign) BOOL transitioning;
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
    [super viewDidLoad];
    
    NSString* eventName= APP.eventBeingEdited.name;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"UNNAMED" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _scrollView= makeScrollView(self.view, self);
    [_scrollView setCanCancelContentTouches:YES];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem  alloc] initWithTitle: @"CANCEL"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action: @selector(userPressedCancel:)];

    self.viewContainer1= makeView(self.scrollView, WHITE);
   self.labelEventCover= makeAttributedLabel(self.viewContainer1, @"EVENT COVER", kGeomEventHeadingFontSize);
    _viewContainer1.layer.borderWidth= 1;
    _viewContainer1.layer.borderColor= GRAY.CGColor;
    
    _buttonSubmit= makeButton(self.viewContainer1,  @"SUBMIT EVENT", kGeomFontSizeHeader, RED, CLEAR, self, @selector(doSubmit:), 1);
    _buttonSubmit.titleLabel.numberOfLines= 0;
    _buttonSubmit.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    self.viewContainer2= makeView(self.scrollView, WHITE);
    self.labelWho = makeAttributedLabel(self.viewContainer2, @"WHO", kGeomFontSizeHeader);
    self.labelPersonIcon= [UILabel new];
    [ self.viewContainer2  addSubview: _labelPersonIcon];
    _labelPersonIcon.attributedText= createPeopleIconString (1);
    _labelPersonIcon.textAlignment= NSTextAlignmentRight;
    _viewContainer2.layer.borderWidth= 1;
    _viewContainer2.layer.borderColor= GRAY.CGColor;
    
    self.viewContainer3= makeView(self.scrollView, WHITE);
    self.labelWhen = makeAttributedLabel(self.viewContainer3, @"WHEN\rDATE\rTIME", kGeomFontSizeHeader);
    _viewContainer3.layer.borderWidth= 1;
    _viewContainer3.layer.borderColor= GRAY.CGColor;
    
    self.viewContainer4= makeView(self.scrollView, WHITE);
    self.labelWhere = makeAttributedLabel(self.viewContainer4, @"WHERE", kGeomEventHeadingFontSize);
    _viewContainer4.layer.borderWidth= 1;
    _viewContainer4.layer.borderColor= GRAY.CGColor;
    _viewContainer4.tag=4;
    
    UITapGestureRecognizer *tap1= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedBox1:)];
    [self.viewContainer1 addGestureRecognizer:tap1 ];
    UITapGestureRecognizer *tap2= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhoBox:)];
    [self.viewContainer2 addGestureRecognizer:tap2 ];
    UITapGestureRecognizer *tap3= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhenBox:)];
    [self.viewContainer3 addGestureRecognizer:tap3 ];
    UITapGestureRecognizer *tap4= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhereBox:)];
    [self.viewContainer4 addGestureRecognizer:tap4 ];
    
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
    [_venuesCollectionView registerClass:[RestaurantMainCVCell class] forCellWithReuseIdentifier: CV_CELL_REUSE_IDENTIFER];
    
    [self updateBoxes];
}

- (void) userPressedCancel: (id) sender
{
    APP.eventBeingEdited= nil;
    
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)userTappedBox1:(id) sender
{
    
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
    [self updateWhereBoxAnimated:NO];
}

- (void)datesChanged
{
    [APP.eventBeingEdited sendDatesToServer];
}

- (void) updateWhenBox
{
    NSAttributedString *title= attributedStringOf(LOCAL( @"WHEN"),  kGeomEventHeadingFontSize);
    NSMutableAttributedString* a= [[NSMutableAttributedString alloc] initWithAttributedString: title];
    NSString *string=nil;
    
    EventObject* event= APP.eventBeingEdited;
    if  (event.date ) {
        string=[NSString stringWithFormat:  @"\r%@", expressLocalDateTime(event.date)];
    } else {
        string= [NSString stringWithFormat: @"\r%@",
                 LOCAL( @"TAP TO SELECT A DATE AND TIME")
                 ];
    }
    
    [a appendAttributedString: attributedStringOf(string,  kGeomFontSizeHeader)];
    _labelWhen.attributedText= a;
}

- (void) initiateUpdateOfWhoBox
{
    EventObject* e= APP.eventBeingEdited;
    [e refreshParticipantStatsFromServerWithSuccess:^{
        [self updateWhoBox];
    }
                                            failure:^{
                                                NSAttributedString *title= attributedStringOf(LOCAL( @"WHO"),  kGeomEventHeadingFontSize);
                                                _labelWho.attributedText= title;
                                            }];
}

- (void)updateWhoBox
{
    EventObject* e= APP.eventBeingEdited;
    NSInteger totalPeople= e.numberOfPeople;
    NSInteger pending= e.numberOfPeople - e.numberOfPeopleResponded;
    NSInteger responded= e.numberOfPeopleResponded;
    NSInteger  voted= e.numberOfPeopleVoted;
    
    _labelPersonIcon.attributedText= createPeopleIconString(totalPeople);
    
    NSAttributedString *title= attributedStringOf(LOCAL( @"WHO"),  kGeomEventHeadingFontSize);
    NSMutableAttributedString* a= [[NSMutableAttributedString alloc] initWithAttributedString: title];
    NSString *countsString= [NSString stringWithFormat: @"\r%lu %@\r%lu %@\r%lu %@",
                             responded,  LOCAL( @"RESPONDED"),
                             pending,  LOCAL( @"PENDING"),
                             voted,  LOCAL( @"VOTED")
                             ];
    [a appendAttributedString: attributedStringOf(countsString,  kGeomFontSizeHeader)];
    _labelWho.attributedText= a;
}

- (void) updateWhereBoxAnimated:(BOOL)animated
{
    if  ([APP.eventBeingEdited totalVenues ] ) {
        NSAttributedString *title= attributedStringOf(LOCAL( @"WHERE"),  kGeomEventHeadingFontSize);
        _labelWhere.attributedText= title;
    } else {
        NSAttributedString *title= attributedStringOf(LOCAL( @"WHERE"),  kGeomEventHeadingFontSize);
        NSMutableAttributedString* a= [[NSMutableAttributedString alloc] initWithAttributedString: title];
        NSString *string= [NSString stringWithFormat: @"\r%@",
                     LOCAL( @"TAP TO ADD RESTAURANTS")
                     ];
        [a appendAttributedString: attributedStringOf(string,  kGeomFontSizeHeader)];

        _labelWhere.attributedText= a;
    }
    
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
                [weakSelf updateWhereBoxAnimated:YES];
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
    
    UIView *v=sender.view;
    
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
    event.isComplete= YES;
    [OOAPI reviseEvent: event
               success:^(id responseObject) {
                   NSLog (@"REVISION SUCCESSFUL");
               } failure:^(NSError *e) {
                   NSLog (@"REVISION FAILED %@",e);
               }];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float spacing= kGeomSpaceEdge;
    
    _scrollView.frame=  self.view.bounds;
#define kGeomEventCoordinatorRestaurantHeight 100
    
    float boxWidth=w-2*margin;
    
    float x=  margin, y=  margin;
    _viewContainer1.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    y += kGeomEventCoordinatorBoxHeight + spacing;
    _viewContainer2.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    y += kGeomEventCoordinatorBoxHeight + spacing;
    _viewContainer3.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    y += kGeomEventCoordinatorBoxHeight + spacing;
    _viewContainer4.frame= CGRectMake(x, y, boxWidth, kGeomEventCoordinatorBoxHeight);
    y += kGeomEventCoordinatorBoxHeight + spacing;
    
    _scrollView.contentSize= CGSizeMake(w-1, y);
    
    y=  0;
    _buttonSubmit.frame=  CGRectMake((boxWidth-kGeomButtonWidth)/2,kGeomEventCoordinatorBoxHeight-kGeomHeightButton-margin,kGeomButtonWidth,kGeomHeightButton);
    _labelEventCover.frame = CGRectMake(0,0,boxWidth,_buttonSubmit.frame.origin.y);
    
    _labelWho.frame = CGRectMake(0,0,boxWidth,kGeomEventCoordinatorBoxHeight);
    _labelPersonIcon.frame = CGRectMake(boxWidth-kGeomButtonWidth, kGeomEventCoordinatorBoxHeight-kGeomHeightButton-margin,kGeomButtonWidth,kGeomHeightButton);
    
    _labelWhen.frame = CGRectMake(0,0,boxWidth,kGeomEventCoordinatorBoxHeight);

    // RULE: If no restaurants have been added then did label should take up the entire height.
    float x2=_viewContainer4.frame.origin.x;
    float y2=_viewContainer4.frame.origin.y;
    if  ([APP.eventBeingEdited totalVenues ] ) {
        float labelHeight=kGeomEventCoordinatorBoxHeight - kGeomEventCoordinatorRestaurantHeight;
        _venuesCollectionView.hidden= NO;
        _labelWhere.frame = CGRectMake(0,0,boxWidth, labelHeight);
        _venuesCollectionView.frame = CGRectMake(x2,y2 +labelHeight,boxWidth,kGeomEventCoordinatorRestaurantHeight);
    } else {
        _venuesCollectionView.hidden= YES;
        _labelWhere.frame = CGRectMake(0,0,boxWidth, kGeomEventCoordinatorBoxHeight);
        _venuesCollectionView.frame = CGRectMake(x2,y2+kGeomEventCoordinatorRestaurantHeight-1,boxWidth,0);
    }
}
#pragma mark - Collection View stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [APP.eventBeingEdited totalVenues ];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kGeomEventCoordinatorRestaurantHeight, kGeomEventCoordinatorRestaurantHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantMainCVCell *cvc = [collectionView dequeueReusableCellWithReuseIdentifier:CV_CELL_REUSE_IDENTIFER
                                                                          forIndexPath:indexPath];
    cvc.backgroundColor = GRAY;
    NSInteger  row= indexPath.row;
    RestaurantObject *venue= [APP.eventBeingEdited getNthVenue:row];
    cvc.restaurant = venue;
    cvc.mediaItemObject= venue.mediaItems.count ?  venue.mediaItems[0] :nil;
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
