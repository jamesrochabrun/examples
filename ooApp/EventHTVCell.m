//
//  EventHTVCell.m
//  ooApp
//
//  Created by Zack Smith on 10/5/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "EventHTVCell.h"
#import "LocationManager.h"

@interface EventHTVCell ()
@property (nonatomic,strong) EventObject* eventInfo;
@property (nonatomic,strong)  UILabel *labelIndicatingAttendeeCount;
@end

@implementation EventHTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _labelIndicatingAttendeeCount= makeIconLabel(self, [NSString stringWithFormat: @"%@ %@", kFontIconPerson,kFontIconPerson ], 30);
        
    }
    return self;
}

- (void) layoutSubviews
{
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    
    _labelIndicatingAttendeeCount.frame = CGRectMake(w-kGeomButtonWidth-kGeomSpaceEdge,h-kGeomHeightButton,kGeomButtonWidth,kGeomHeightButton);
    _labelIndicatingAttendeeCount.textAlignment= NSTextAlignmentRight;
}

- (void)setEvent:(EventObject *)eo
{
    // NOTE:  the contents of the user object may have changed, therefore set user always.
    
    RestaurantObject* primaryVenue= _eventInfo.restaurants.count ? (RestaurantObject*)_eventInfo.restaurants[0] :nil;
    self.eventInfo = eo;
    self.thumbnail.image = nil;
    self.header.text = eo.name;
    
//    NSDate *localDate= [_eventInfo.date
    
    NSString* dateString= [NSString stringWithFormat: @"%@",_eventInfo.date];
    if ( dateString.length  == 25) {
        dateString= [dateString substringToIndex:16];
    }
    
    self.subHeader1.text = dateString;
    self.subHeader2.text = primaryVenue ? primaryVenue.name :  @"Undisclosed location";
    
    UIImage *placeholder= [UIImage imageNamed: @"forkKnife"];

    if (primaryVenue && primaryVenue.imageRefs.count) {
        NSString *str= primaryVenue.imageRefs[0];
        [self.thumbnail setImageWithURL:[NSURL URLWithString: str] placeholderImage:placeholder];

    }  else {
        [self.thumbnail setImage:placeholder];
    }
}

@end
