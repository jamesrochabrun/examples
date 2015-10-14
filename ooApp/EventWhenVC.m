//
//  EventWhenVC.m
//  ooApp
//
//  Created by Zack Smith on 10/7/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "EventWhenVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"

@interface EventWhenVC ()
@property (nonatomic,strong)  UILabel* labelEventDateHeader;
@property (nonatomic,strong)   UILabel* labelEventVotingHeader;
@property (nonatomic,strong)   UIButton* buttonEventDate;
@property (nonatomic,strong)   UIButton* buttonEventVoting;
@property (nonatomic,strong)  UIDatePicker* pickerEventDate;
@property (nonatomic,strong)   UIDatePicker* pickerEventVotingDate;
@end

@implementation EventWhenVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"WHEN IS THE EVENT" subHeader: nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= WHITE;
                                
    self.labelEventDateHeader= makeLabel( self.view,  @"WHEN IS THIS?", kGeomFontSizeHeader);
    self.labelEventVotingHeader= makeLabel( self.view,  @"WHEN IS VOTING CLOSED?", kGeomFontSizeHeader);
    self.buttonEventDate=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedUpperButton:), 0);
    self.buttonEventVoting=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedLowerButton:), 0);
    
    self.pickerEventDate= [[UIDatePicker  alloc] init];
    self.pickerEventVotingDate= [[UIDatePicker  alloc] init];
    [self.view addSubview: _pickerEventDate ];
    [self.view addSubview: _pickerEventVotingDate];
    
    _pickerEventDate.datePickerMode= UIDatePickerModeDateAndTime;
    _pickerEventVotingDate.datePickerMode= UIDatePickerModeDateAndTime;
    
    _pickerEventDate.hidden= YES;
    _pickerEventVotingDate.hidden= YES;
    
    self.navigationItem.leftBarButtonItem= nil;
    
    if (APP.eventBeingEdited.date ) {
        [_buttonEventDate setTitle:[NSString stringWithFormat: @"%@", APP.eventBeingEdited.date ]
                                                      forState:UIControlStateNormal];
    }
    if ( APP.eventBeingEdited.dateWhenVotingClosed) {
        [_buttonEventVoting setTitle:[NSString stringWithFormat: @"%@",APP.eventBeingEdited.dateWhenVotingClosed]
                            forState:UIControlStateNormal];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self extractDateTimeFromUpperPicker];
    [self extractDateTimeFromLowerPicker];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)extractDateTimeFromUpperPicker
{
    NSDate *date= _pickerEventDate.date;
    APP.eventBeingEdited.date= date;
    [_buttonEventDate setTitle:[NSString stringWithFormat: @"%@",date]
                      forState:UIControlStateNormal];
}

- (void)extractDateTimeFromLowerPicker
{
    NSDate *date= _pickerEventVotingDate.date;
    APP.eventBeingEdited.dateWhenVotingClosed= date;
    [_buttonEventVoting setTitle:[NSString stringWithFormat: @"%@",date]
                      forState:UIControlStateNormal];
}

- (void)userPressedUpperButton: (id) sender
{
    _pickerEventDate.hidden= !_pickerEventDate.hidden;
    if (!_pickerEventVotingDate.hidden) {
        [self extractDateTimeFromLowerPicker];
    }
    if (! _pickerEventDate.hidden) {
        _pickerEventVotingDate.hidden= YES;
    }else {
        [self extractDateTimeFromUpperPicker];
    }
    __weak EventWhenVC *weakSelf = self;
    [UIView animateWithDuration: 0.4 animations:^{
        [weakSelf doLayout];
    }];
}

- (void)userPressedLowerButton: (id) sender
{
    _pickerEventVotingDate.hidden= !_pickerEventVotingDate.hidden;
    if (!_pickerEventDate.hidden) {
        [self extractDateTimeFromUpperPicker];
    }
    if (! _pickerEventVotingDate.hidden) {
        _pickerEventDate.hidden= YES;
    }else {
        [self extractDateTimeFromLowerPicker];
    }
    __weak EventWhenVC *weakSelf = self;
    [UIView animateWithDuration: 0.4 animations:^{
        [weakSelf doLayout];
    }];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    const float kGeomSpaceInterMiddle =  15;
    float  margin= kGeomSpaceEdge;
    float  spacing=  kGeomSpaceInter;

    float y=  margin;
    float pickerHeight= _pickerEventDate.intrinsicContentSize.height;

    float requiredHeight= 2*kGeomHeightButton + 3* spacing  +kGeomSpaceInterMiddle;
    if  (_pickerEventDate.hidden ) {
        requiredHeight+=kGeomHeightButton;
    } else {
        requiredHeight+=pickerHeight;
    }
    if  (_pickerEventVotingDate.hidden ) {
        requiredHeight+=kGeomHeightButton;
    } else {
        requiredHeight+=pickerHeight;
    }
    
    // RULE: The contents are not centered vertically but are rather at the one quarter mark.
    y= (h-requiredHeight)/4;
    
    _labelEventDateHeader.frame = CGRectMake(0,y, w, kGeomHeightButton);
    y +=kGeomHeightButton +  spacing;
    
    if  (_pickerEventDate.hidden ) {
        _buttonEventDate.hidden= NO;
        _buttonEventDate.frame = CGRectMake(0,y, w, kGeomHeightButton);
        _pickerEventDate.frame = CGRectMake(0,y,w, 0);
        y +=kGeomHeightButton +  spacing;
    } else {
        _buttonEventDate.frame = CGRectMake(0,y, w, 0);
        _buttonEventDate.hidden= YES;
        _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
        y += pickerHeight+ spacing;
    }
    
    y += kGeomSpaceInterMiddle;
    
    _labelEventVotingHeader.frame = CGRectMake(0,y, w, kGeomHeightButton);
    y +=kGeomHeightButton +  spacing;
    
    if  (_pickerEventVotingDate.hidden ) {
        _buttonEventVoting.hidden= NO;
       _buttonEventVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
        _pickerEventVotingDate.frame = CGRectMake(0,y,w, 0);
        y +=kGeomHeightButton +  spacing;
    } else {
        _buttonEventVoting.frame = CGRectMake(0,y, w, 0);
        _buttonEventVoting.hidden= YES;
        float pickerHeight= _pickerEventVotingDate.intrinsicContentSize.height;
        _pickerEventVotingDate.frame = CGRectMake(0,y,w, pickerHeight);
        y += pickerHeight+ spacing;
    }
    
}

@end
