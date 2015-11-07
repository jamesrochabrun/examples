//
//  EventWhenVC.m E7
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
#import "OOStripHeader.h"

@interface EventWhenVC ()
@property (nonatomic,strong)  UILabel* labelEventDateHeader;
@property (nonatomic,strong)   UILabel* labelEventVotingHeader;
@property (nonatomic,strong)   UIButton* buttonEventDate;
@property (nonatomic,strong)   UIButton* buttonEventVoting;
@property (nonatomic,strong) UIButton* buttonDuration1;
@property (nonatomic,strong)  UIDatePicker* pickerEventDate;
@property (nonatomic,strong)   UIDatePicker* pickerEventVotingDate;
@property (nonatomic,assign) BOOL upperDateWasModified;
@property (nonatomic,assign) BOOL lowerDateWasModified;
@property (nonatomic,strong) OOStripHeader *headerWhen;
@property (nonatomic,strong) OOStripHeader *headerEndOfVoting;
@end

@implementation EventWhenVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
   [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"WHEN IS THE EVENT" subHeader: nil];
    self.navTitle = nto;
    
    self.view.backgroundColor= UIColorRGB(0xfff0f0f0);
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    self.buttonEventDate=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedUpperButton:), 0);
    self.buttonEventVoting=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  BLACK, CLEAR,
                                    self, @selector(userPressedLowerButton:), 0);
    
//    self.buttonDuration1= makeButton(self.view,  @"1 HOUR FOR VOTING",
//                                     kGeomFontSizeHeader,
//                                     BLACK, CLEAR, self, @selector(userPressDurationButton1:) , 1);
    
    self.pickerEventDate= [[UIDatePicker  alloc] init];
    self.pickerEventVotingDate= [[UIDatePicker  alloc] init];
    [self.view addSubview: _pickerEventDate ];
    [self.view addSubview: _pickerEventVotingDate];
    _pickerEventDate.backgroundColor= WHITE;
    _pickerEventVotingDate.backgroundColor= WHITE;
    
    addShadowTo(_pickerEventDate);
    addShadowTo(_pickerEventVotingDate);
    
    _pickerEventDate.timeZone= [NSTimeZone systemTimeZone];
    _pickerEventVotingDate.timeZone= [NSTimeZone systemTimeZone];
    
    _pickerEventDate.datePickerMode= UIDatePickerModeDateAndTime;
    _pickerEventVotingDate.datePickerMode= UIDatePickerModeDateAndTime;
    
    if ( self.eventBeingEdited.date) {
        _pickerEventDate.date= self.eventBeingEdited.date;

    }
    if (self.eventBeingEdited.dateWhenVotingClosed ) {
        _pickerEventDate.date= self.eventBeingEdited.dateWhenVotingClosed;
    }
    
    _pickerEventDate.hidden= YES;
    _pickerEventVotingDate.hidden= YES;
    
    self.navigationItem.leftBarButtonItem= nil;
    
    if (self.eventBeingEdited.date ) {
        [self expressUpperDate];
    }
    if ( self.eventBeingEdited.dateWhenVotingClosed) {
        [self expressLowerDate];
    }

    self.headerWhen= [[OOStripHeader alloc] init];
    self.headerEndOfVoting= [[OOStripHeader alloc] init];
    [self.view addSubview: _headerWhen ];
    [self.view addSubview: _headerEndOfVoting];
    [_headerWhen setName: @"WHEN IS THIS?" ];
    [_headerEndOfVoting setName: @"WHEN IS VOTING CLOSED?" ];

}

- (void)userPressDurationButton1: (id) sender
{
    
    
}
- (void)expressUpperDate
{
    NSDate* gmtTime= self.eventBeingEdited.date;

    [_buttonEventDate setTitle: expressLocalDateTime(gmtTime)
                      forState:UIControlStateNormal];
}

