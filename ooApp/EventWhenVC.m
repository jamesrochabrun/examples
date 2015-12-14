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
    ONE_HOUR,  ONE_DAY,  TWO_DAYS
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

//    self.pickerEventVotingDate= [[UIDatePicker  alloc] init];
//    [self.view addSubview: _pickerEventVotingDate];
//    _pickerEventVotingDate.backgroundColor= WHITE;
//    _pickerEventVotingDate.tintColor= WHITE;
//    self.buttonEventVoting=makeButton(self.view, @"Press here to set.", kGeomFontSizeHeader,  WHITE, CLEAR, self, @selector(userPressedLowerButton:), 0);
    
    UIButton* buttonVotingOption1= makeButton( self.view,  @"1 hour before",
                                             kGeomFontSizeHeader, WHITE, CLEAR,
                                             self, @selector(userPressedOption:) , 0);
    buttonVotingOption1.tag= 0;
    UIButton* buttonVotingOption2= makeButton( self.view,  @"1 day before",
                                             kGeomFontSizeHeader, WHITE, CLEAR,
                                             self, @selector(userPressedOption:) , 0);
    buttonVotingOption2.tag= 1;
    UIButton *buttonVotingOption3= makeButton( self.view,  @"2 days before",
                                             kGeomFontSizeHeader, WHITE, CLEAR,
                                             self, @selector(userPressedOption:) , 0);
    buttonVotingOption3.tag= 2;
    self.arrayOfVotingOptionButtons=  @[
                                        buttonVotingOption1,
                                        buttonVotingOption2,
                                        buttonVotingOption3
                                        ];
    
    self.viewOver1 = [[UIView alloc] init];
    _viewOver1.backgroundColor = YELLOW;
    _viewOver1.alpha = 0.5f;
    [_pickerEventDate addSubview: _viewOver1];
    
//    self.viewOver2 = [[UIView alloc] init];
//    _viewOver2.backgroundColor = YELLOW;
//    _viewOver2.alpha = 0.5f;
//    [_pickerEventVotingDate addSubview: _viewOver2];

    addShadowTo(_pickerEventDate);
    _pickerEventDate.timeZone= [NSTimeZone systemTimeZone];
    _pickerEventDate.minuteInterval=15;
    _pickerEventDate.datePickerMode= UIDatePickerModeDateAndTime;

    //    _pickerEventVotingDate.timeZone= [NSTimeZone systemTimeZone];
//    _pickerEventVotingDate.minuteInterval=15;
    //    addShadowTo(_pickerEventVotingDate);

//    _pickerEventVotingDate.datePickerMode= UIDatePickerModeDateAndTime;
    
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
        long long when= [self.eventBeingEdited.date timeIntervalSince1970];
        long long whenVotingEnds = [self.eventBeingEdited.dateWhenVotingClosed timeIntervalSince1970];
        long long difference = when-whenVotingEnds;
        if  (difference>=ONE_HOUR-5  && difference<=ONE_HOUR+5 ) {
            _lowerSelection= 0;
        }
        else if (difference>=ONE_DAY-5  && difference<=ONE_DAY+5) {
            _lowerSelection= 1;
        }
        else if (difference>=TWO_DAYS-5  && difference<=TWO_DAYS+5) {
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
//    if (self.eventBeingEdited.dateWhenVotingClosed ) {
//        _pickerEventVotingDate.date= self.eventBeingEdited.dateWhenVotingClosed;
//        if (!self.editable) {
//            _pickerEventVotingDate.minimumDate= self.eventBeingEdited.dateWhenVotingClosed;
//            _pickerEventVotingDate.maximumDate= self.eventBeingEdited.dateWhenVotingClosed;
//        }
//    }

    self.headerWhen= makeLabelLeft(self.view, @" WHEN IS THIS?", kGeomFontSizeStripHeader);
    self.headerEndOfVoting= makeLabelLeft(self.view, @" WHEN IS VOTING CLOSED?", kGeomFontSizeStripHeader);
    _headerWhen.textColor=GRAY;
    _headerEndOfVoting.textColor=GRAY;
    
    removeRightButton(self.navigationItem);
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
}

