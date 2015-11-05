//
//  EventTVCell.m
//  ooApp
//
//  Created by Zack Smith on 10/5/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "EventTVCell.h"
#import "LocationManager.h"
#import "DebugUtilities.h"

@interface EventTVCell ()

@property (nonatomic, strong) EventObject *eventInfo;
@property (nonatomic, strong) UILabel *labelIndicatingAttendeeCount;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) AFHTTPRequestOperation *imageOperation;
//@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, assign) BOOL isFirst, isMessage;

@end

@implementation EventTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        _viewShadow= makeView(self,  WHITE);
//        addShadowTo(_viewShadow);
        
        _labelIndicatingAttendeeCount= [UILabel  new];
        [self  addSubview: _labelIndicatingAttendeeCount];
        _labelIndicatingAttendeeCount.textColor= WHITE;

        self.header.textAlignment= NSTextAlignmentCenter;
        self.subHeader1.textAlignment= NSTextAlignmentCenter;
        self.subHeader2.textAlignment= NSTextAlignmentCenter;
        self.header.textColor= WHITE;
        self.subHeader1.textColor= WHITE;
        self.subHeader2.textColor= WHITE;
        self.header.font= [ UIFont  fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeHeader];
        self.subHeader1.font= [ UIFont  fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
//        self.thumbnail.contentMode= UIViewContentModeScaleAspectFill;
//        self.thumbnail.clipsToBounds= YES;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self showShadow];
    [self.operation cancel];
    [_imageOperation cancel];
    [self updateHighlighting:NO];
    self.clipsToBounds= NO;
    self.eventInfo= nil;
    [_nameHeader removeFromSuperview];
    _nameHeader = nil;
    self.isFirst= NO;
    self.header.text= nil;
    self.subHeader1.text= nil;
    self.subHeader2.text= nil;
    self.thumbnail.image= nil;
    _labelIndicatingAttendeeCount.text= nil;
    _isMessage= NO;
    self.header.textColor= WHITE;
    
    NSLog (@"0x%lx prepare @ %lu", (unsigned long) self,msTime());
}

- (void)setMessageMode:(NSString *)message;
{
    self.header.text=  message;
    [self hideShadow];
    _isMessage= YES;
    self.header.textColor= BLACK;
}

- (void)setIsFirst
{
    self.isFirst= YES;
}

- (void)updateHighlighting:(BOOL)highlighted;
{
    if (highlighted) {
        self.thumbnail.alpha = 0.5;
    } else {
        self.thumbnail.alpha = 1;
    }
}

- (void)setNameHeader:(OOStripHeader *)header
{
    if (!header || _nameHeader) {
        return;
    }
    _nameHeader = header;
    [self addSubview: header];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self removeConstraints:self.tnConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomWidthMenuButton)};
    
    UIView *superview = self, *tn = self.thumbnail, *shadow = self.viewShadow;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, tn, shadow);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tn]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = width(self);
    CGFloat h = height(self);
    const float lowerGradientHeight =  8;
    float thumbHeight,y;
    
    _nameHeader.frame = CGRectMake(0,(kGeomHeightButton-27)/2,w, 27);
    
    if (!_isMessage) {
        _labelIndicatingAttendeeCount.frame = CGRectMake(w-kGeomButtonWidth-kGeomSpaceEdge,h-kGeomHeightButton-lowerGradientHeight,kGeomButtonWidth,kGeomHeightButton);
        _labelIndicatingAttendeeCount.textAlignment= NSTextAlignmentRight;
        
        // RULE: If the cell is the first one then leave space for the header.
        if  (_isFirst) {
            thumbHeight=h-lowerGradientHeight-kGeomHeightButton/2;
            self.thumbnail.frame = CGRectMake(0,kGeomHeightButton/2,w,thumbHeight);
            y= kGeomHeightButton/2 + (thumbHeight-2*kGeomFontSizeHeader)/2;
        } else {
            thumbHeight=h-lowerGradientHeight;
            self.thumbnail.frame = CGRectMake(0,0,w,thumbHeight);
            y= (thumbHeight-2*kGeomFontSizeHeader)/2;
        }
        
        //NOTE: this is a bit of a hack. We should really be using autolayout
        self.viewShadow.frame = self.thumbnail.frame;
        
//        [self  sendSubviewToBack:_viewShadow ];
        
        [self.header sizeToFit];
        [self.subHeader1 sizeToFit];
        float headerHeight= self.header.frame.size.height;
        float subheaderHeight= self.subHeader1.frame.size.height;
        
        self.header.frame = CGRectMake(0,y,w,headerHeight); y += headerHeight;
        self.subHeader1.frame = CGRectMake(0,y,w,subheaderHeight);
        self.subHeader2.frame = CGRectZero;
    } else {
        self.header.frame = CGRectMake(0,0,w,h);
        self.subHeader1.frame = CGRectZero;
        self.subHeader2.frame = CGRectZero;
        self.thumbnail.frame= CGRectZero;
    }
    
    self.gradient.hidden = YES;
    self.locationIcon.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [_nameHeader unHighlightButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [_nameHeader unHighlightButton];
}

