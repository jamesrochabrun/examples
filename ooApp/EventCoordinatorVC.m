//
//  EventCoordinatorVC.m
//  ooApp
//
//  Created by Zack S on 7/16/15.
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
#import "ListStripTVCell.h"
#import "EventWhenVC.h"
#import "EventWhoVC.h"
#import "SearchVC.h"

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

@property (nonatomic,strong) ListStripTVCell *venuesRowView;
@end

@implementation EventCoordinatorVC
{
}

- (void)dealloc
{
    [_viewContainer1 removeGestureRecognizer:_tap1];
    [_viewContainer2 removeGestureRecognizer:_tap2];
    [_viewContainer3 removeGestureRecognizer:_tap3];
    [_viewContainer4 removeGestureRecognizer:_tap4];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* eventName= APP.eventBeingEdited.name;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: eventName ?:  @"MISSING EVENT NAME" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _scrollView= makeScrollView(self.view, self);
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem  alloc] initWithTitle: @"CANCEL"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action: @selector(userPressedCancel:)];
    
    self.viewContainer1= makeView(self.scrollView, WHITE);
    self.labelEventCover= makeLabel(self.viewContainer1, @"EVENT COVER", kGeomEventHeadingFontSize);
    _viewContainer1.layer.borderWidth= 1;
    _viewContainer1.layer.borderColor= GRAY.CGColor;
    
    _buttonSubmit= makeButton(self.viewContainer1,  @"SUBMIT EVENT", kGeomFontSizeHeader, RED, CLEAR, self, @selector(doSubmit:), 1);
    _buttonSubmit.titleLabel.numberOfLines= 0;
    _buttonSubmit.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    self.viewContainer2= makeView(self.scrollView, WHITE);
    self.labelWho = makeLabel(self.viewContainer2, @"WHO", kGeomFontSizeHeader);
    self.labelPersonIcon= [UILabel new];
    [ self.viewContainer2  addSubview: _labelPersonIcon];
    _labelPersonIcon.attributedText= createPeopleIconString (1);
    _labelPersonIcon.textAlignment= NSTextAlignmentRight;
    _viewContainer2.layer.borderWidth= 1;
    _viewContainer2.layer.borderColor= GRAY.CGColor;
    
    self.viewContainer3= makeView(self.scrollView, WHITE);
    self.labelWhen = makeLabel(self.viewContainer3, @"WHEN\rDATE\rTIME", kGeomFontSizeHeader);
    _viewContainer3.layer.borderWidth= 1;
    _viewContainer3.layer.borderColor= GRAY.CGColor;
    
    self.viewContainer4= makeView(self.scrollView, WHITE);
    self.labelWhere = makeLabel(self.viewContainer4, @"WHERE", kGeomEventHeadingFontSize);
    _viewContainer4.layer.borderWidth= 1;
    _viewContainer4.layer.borderColor= GRAY.CGColor;
    
    UITapGestureRecognizer *tap1= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedBox1:)];
    [self.viewContainer1 addGestureRecognizer:tap1 ];
    UITapGestureRecognizer *tap2= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhoBox:)];
    [self.viewContainer2 addGestureRecognizer:tap2 ];
    UITapGestureRecognizer *tap3= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhenBox:)];
    [self.viewContainer3 addGestureRecognizer:tap3 ];
    UITapGestureRecognizer *tap4= [[UITapGestureRecognizer  alloc] initWithTarget: self action: @selector(userTappedWhereBox:)];
    [self.viewContainer4 addGestureRecognizer:tap4 ];
    
    self.venuesRowView= [[ListStripTVCell alloc] initWithFrame: CGRectZero];
    [ self.viewContainer4  addSubview: _venuesRowView   ];
    ListObject *list=[[ListObject  alloc] init];
    list.name=  @"Where";
    list.listDisplayType = KListDisplayTypeStrip;
    _venuesRowView.listItem=list ;
    
}

- (void) userPressedCancel: (id) sender
{
    APP.eventBeingEdited= nil;
    
    [self.navigationController popViewControllerAnimated:YES ];
}

- (void)userTappedBox1:(id) sender
{
    
}

- (void) updateWhenBox
{
    NSAttributedString *title= attributedStringOf(LOCAL( @"WHEN"),  kGeomEventHeadingFontSize);
    NSMutableAttributedString* a= [[NSMutableAttributedString alloc] initWithAttributedString: title];
    NSString *string=nil;
    
    EventObject* event= APP.eventBeingEdited;
    if  (event.date ) {
        string=[NSString stringWithFormat:  @"\r%@", event.date];
    } else {
        string= [NSString stringWithFormat: @"\r%@",
                 LOCAL( @"TAP TO SELECT A DATE AND TIME")
                 ];
    }
    
    [a appendAttributedString: attributedStringOf(string,  kGeomFontSizeHeader)];
    _labelWhen.attributedText= a;
}

- (void) updateWhoBox
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

- (void) updateWhereBox
{
    [_venuesRowView getRestaurants];
    
    // RULE: Check whether the backend has new information every 30 seconds.
    [self  performSelector: @selector(updateWhereBox) withObject:nil afterDelay:30];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateWhenBox];
    [self updateWhoBox];
    [self updateWhereBox];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(updateWhereBox) object:nil];
    [super viewDidDisappear:animated];
}

- (void)userTappedWhoBox: (id) sender
{
    EventWhoVC* vc= [[EventWhoVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)userTappedWhenBox: (id) sender
{
    EventWhenVC* vc= [[EventWhenVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userTappedWhereBox: (id) sender
{
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
#define kGeomEventCoordinatorBoxHeight 175
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

    float labelHeight=kGeomEventCoordinatorBoxHeight - kGeomEventCoordinatorRestaurantHeight;
    _labelWhere.frame = CGRectMake(0,0,boxWidth, labelHeight);
    _venuesRowView.frame = CGRectMake(0,labelHeight,boxWidth,kGeomEventCoordinatorRestaurantHeight);
    
}

@end
