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

static int votingEndingValues[3]= {
  HALF_HOUR, ONE_DAY, ONE_WEEK
};

@interface EventWhenVC ()
@property (nonatomic,strong)  UILabel* labelEventDateHeader;
@property (nonatomic,strong)   UIButton* buttonEventDate;
@property (nonatomic,strong)   UIButton* buttonEventVoting;
@property (nonatomic,strong) UIButton* buttonDuration1;
@property (nonatomic,strong)  UIDatePicker* pickerEventDate;
@property (nonatomic,strong)   UIDatePicker* pickerEventVotingDate;
@property (nonatomic,assign) BOOL upperDateWasModified;
@property (nonatomic,assign) BOOL lowerDateWasModified;
@property (nonatomic,assign)  int lowerSelection;
@property (nonatomic,assign)  BOOL lowerSelectionModified;
@property (nonatomic,strong) UILabel *headerWhen;
@property (nonatomic,strong) UILabel *headerEndOfVoting;
@property (nonatomic,strong) UIView*viewOver1;
@property (nonatomic,strong) UIView*viewOver2;
@property (nonatomic,strong)  UILabel* labelOptions;
@property (nonatomic,strong) NSArray* arrayOfVotingOptionButtons;
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
    
    self.pickerEventDate= [[UIDatePicker  alloc] init];
    [self.view addSubview: _pickerEventDate ];
    _pickerEventDate.backgroundColor= UIColorRGB(kColorOffBlack);
    _pickerEventDate.tintColor= WHITE;
    _pickerEventDate.tintAdjustmentMode= UIViewTintAdjustmentModeAutomatic;
    [_pickerEventDate addTarget:self action:@selector(userAlteredPicker:) forControlEvents:UIControlEventValueChanged];
    [_pickerEventDate setValue:[UIColor whiteColor] forKey:@"textColor"];
    
    self.labelOptions= makeLabel( self.view,  @"When is Voting Closed?", kGeomFontSizeHeader);
    _labelOptions.textColor= WHITE;
    self.lowerSelection=  -1;

    UIButton* buttonVotingOption0= makeButton( self.view,  @"30 minutes before",
                                              kGeomFontSizeHeader, WHITE, CLEAR,
                                              self, @selector(userPressedOption:) , 0);
    buttonVotingOption0.tag= 0;
    UIButton* buttonVotingOption1= makeButton( self.view,  @"1 day before",
                                              kGeomFontSizeHeader, WHITE, CLEAR,
                                              self, @selector(userPressedOption:) , 0);
    buttonVotingOption1.tag= 1;
    UIButton* buttonVotingOption2= makeButton( self.view,  @"1 week before",
                                             kGeomFontSizeHeader, WHITE, CLEAR,
                                             self, @selector(userPressedOption:) , 0);
    buttonVotingOption2.tag= 2;

    self.arrayOfVotingOptionButtons=  @[
                                        buttonVotingOption0,
                                        buttonVotingOption1,
                                        buttonVotingOption2,
                                        ];
    
    self.viewOver1 = [[UIView alloc] init];
    _viewOver1.backgroundColor = YELLOW;
    _viewOver1.alpha = 0.5f;
    [_pickerEventDate addSubview: _viewOver1];
    
//    addShadowTo(_pickerEventDate);
    _pickerEventDate.timeZone= [NSTimeZone systemTimeZone];
    _pickerEventDate.minuteInterval=15;
    _pickerEventDate.datePickerMode= UIDatePickerModeDateAndTime;

    if (self.eventBeingEdited.date ) {
        [self expressUpperDate];
    } else {
        // RULE: Set up default date to be 3 hours in future.
        NSDate *d = [NSDate date];
        long long when= [d timeIntervalSince1970];
        when += 3*ONE_HOUR+59; // As per Jay, 6:15 becomes 10:00.
        when /= ONE_HOUR;
        when *= ONE_HOUR;
        d = [NSDate dateWithTimeIntervalSince1970:when];
        self.eventBeingEdited.date = d;
        [self expressUpperDate];
    }

    if ( self.eventBeingEdited.dateWhenVotingClosed && self.eventBeingEdited.date) {
        long long when = [self.eventBeingEdited.date timeIntervalSince1970];
        long long whenVotingEnds = [self.eventBeingEdited.dateWhenVotingClosed timeIntervalSince1970];
        long long difference = when-whenVotingEnds;
        if  (difference>=HALF_HOUR-5  && difference<=HALF_HOUR+5 ) {
            _lowerSelection= 0;
        }
        else if (difference>=ONE_DAY-5  && difference<=ONE_DAY+5) {
            _lowerSelection= 1;
        }
        else if (difference>=ONE_WEEK-5  && difference<=ONE_WEEK+5) {
            _lowerSelection= 2;
        }
        [self highlightSelection];
    }
    
    _pickerEventDate.minimumDate= [NSDate date ];
    if ( self.eventBeingEdited.date) {
        _pickerEventDate.date= self.eventBeingEdited.date;
        if (!self.editable) {
            _pickerEventDate.minimumDate= self.eventBeingEdited.date;
            _pickerEventDate.maximumDate= self.eventBeingEdited.date;
        }
    }

    self.headerWhen= makeLabelLeft(self.view, @" WHEN IS THIS?", kGeomFontSizeStripHeader);
    self.headerEndOfVoting= makeLabelLeft(self.view, @" WHEN IS VOTING CLOSED?", kGeomFontSizeStripHeader);
    _headerWhen.textColor=GRAY;
    _headerEndOfVoting.textColor=GRAY;
    
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
}