- (void)setEvent:(EventObject *)eo
{
    self.eventInfo = eo;
    self.thumbnail.image = nil;
    self.header.text = eo.name.length ? eo.name :  @"Unnamed event.";
    
    NSString *dateString = expressLocalDateTime(eo.date);
    
    self.subHeader1.text = dateString;
    //    self.subHeader2.text = primaryVenue ? primaryVenue.name :  @"Undisclosed location";
    
    NSInteger numberOfPeople=_eventInfo.numberOfPeople;
    _labelIndicatingAttendeeCount.attributedText= createPeopleIconString(numberOfPeople );
    
    RestaurantObject* primaryVenue= [_eventInfo totalVenues ] ? (RestaurantObject*)[_eventInfo firstVenue ] :nil;
    
    OOAPI *api = [[OOAPI alloc] init];
    UIImage *placeholder= [UIImage imageNamed: @"background-image.jpg"];
    
    if (_eventInfo.primaryImage ) {
        self.thumbnail.image= _eventInfo.primaryImage;
        NSLog (@"0x%lx set primaryImage @ %lu", (unsigned long) self,msTime());
    } else if (!primaryVenue && _eventInfo.numberOfVenues) {
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
                                                                NSURLRequest* request= [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
                                                                
                                                                NSLog (@"0x%lx setImageWithURLRequest @ %lu", (unsigned long) self,msTime());

                                                                [weakSelf.thumbnail setImageWithURLRequest:request
                                                                                          placeholderImage:placeholder
                                                                                                   success:^(NSURLRequest *  request, NSHTTPURLResponse *  response, UIImage *  image) {
                                                                                                       weakSelf.eventInfo.primaryImage= image;
                                                                                                       NSLog  (@"MANAGED TO CAPTURE IMAGE THAT WAS FETCHED.");
                                                                                                       ON_MAIN_THREAD(  ^{
                                                                                                           NSLog (@"0x%lx thumbnail.image @ %lu", (unsigned long) self,msTime());

                                                                                                           weakSelf.thumbnail.image= image;
                                                                                                           weakSelf.thumbnail.hidden= NO;

                                                                                                       });
                                                                                                   } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                                                                       ;
                                                                                                   }];
                                                                
                                                            } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
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
                                                          NSLog (@"0x%lx setImageWithURLRequest @ %lu", (unsigned long) self,msTime());

                                                          NSURLRequest* request= [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
                                                          
                                                          [weakSelf.thumbnail setImageWithURLRequest:request
                                                                                    placeholderImage:placeholder
                                                                                             success:^(NSURLRequest *  request, NSHTTPURLResponse *  response, UIImage *  image) {
                                                                                                 weakSelf.eventInfo.primaryImage= image;
                                                                                                 ON_MAIN_THREAD(  ^{
                                                                                                     NSLog (@"0x%lx thumbnail.image @ %lu", (unsigned long) self,msTime());

                                                                                                     weakSelf.thumbnail.image= image;
                                                                                                 });
                                                                                                 
                                                                                                 NSLog  (@"MANAGED TO OBTAIN IMAGE THAT WAS FETCHED.");
                                                                                             } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                                                                 ;
                                                                                             }];
                                                      } failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                                          [weakSelf.thumbnail setImage:placeholder];
                                                      }];
        
    }  else {
        NSLog (@"EVENT %lu HAS NO PRIMARY VENUE",(unsigned long)_eventInfo.eventID);
        [self.thumbnail setImage:placeholder];
    }
}

@end