- (void)expressLowerDate
{
    NSDate* gmtTime= self.eventBeingEdited.dateWhenVotingClosed;
    
    [_buttonEventVoting setTitle:expressLocalDateTime (gmtTime)
                        forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if  (_lowerDateWasModified ) {
        [self extractDateTimeFromLowerPicker];
    }
    if ( _upperDateWasModified) {
        [self extractDateTimeFromUpperPicker];
    }
    
    if ( self.delegate  && (_upperDateWasModified || _lowerDateWasModified)) {
        [self.delegate datesChanged];
    }
    
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
    NSDate *gmtTime= _pickerEventDate.date;
    self.eventBeingEdited.date= gmtTime;
    self.eventBeingEdited.hasBeenAltered= YES;// XX:  need to write set date method
    [self expressUpperDate];
}

- (void)extractDateTimeFromLowerPicker
{
    NSDate *gmtTime= _pickerEventVotingDate.date;
    self.eventBeingEdited.dateWhenVotingClosed= gmtTime;
    self.eventBeingEdited.hasBeenAltered= YES;// XX:  need to write set date when voting method
    [self expressLowerDate];
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
    
    _upperDateWasModified= YES;
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
    
    _lowerDateWasModified= YES;
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

    BOOL bothPickersOpen= IS_IPAD;
    if  (bothPickersOpen ) {
        _buttonEventDate.hidden= YES;
        _buttonEventVoting.hidden= YES;
        _pickerEventDate.hidden = NO;
        _pickerEventVotingDate.hidden= NO;
    }
//    float requiredHeight= 2*kGeomHeightButton + 3* spacing  +kGeomSpaceInterMiddle;
//    if  (_pickerEventDate.hidden ) {
//        requiredHeight+=kGeomHeightButton;
//    } else {
//        requiredHeight+=pickerHeight;
//    }
//    if  (_pickerEventVotingDate.hidden ) {
//        requiredHeight+=kGeomHeightButton;
//    } else {
//        requiredHeight+=pickerHeight;
//    }
    
//    // RULE: The contents are not centered vertically but are rather at the one quarter mark.
//    y= (h-requiredHeight)/4;
    
    if  (!bothPickersOpen ) {
        
        _headerWhen.frame = CGRectMake(0,y, w, kGeomHeightButton);
        
        if  (_pickerEventDate.hidden  ) {
            y +=kGeomHeightButton +  spacing;
            _buttonEventDate.hidden= NO;
            _buttonEventDate.frame = CGRectMake(0,y, w, kGeomHeightButton);
            _pickerEventDate.frame = CGRectMake(0,y,w, 0);
            y +=kGeomHeightButton +  spacing;
        } else {
            y +=kGeomHeightButton/2;
            _buttonEventDate.frame = CGRectMake(0,y, w, 0);
            _buttonEventDate.hidden= YES;
            _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
            y += pickerHeight+ spacing;
        }
        
        y += kGeomSpaceInterMiddle;
        
        _headerEndOfVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
        
        if  (_pickerEventVotingDate.hidden) {
            y +=kGeomHeightButton +  spacing;
            _buttonEventVoting.hidden= NO;
            _buttonEventVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
            _pickerEventVotingDate.frame = CGRectMake(0,y,w, 0);
            y +=kGeomHeightButton +  spacing;
        } else {
            y +=kGeomHeightButton/2;
            _buttonEventVoting.frame = CGRectMake(0,y, w, 0);
            _buttonEventVoting.hidden= YES;
            float pickerHeight= _pickerEventVotingDate.intrinsicContentSize.height;
            _pickerEventVotingDate.frame = CGRectMake(0,y,w, pickerHeight);
            y += pickerHeight+ spacing;
        }
    } else {
        
        _headerWhen.frame = CGRectMake(0,y, w, kGeomHeightButton);
        
        y +=kGeomHeightButton/2;
        _buttonEventDate.frame = CGRectMake(0,y, w, 0);
        _buttonEventDate.hidden= YES;
        _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
        y += pickerHeight+ spacing;
        
        y += kGeomSpaceInterMiddle;
        
        _headerEndOfVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
        
        y +=kGeomHeightButton/2;
        _buttonEventVoting.frame = CGRectMake(0,y, w, 0);
        _buttonEventVoting.hidden= YES;
        float pickerHeight= _pickerEventVotingDate.intrinsicContentSize.height;
        _pickerEventVotingDate.frame = CGRectMake(0,y,w, pickerHeight);
        y += pickerHeight+ spacing;
    }
    
    _buttonDuration1.frame = CGRectMake(margin,h-kGeomHeightButton- margin,w-2*margin, kGeomHeightButton);
}

@end