- (void)userAlteredPicker: (id) sender
{
    _upperDateWasModified= YES;
    self.eventBeingEdited.date = _pickerEventDate.date;
    [self updateVoteEndingDate];
}

- (void)userPressedOption: (UIButton*)sender
{
    if (!self.editable)
        return;

    _lowerSelectionModified= YES;
    _lowerSelection=sender.tag;
    NSUInteger durationBefore=  0;
    if  ( _lowerSelection<(sizeof(votingEndingValues)/ sizeof(int))) {
        durationBefore= votingEndingValues[ _lowerSelection];
        NSTimeInterval t = [_pickerEventDate.date timeIntervalSince1970];
        t -= durationBefore;
        
        NSDate *d=[NSDate date];
        NSTimeInterval tnow=d.timeIntervalSince1970;
        if (tnow>t) {
            message(@"That time is in the past.");
            _lowerSelection=-1;
        }
        
        [self highlightSelection];
    }
}

- (void) highlightSelection
{
    int i= 0;
    for (UIButton* button  in  _arrayOfVotingOptionButtons) {
        button.backgroundColor=  _lowerSelection==i? RED:CLEAR;
        i ++;
    }
    
}

- (void)done:(id)sender
{
    // RULE: If the dates have changed only transition to the previous screen after the backend has been updated.
    if ( self.editable) {
        BOOL changed= NO;
        
        if ( _upperDateWasModified || _lowerSelectionModified) {
            [self extractDateTimeFromUpperPicker];
            changed= YES;
        }
        
        if  (_lowerSelectionModified ) {
            [self updateVoteEndingDate];
            changed= YES;
        }
        
        if ( self.delegate  && changed) {
            [self.delegate datesChanged];
        }
        
        if (!changed) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            __weak EventWhenVC *weakSelf = self;
            [self.eventBeingEdited sendDatesToServerWithCompletionBlock:^  {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)expressUpperDate
{
    NSDate* gmtTime= self.eventBeingEdited.date;

    [_buttonEventDate setTitle: expressLocalDateTime(gmtTime)
                      forState:UIControlStateNormal];
}

- (void)updateVoteEndingDate
{
    NSDate*date= _pickerEventDate.date;
    NSTimeInterval t= date.timeIntervalSince1970;
    
    if  ( _lowerSelection<(sizeof(votingEndingValues)/ sizeof(int))) {
        t-= votingEndingValues[_lowerSelection];
    }
    
    self.eventBeingEdited.dateWhenVotingClosed= [NSDate dateWithTimeIntervalSince1970:t];
    
    if ( t<[NSDate date].timeIntervalSince1970) {
        self.eventBeingEdited.dateWhenVotingClosed= nil;
        _lowerSelection= -1;
        [self highlightSelection];
    }
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

- (void)userPressedUpperButton: (id) sender
{
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float  spacing= IS_IPHONE4? 5 : kGeomSpaceInter;

    float pickerHeight= _pickerEventDate.intrinsicContentSize.height;
    const  float kGeomWidthOptionButton= 130;
    const  float kGeomHeightOptionButton= IS_IPHONE4? 37: kGeomHeightButton;
    float totalRequiredHeight= pickerHeight + kGeomHeightOptionButton*_arrayOfVotingOptionButtons.count;
    totalRequiredHeight += kGeomFontSizeHeader;
    totalRequiredHeight += 2*kGeomFontSizeHeader;

    float y= IS_IPHONE4? 0: margin;
    _buttonEventDate.frame = CGRectMake(0,y, w, kGeomHeightButton);
    y +=kGeomHeightButton +  spacing;
    
    _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
    y += pickerHeight+ spacing;
    y +=  spacing;
    
    [_labelOptions sizeToFit];
    _labelOptions.frame = CGRectMake(0,y,w,_labelOptions.frame.size.height);
    y += _labelOptions.frame.size.height;
    y+= spacing;

    for (UIButton* button  in  _arrayOfVotingOptionButtons) {
         button.frame = CGRectMake( (w-kGeomWidthOptionButton)/2,y,kGeomWidthOptionButton,  kGeomHeightOptionButton);
        y += kGeomHeightOptionButton;
    }
}

@end
