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
@property (nonatomic,strong)  AFHTTPRequestOperation *operation;
@property (nonatomic,strong)  AFHTTPRequestOperation *imageOperation;
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
        self.thumbnail.clipsToBounds= YES;
    }
    return self;
}

- (void)prepareForReuse
{
    [  super prepareForReuse];
    [self.operation cancel ];
    [_imageOperation cancel];
    [self updateHighlighting:NO];
    self.clipsToBounds= NO;
    self.eventInfo= nil;    
    [_nameHeader removeFromSuperview];
    _nameHeader = nil;
    self.header.text= nil;
    self.subHeader1.text= nil;
    self.subHeader2.text= nil;
    self.thumbnail.image= nil;
    _labelIndicatingAttendeeCount.text= nil;
}

- (void) updateHighlighting: (BOOL)highlighted;
{
    if  (highlighted ) {
        self.thumbnail.alpha=  .5;
    } else {
        self.thumbnail.alpha=  1;
    }
}

- (void)setNameHeader: (OOStripHeader*)header
{
    if (!header || _nameHeader) {
        return;
    }
    _nameHeader= header;
    [self  addSubview: header];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    const float lowerGradientHeight=  5;
    _nameHeader.frame = CGRectMake(0,(kGeomHeightButton-27)/2,w, 27);
    
    _labelIndicatingAttendeeCount.frame = CGRectMake(w-kGeomButtonWidth-kGeomSpaceEdge,h-kGeomHeightButton-lowerGradientHeight,kGeomButtonWidth,kGeomHeightButton);
    _labelIndicatingAttendeeCount.textAlignment= NSTextAlignmentRight;
    
    float thumbHeight=h-lowerGradientHeight-kGeomHeightButton/2;
    self.thumbnail.frame = CGRectMake(0,kGeomHeightButton/2,w,thumbHeight);
    
    float y= kGeomHeightButton/2+ (thumbHeight-2*kGeomFontSizeHeader)/2;
    self.header.frame = CGRectMake(0,y,w,kGeomFontSizeHeader); y += kGeomFontSizeHeader;
    self.subHeader1.frame = CGRectMake(0,y,w,kGeomFontSizeHeader); y += kGeomFontSizeHeader;
    //    self.subHeader2.frame = CGRectMake(0,y,w,kGeomFontSizeHeader);
}

- (void)setEvent:(EventObject *)eo
{
    self.eventInfo = eo;
    self.thumbnail.image = nil;
    self.header.text = eo.name.length ? eo.name :  @"Unnamed event.";
    
    NSString*dateString = expressLocalDateTime(eo.date);
    
    self.subHeader1.text = dateString;
    //    self.subHeader2.text = primaryVenue ? primaryVenue.name :  @"Undisclosed location";
    
    NSInteger numberOfPeople=_eventInfo.numberOfPeople;
    _labelIndicatingAttendeeCount.attributedText= createPeopleIconString(numberOfPeople );
    
    RestaurantObject* primaryVenue= [_eventInfo totalVenues ] ? (RestaurantObject*)[_eventInfo firstVenue ] :nil;
    
    OOAPI *api = [[OOAPI alloc] init];
    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];

    if (!primaryVenue && _eventInfo.numberOfVenues) {
        __weak EventTVCell *weakSelf = self;
        
        self.thumbnail.image= placeholder;
        
        self.operation= [_eventInfo refreshVenuesFromServerWithSuccess:^{
            NSLog (@"DID REFRESH VENUES OF %@, TOTAL= %ld",[weakSelf.eventInfo asString],
                   ( unsigned long) [_eventInfo totalVenues ]);
            if  (!_eventInfo.primaryVenueImageIdentifier ) {
                [weakSelf.thumbnail setImage:placeholder];
            } else {
                __weak EventTVCell *weakSelf = self;
                _imageOperation=[api getRestaurantImageWithImageRef: _eventInfo.primaryVenueImageIdentifier
                                                           maxWidth:self.frame.size.width// XX:
                                                          maxHeight:0
                                                            success:^(NSString *link) {
                                                                ON_MAIN_THREAD(  ^{
                                                                    [weakSelf.thumbnail
                                                                     setImageWithURL:[NSURL URLWithString:link]
                                                                     placeholderImage:placeholder];
                                                                });
                                                            } failure:^(NSError *error) {
                                                                [weakSelf.thumbnail setImage:placeholder];
                                                            }];
            }
        }
                                                               failure:^{
                                                                   NSLog  (@" failed to refresh");
                                                               }];
        
        return;
    }
    else if (_eventInfo.primaryVenueImageIdentifier) {
        
        __weak EventTVCell *weakSelf = self;
        _imageOperation=  [api getRestaurantImageWithImageRef: _eventInfo.primaryVenueImageIdentifier
                                                     maxWidth:self.frame.size.width
                                                    maxHeight:0
                                                      success:^(NSString *link) {
                                                          ON_MAIN_THREAD(  ^{
                                                              [weakSelf.thumbnail
                                                               setImageWithURL:[NSURL URLWithString:link]
                                                               placeholderImage:placeholder];
                                                          });
                                                      } failure:^(NSError *error) {
                                                          [weakSelf.thumbnail setImage:placeholder];
                                                      }];
        
    }  else {
        NSLog (@"EVENT %ld HAS NO PRIMARY VENUE",_eventInfo.eventID);
        [self.thumbnail setImage:placeholder];
    }
}

@end