- (void)userAlteredPicker: (id) sender
{
    _upperDateWasModified= YES;
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

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)expressUpperDate
{
    NSDate* gmtTime= self.eventBeingEdited.date;

    [_buttonEventDate setTitle: expressLocalDateTime(gmtTime)
                      forState:UIControlStateNormal];
}

//- (void)expressLowerDate
//{
//    NSDate* gmtTime= self.eventBeingEdited.dateWhenVotingClosed;
//    
//    [_buttonEventVoting setTitle:expressLocalDateTime (gmtTime)
//                        forState:UIControlStateNormal];
//}

- (void)viewWillDisappear:(BOOL)animated
{
    if ( self.editable) {
        
        if ( _upperDateWasModified || _lowerSelectionModified) {
            [self extractDateTimeFromUpperPicker];
        }
        
        if  (_lowerSelectionModified ) {
//            [self extractDateTimeFromLowerPicker];
            [self updateVoteEndingDate];
        }
        
        if ( self.delegate  && (_upperDateWasModified || _lowerSelectionModified)) {
            [self.delegate datesChanged];
        }
    }
    
    [super viewWillDisappear:animated];
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

//- (void)extractDateTimeFromLowerPicker
//{
//    NSDate *gmtTime= _pickerEventVotingDate.date;
//    self.eventBeingEdited.dateWhenVotingClosed= gmtTime;
//    self.eventBeingEdited.hasBeenAltered= YES;// XX:  need to write set date when voting method
//    [self expressLowerDate];
//}

- (void)userPressedUpperButton: (id) sender
{
//    _pickerEventDate.hidden= !_pickerEventDate.hidden;
//    if (!_pickerEventVotingDate.hidden) {
////        [self extractDateTimeFromLowerPicker];
//    }
//    if (! _pickerEventDate.hidden) {
//        _pickerEventVotingDate.hidden= YES;
//    }else {
//        [self extractDateTimeFromUpperPicker];
//    }
//    __weak EventWhenVC *weakSelf = self;
//    [UIView animateWithDuration: 0.4 animations:^{
//        [weakSelf doLayout];
//    }];
//    
//    _upperDateWasModified= YES;
}

//- (void)userPressedLowerButton: (id) sender
//{
//    _pickerEventVotingDate.hidden= !_pickerEventVotingDate.hidden;
//    if (!_pickerEventDate.hidden) {
//        [self extractDateTimeFromUpperPicker];
//    }
//    if (! _pickerEventVotingDate.hidden) {
//        _pickerEventDate.hidden= YES;
//    }else {
//        [self extractDateTimeFromLowerPicker];
//    }
//    __weak EventWhenVC *weakSelf = self;
//    [UIView animateWithDuration: 0.4 animations:^{
//        [weakSelf doLayout];
//    }];
//    
//    _lowerDateWasModified= YES;
//}

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
    float  spacing= IS_IPHONE4? 5 : kGeomSpaceInter;

    float pickerHeight= _pickerEventDate.intrinsicContentSize.height;

#if 0
    float y=  margin;
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
#endif
    
    const  float kGeomWidthOptionButton= 130;
    const  float kGeomHeightOptionButton= IS_IPHONE4 ? 37 : 44;
    float totalRequiredHeight=  pickerHeight + kGeomHeightOptionButton*_arrayOfVotingOptionButtons.count;
    totalRequiredHeight += kGeomFontSizeHeader;
    totalRequiredHeight += 2*kGeomFontSizeHeader;

    float y=  margin;
    _buttonEventDate.frame = CGRectMake(0,y, w, kGeomHeightButton);
    y +=kGeomHeightButton +  spacing;
    
    _pickerEventDate.frame = CGRectMake(0,y,w, pickerHeight);
    y += pickerHeight+ spacing;
    y +=  spacing;
    
    [_labelOptions sizeToFit];
    _labelOptions.frame = CGRectMake(0,y,w,_labelOptions.frame.size.height);
    y += _labelOptions.frame.size.height;

    for (UIButton* button  in  _arrayOfVotingOptionButtons) {
         button.frame = CGRectMake( (w-kGeomWidthOptionButton)/2,y,kGeomWidthOptionButton,  kGeomHeightOptionButton);
        y += kGeomHeightOptionButton;
    }

}

@end
