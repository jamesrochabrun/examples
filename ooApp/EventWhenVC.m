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
@property (nonatomic,strong) UILabel *headerWhen;
@property (nonatomic,strong) UILabel *headerEndOfVoting;
@property (nonatomic,strong) UIView*viewOver1;
@property (nonatomic,strong) UIView*viewOver2;
@end

@implementation EventWhenVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

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
    
    self.view.backgroundColor= BLACK;
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    self.buttonEventDate=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  WHITE, CLEAR,
                                    self, @selector(userPressedUpperButton:), 0);
    self.buttonEventVoting=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  WHITE, CLEAR,
                                    self, @selector(userPressedLowerButton:), 0);
    
    self.pickerEventDate= [[UIDatePicker  alloc] init];
    self.pickerEventVotingDate= [[UIDatePicker  alloc] init];
    [self.view addSubview: _pickerEventDate ];
    [self.view addSubview: _pickerEventVotingDate];
    _pickerEventDate.backgroundColor= WHITE;
    _pickerEventVotingDate.backgroundColor= WHITE;
    _pickerEventDate.tintColor= GREEN;
    _pickerEventVotingDate.tintColor= WHITE;
    _pickerEventDate.tintAdjustmentMode= UIViewTintAdjustmentModeDimmed;
    
    self.viewOver1 = [[UIView alloc] init];
    _viewOver1.backgroundColor = YELLOW;
    _viewOver1.alpha = 0.5f;
    [_pickerEventDate addSubview: _viewOver1];
    
    self.viewOver2 = [[UIView alloc] init];
    _viewOver2.backgroundColor = YELLOW;
    _viewOver2.alpha = 0.5f;
    [_pickerEventVotingDate addSubview: _viewOver2];

    addShadowTo(_pickerEventDate);
    addShadowTo(_pickerEventVotingDate);
    
    _pickerEventDate.timeZone= [NSTimeZone systemTimeZone];
    _pickerEventVotingDate.timeZone= [NSTimeZone systemTimeZone];
    _pickerEventDate.minuteInterval=15;
    _pickerEventVotingDate.minuteInterval=15;
    
    _pickerEventDate.datePickerMode= UIDatePickerModeDateAndTime;
    _pickerEventVotingDate.datePickerMode= UIDatePickerModeDateAndTime;
    
    _pickerEventDate.hidden= YES;
    _pickerEventVotingDate.hidden= YES;
    
    self.navigationItem.leftBarButtonItem= nil;
    
    if (self.eventBeingEdited.date ) {
        [self expressUpperDate];
    } else {
        // RULE: Set up default date to be 3 hours in future.
        NSDate *d = [NSDate date];
        long long when= [d timeIntervalSince1970];
        when += 3*60*60+59; // As per Jay, 6:15 becomes 10:00.
        when /= 60*60;
        when *= 60*60;
        d = [NSDate dateWithTimeIntervalSince1970:when];
        self.eventBeingEdited.date = d;
        [self expressUpperDate];
    }

    if ( self.eventBeingEdited.dateWhenVotingClosed) {
        [self expressLowerDate];
    } else {
        // RULE: Set up default date to be 2 hours in future.
        NSDate *d = [NSDate date];
        long long when= [d timeIntervalSince1970];
        when += 2*60*60+59;
        when /= 60*60;
        when *= 60*60;
        d = [NSDate dateWithTimeIntervalSince1970:when];
        self.eventBeingEdited.dateWhenVotingClosed = d;
        [self expressLowerDate];
    }
    
    if ( self.eventBeingEdited.date) {
        _pickerEventDate.date= self.eventBeingEdited.date;
        if (!self.editable) {
            _pickerEventDate.minimumDate= self.eventBeingEdited.date;
            _pickerEventDate.maximumDate= self.eventBeingEdited.date;
        }
    }
    
    if (self.eventBeingEdited.dateWhenVotingClosed ) {
        _pickerEventVotingDate.date= self.eventBeingEdited.dateWhenVotingClosed;
        if (!self.editable) {
            _pickerEventVotingDate.minimumDate= self.eventBeingEdited.dateWhenVotingClosed;
            _pickerEventVotingDate.maximumDate= self.eventBeingEdited.dateWhenVotingClosed;
        }
    }

    self.headerWhen= makeLabelLeft(self.view, @" WHEN IS THIS?", kGeomFontSizeStripHeader);
    self.headerEndOfVoting= makeLabelLeft(self.view, @" WHEN IS VOTING CLOSED?", kGeomFontSizeStripHeader);
    _headerWhen.textColor=GRAY;
    _headerEndOfVoting.textColor=GRAY;
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
    if ( self.editable) {
        
        if  (_lowerDateWasModified ) {
            [self extractDateTimeFromLowerPicker];
        }
        if ( _upperDateWasModified) {
            [self extractDateTimeFromUpperPicker];
        }
        
        if ( self.delegate  && (_upperDateWasModified || _lowerDateWasModified)) {
            [self.delegate datesChanged];
        }
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
    
#define OVER_HEIGHT 34
    if  (!bothPickersOpen ) {
        _headerWhen.frame = CGRectMake(0,y, w, kGeomHeightButton);
        y +=kGeomHeightButton +  spacing;

        if  (_pickerEventDate.hidden  ) {
            _buttonEventDate.hidden= NO;
            _buttonEventDate.frame = CGRectMake(0,y, w, kGeomHeightButton);
            _pickerEventDate.frame = CGRectMake(0,y,w, 0);
            _viewOver1.frame = CGRectMake(0,pickerHeight/2-OVER_HEIGHT/2,w,OVER_HEIGHT);
            y +=kGeomHeightButton +  spacing;
        } else {
            _buttonEventDate.frame = CGRectMake(0,y, w, 0);
            _buttonEventDate.hidden= YES;
            _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
            _viewOver1.frame = CGRectMake(0,pickerHeight/2-OVER_HEIGHT/2,w,OVER_HEIGHT);
            y += pickerHeight+ spacing;
        }
        
        y += kGeomSpaceInterMiddle;
        
        _headerEndOfVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
        y +=kGeomHeightButton +  spacing;

        if  (_pickerEventVotingDate.hidden) {
            _buttonEventVoting.hidden= NO;
            _buttonEventVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
            _pickerEventVotingDate.frame = CGRectMake(0,y,w, 0);
            _viewOver2.frame = CGRectMake(0,pickerHeight/2-OVER_HEIGHT/2,w,OVER_HEIGHT);
            y +=kGeomHeightButton +  spacing;
        } else {
            _buttonEventVoting.frame = CGRectMake(0,y, w, 0);
            _buttonEventVoting.hidden= YES;
            float pickerHeight= _pickerEventVotingDate.intrinsicContentSize.height;
            _pickerEventVotingDate.frame = CGRectMake(0,y,w, pickerHeight);
            _viewOver2.frame = CGRectMake(0,pickerHeight/2-OVER_HEIGHT/2,w,OVER_HEIGHT);
            y += pickerHeight+ spacing;
        }
    } else {
        
        _headerWhen.frame = CGRectMake(0,y, w, kGeomHeightButton);
        y +=kGeomHeightButton +  spacing;
        _buttonEventDate.frame = CGRectMake(0,y, w, 0);
        _buttonEventDate.hidden= YES;
        _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
        _viewOver1.frame = CGRectMake(0,pickerHeight/2-OVER_HEIGHT/2,w,OVER_HEIGHT);
        y += pickerHeight+ spacing;
        
        y += kGeomSpaceInterMiddle;
        
        _headerEndOfVoting.frame = CGRectMake(0,y, w, kGeomHeightButton);
        y +=kGeomHeightButton +  spacing;
        _buttonEventVoting.frame = CGRectMake(0,y, w, 0);
        _buttonEventVoting.hidden= YES;
        float pickerHeight= _pickerEventVotingDate.intrinsicContentSize.height;
        _pickerEventVotingDate.frame = CGRectMake(0,y,w, pickerHeight);
        _viewOver2.frame = CGRectMake(0,pickerHeight/2-OVER_HEIGHT/2,w,OVER_HEIGHT);
        y += pickerHeight+ spacing;
    }
    
    _buttonDuration1.frame = CGRectMake(margin,h-kGeomHeightButton- margin,w-2*margin, kGeomHeightButton);
}

@end
