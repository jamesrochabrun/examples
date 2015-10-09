//
//  EventParticipantVC.m
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
#import "EventParticipantVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "ListTVCell.h"
#import "EventWhenVC.h"

@interface EventParticipantVC ()
@property (nonatomic,strong)  UIButton* buttonSubmitVote;
@property (nonatomic,strong)  UIScrollView* scrollView;

@property (nonatomic,strong) ListTVCell *venuesRowView;
@end

@implementation EventParticipantVC
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: _eventName ?:  @"MISSING EVENT NAME" subHeader:  nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _scrollView= makeScrollView(self.view, self);
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem  alloc] initWithTitle: @"CANCEL"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action: @selector(userPressedCancel:)];
    _buttonSubmitVote= makeButton(self.view,  @"SUBMIT VOTE", kGeomEventHeadingFontSize,
                                  BLACK, CLEAR, self, @selector(doSubmitVote:), 1);
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

//------------------------------------------------------------------------------
// Name:    doSubmitVote
// Purpose:
//------------------------------------------------------------------------------
- (void)doSubmitVote: (id) sender
{
    message( @"you pressed submit.");
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float spacing= kGeomSpaceEdge;
    
    _scrollView.frame=  self.view.bounds;
#define kGeomEventParticipantBoxHeight 175
#define kGeomEventParticipantRestaurantHeight 100
    
    _buttonSubmitVote.frame=  CGRectMake((w-kGeomButtonWidth)/2,kGeomEventParticipantBoxHeight-kGeomHeightButton-margin,kGeomButtonWidth,kGeomHeightButton);

}

@end
