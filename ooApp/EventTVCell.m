//
//  EventTVCell.m
//  ooApp
//
//  Created by Zack Smith on 10/5/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "EventTVCell.h"
#import "LocationManager.h"

@interface EventTVCell ()
@property (nonatomic,strong) EventObject* eventInfo;
@property (nonatomic,strong)  UILabel *labelIndicatingAttendeeCount;
@end

@implementation EventTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _labelIndicatingAttendeeCount= [UILabel  new];
        [self  addSubview: _labelIndicatingAttendeeCount];
        _labelIndicatingAttendeeCount.textColor= WHITE;

        self.header.textAlignment= NSTextAlignmentCenter;
        self.subHeader1.textAlignment= NSTextAlignmentCenter;
        self.subHeader2.textAlignment= NSTextAlignmentCenter;
        self.header.textColor= WHITE;
        self.subHeader1.textColor= WHITE;
        self.subHeader2.textColor= WHITE;

        self.thumbnail.contentMode= UIViewContentModeScaleAspectFill;
        self.thumbnail.alpha= .6;
        self.thumbnail.clipsToBounds= YES;

    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    const float lowerGradientHeight=  15;
    
    _labelIndicatingAttendeeCount.frame = CGRectMake(w-kGeomButtonWidth-kGeomSpaceEdge,h-kGeomHeightButton-lowerGradientHeight,kGeomButtonWidth,kGeomHeightButton);
    _labelIndicatingAttendeeCount.textAlignment= NSTextAlignmentRight;
    
    self.thumbnail.frame = CGRectMake(0,0,w,h-lowerGradientHeight);
    
    float y= (h-lowerGradientHeight-2*kGeomFontSizeHeader)/2;
    self.header.frame = CGRectMake(0,y,w,kGeomFontSizeHeader); y += kGeomFontSizeHeader;
    self.subHeader1.frame = CGRectMake(0,y,w,kGeomFontSizeHeader); y += kGeomFontSizeHeader;
//    self.subHeader2.frame = CGRectMake(0,y,w,kGeomFontSizeHeader);

    
}

- (void)setEvent:(EventObject *)eo
{
    // NOTE: The contents of the user object may have changed, therefore set user always.
    
    RestaurantObject* primaryVenue= [_eventInfo totalVenues ] ?
            (RestaurantObject*)[_eventInfo firstVenue ] :nil;
    self.eventInfo = eo;
    self.thumbnail.image = nil;
    self.header.text = eo.name.length ? eo.name :  @"Unnamed event.";
    
    // NOTE:  need to localize the date and time expression.
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM dd, hh:mm"];
    NSString*dateString = [df stringFromDate:[NSDate date]];
    
    self.subHeader1.text = dateString;
//    self.subHeader2.text = primaryVenue ? primaryVenue.name :  @"Undisclosed location";
    
    NSInteger numberOfPeople=_eventInfo.numberOfPeople;
    _labelIndicatingAttendeeCount.attributedText= createPeopleIconString(numberOfPeople );

    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];

    if (primaryVenue && primaryVenue.imageRefs.count) {
        NSString *str= primaryVenue.imageRefs[0];
        [self.thumbnail setImageWithURL:[NSURL URLWithString: str] placeholderImage:placeholder];

    }  else {
        [self.thumbnail setImage:placeholder];
    }
}

@end
