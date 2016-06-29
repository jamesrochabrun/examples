//
//  RestaurantMainCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "TTTAttributedLabel.h"
#import "OOAPI.h"
#import "RestaurantMainCVCell.h"
#import "LocationManager.h"
#import "DebugUtilities.h"
#import "HoursOpen.h"
#import "UIImageEffects.h"
#import "RestaurantListVC.h"
#import "AppDelegate.h"
#import "NSString+Util.h"

@interface RestaurantMainCVCell()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
//@property (nonatomic, strong) TTTAttributedLabel *phoneNumber;
//@property (nonatomic, strong) TTTAttributedLabel *website;
@property (nonatomic, strong) TTTAttributedLabel *address;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *priceRange;
@property (nonatomic, strong) UILabel *isOpen;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UILabel *cuisine;
@property (nonatomic, strong) UIButton *website;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *imageOverlay;
@property (nonatomic, strong) UIButton *hoursButton;
@property (nonatomic, strong) UIScrollView *hoursScroll;
@property (nonatomic, strong) UILabel *hoursView;
@property (nonatomic, strong) UIView *verticalLine1;
@property (nonatomic, strong) UIView *verticalLine2;
@end

@implementation RestaurantMainCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
        _backgroundImage.clipsToBounds = YES;
        [self addSubview:_backgroundImage];
        
        _imageOverlay = [[UIView alloc] init];
        _imageOverlay.backgroundColor = UIColorRGBOverlay(kColorWhite, 0.5);
        [_backgroundImage addSubview:_imageOverlay];
        
        _verticalLine1 = [[UIView alloc] init];
        _verticalLine2 = [[UIView alloc] init];
        [self addSubview:_verticalLine1];
        [self addSubview:_verticalLine2];
        
        _verticalLine1.backgroundColor = _verticalLine2.backgroundColor = UIColorRGBA(kColorText);
        
        _hoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hoursButton withText:@"" fontSize:kGeomFontSizeH2 width:100 height:30 backgroundColor:kColorClear target:self selector:@selector(viewHours)];
        [_hoursButton setTitleColor:UIColorRGBA(kColorText) forState:UIControlStateNormal];
        _hoursButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_hoursButton setContentEdgeInsets:UIEdgeInsetsMake(0, kGeomSpaceEdge, 0, kGeomSpaceEdge)];
        [self addSubview:_hoursButton];
        
        _hoursScroll = [[UIScrollView alloc] init];
        _hoursScroll.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        
        _hoursView = [[UILabel alloc] init];
        _hoursView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
        _hoursView.textColor = UIColorRGBA(kColorText);
        _hoursView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
        _hoursView.numberOfLines = 0;
        _hoursView.lineBreakMode = NSLineBreakByWordWrapping;
        _hoursView.textAlignment = NSTextAlignmentLeft;
        [_hoursScroll addSubview:_hoursView];
        
        _name = [[UILabel alloc] init];
        [_name withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeBig] textColor:kColorText backgroundColor:kColorClear];
        [self addSubview:_name];
        
        _priceRange = [[UILabel alloc] init];
        [_priceRange withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorText backgroundColor:kColorClear];
        [self addSubview:_priceRange];

        _website = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_website];

        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_menuButton];
        
        _distance = [[UILabel alloc] init];
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorText backgroundColor:kColorClear];
        [self addSubview:_distance];
        
        _cuisine = [[UILabel alloc] initWithFrame:CGRectZero];
        [_cuisine withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorText backgroundColor:kColorClear];
        [self addSubview:_cuisine];
        
        _address = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_address withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorText backgroundColor:kColorClear];
        [self addSubview:_address];
        self.backgroundColor = UIColorRGBA(kColorWhite);
        
        _hoursScroll.layer.borderColor = _hoursButton.layer.borderColor = UIColorRGBA(kColorBordersAndLines).CGColor;
        _hoursScroll.layer.borderWidth = _hoursButton.layer.borderWidth = 1;
        _hoursScroll.hidden = YES;
        [self addSubview:_hoursScroll]; //should appear above everything
                
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
//        [DebugUtilities addBorderToViews:@[_name, _priceRange, _distance, _cuisine, _hoursButton, _address, _website]];
    }
    return self;
}

- (CGFloat)getHeight {
    CGFloat height = 0;
    
    if (_restaurant.name) height += [self getEstimatedHeightForFont:_name.font] + kGeomSpaceEdge;
    
    if (_restaurant.cuisine) height += ([self getEstimatedHeightForFont:_cuisine.font] + kGeomSpaceInter);
    
    if (_restaurant.location.latitude || _restaurant.priceRange) height += ([self getEstimatedHeightForFont:_priceRange.font] + kGeomSpaceInter);
    
    if (_restaurant.hours) height += (30 + kGeomSpaceInter);
    
    if (_restaurant.address) height += ([self getEstimatedHeightForFont:_address.font] + kGeomSpaceInter);
    
    if ([_restaurant.website length] || [_restaurant.mobileMenuURL length]) height += (kGeomHeightButton + kGeomSpaceInter);
                                                                            
    return height;
}

- (CGFloat)getEstimatedHeightForFont:(UIFont *)font {
    UILabel *l = [UILabel new];
    l.text = @"X";
    l.font = font;
    return [l intrinsicContentSize].height;
}

- (void)viewHours {
    _hoursScroll.hidden = !_hoursScroll.hidden;
    [self setNeedsLayout];
}

- (void)goToMenuURL {
    NSURL *url = [NSURL URLWithString:_restaurant.mobileMenuURL];
    [_delegate restaurantMainCVCell:self gotoURL:url];
}

- (void)goToWebsiteURL {
    NSURL *url = [NSURL URLWithString:_restaurant.website];
    [_delegate restaurantMainCVCell:self gotoURL:url];
}

- (void)morePressed:(id)sender {
    [_delegate restaurantMainCVCellMorePressed:sender];
}

- (void)showOnMap {
    [_delegate restaurantMainCVCell:self showMapTapped:_restaurant.location];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [_delegate restaurantMainCVCell:self gotoURL:url];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = width(self);
//    CGFloat h = height(self);
    CGRect frame;
    CGSize s;
    CGFloat y, x;

    _backgroundImage.frame = self.bounds;
    _imageOverlay.frame = self.bounds;
    
    frame = _name.frame;
    frame.origin = CGPointMake(kGeomSpaceEdge, kGeomSpaceEdge);
    frame.size = CGSizeMake(width(_name), height(_name));
    _name.frame = frame;
    
    y = CGRectGetMaxY(_name.frame);
    
    if (_restaurant.cuisine) {
        y+=kGeomSpaceInter;
        
        frame = _cuisine.frame;
        frame.origin = CGPointMake(kGeomSpaceEdge, y);
        frame.size = CGSizeMake(width(_cuisine), height(_cuisine));
        _cuisine.frame = frame;
        y = CGRectGetMaxY(_cuisine.frame);
    }
    
    if (_restaurant.location.latitude || _restaurant.priceRange) {
        y+=kGeomSpaceInter;
        
        frame = _priceRange.frame;
        frame.origin = CGPointMake(kGeomSpaceEdge, y);
        frame.size = CGSizeMake(width(_priceRange), height(_priceRange));
        _priceRange.frame = frame;
        
        x = kGeomSpaceEdge;
        
        if (_restaurant.location.latitude && _restaurant.priceRange) {
            CGFloat trim = 0;
            frame = _verticalLine1.frame;
            frame.origin = CGPointMake(CGRectGetMaxX(_priceRange.frame) + kGeomSpaceInter, y+trim/2);
            frame.size = CGSizeMake(1, height(_priceRange)-trim);
            _verticalLine1.frame = frame;
            x = CGRectGetMaxX(_verticalLine1.frame) + kGeomSpaceInter;
        }
        
        frame = _distance.frame;
        frame.origin = CGPointMake(x, y);
        frame.size = CGSizeMake(width(_distance), height(_distance));
        _distance.frame = frame;
        
        if (_restaurant.location.latitude) {
            y = CGRectGetMaxY(_distance.frame);
        } else {
            y = CGRectGetMaxY(_priceRange.frame);
        }
    }
    
    if (_restaurant.hours) {
        y+=kGeomSpaceInter;
        
        s = [_hoursView.text sizeWithAttributes:@{NSFontAttributeName:_hoursView.font}];
        _hoursScroll.contentSize = CGSizeMake(width(_hoursScroll), s.height);
        
        frame = _hoursButton.frame;
        frame.size.width = s.width + 20;
        frame.size.height = 30;
        frame.origin = CGPointMake(kGeomSpaceEdge, y);
        _hoursButton.frame = frame;
        y = CGRectGetMaxY(_hoursButton.frame);
        
        frame = _hoursScroll.frame;
        frame.origin = CGPointMake(CGRectGetMinX(_hoursButton.frame), y);
        frame.size.height = height(self) - y - kGeomSpaceEdge;
        frame.size.width = width(_hoursButton);
        _hoursScroll.frame = frame;
        
        frame = _hoursScroll.bounds;
        frame.size.height = s.height;
        _hoursView.frame = frame;
    }
    
    if (_restaurant.address) {
        y+=kGeomSpaceInter;
        
        frame = _address.frame;
        frame.size.width = w - 2*(kGeomSpaceEdge);
        frame.origin = CGPointMake(kGeomSpaceEdge, y);
        _address.frame = frame;
        y = CGRectGetMaxY(_address.frame);
    }
    
    if (_restaurant.website || _restaurant.mobileMenuURL) {
        BOOL bothItems = (_restaurant.website && _restaurant.mobileMenuURL) ? YES:NO;
        y+=kGeomSpaceInter;
        
        w = (bothItems) ? width(self)/2 : width(self);
        
        if (bothItems) {
            CGFloat trim = 6;
            frame = _verticalLine2.frame;
            frame.origin = CGPointMake(w, y+trim/2);
            frame.size = CGSizeMake(1, height(_website)-trim);
            _verticalLine2.frame = frame;
            x = CGRectGetMaxX(_verticalLine2.frame);
        }
        
        frame = _website.frame;
        frame.origin = CGPointMake(0, y);
        frame.size = CGSizeMake(w, height(_website));
        _website.frame = frame;

        frame = _menuButton.frame;
        frame.origin = CGPointMake((bothItems)?w:0, y);
        frame.size = CGSizeMake(w, height(_menuButton));
        _menuButton.frame = frame;
        
        if (_restaurant.mobileMenuURL) {
            y = CGRectGetMaxY(_menuButton.frame);
        } else if (_restaurant.website) {
            y = CGRectGetMaxY(_website.frame);
        }
    }
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    
    _name.text = _restaurant.name;
    [_name sizeToFit];
    
    _address.text = _restaurant.address;
    [_address sizeToFit];
    
    if ([_restaurant.website length]) {
        [_website withText:@"Website" fontSize:kGeomFontSizeH2 width:0 height:kGeomHeightButton backgroundColor:kColorButtonBackground target:self selector:@selector(goToWebsiteURL)];
        [_website setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        _website.hidden = NO;
    } else {
        [_website setTitle:@"" forState:UIControlStateNormal];
        _website.frame = CGRectZero;
        _website.hidden = YES;
    }

    if ([_restaurant.mobileMenuURL length]) {
        [_menuButton withText:@"Menu" fontSize:kGeomFontSizeH2 width:0 height:kGeomHeightButton backgroundColor:kColorButtonBackground target:self selector:@selector(goToMenuURL)];
        [_menuButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        _menuButton.hidden = NO;
    } else {
        [_menuButton setTitle:@"" forState:UIControlStateNormal];
        _menuButton.frame = CGRectZero;
        _menuButton.hidden = YES;
    }
    _menuButton.layer.cornerRadius = _website.layer.cornerRadius = 0;
    
    _priceRange.text = [_restaurant priceRangeText];
    [_priceRange sizeToFit];
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];
    [_distance sizeToFit];
    
    _cuisine.text = (_restaurant.cuisine) ? [NSString stringWithFormat:@"#%@", _restaurant.cuisine]:@"";
    [_cuisine sizeToFit];
    
    _verticalLine2.hidden = ([_restaurant.mobileMenuURL length] && [_restaurant.website length]) ?NO:YES;
    [self bringSubviewToFront:_verticalLine2];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday] - 1; //because google maps 0-6 and NSDateComponents uses 1-7 grrr
    
    __block HoursOpen *ho = [_restaurant.hours count] ? [_restaurant.hours objectAtIndex:0] : nil;
    [_restaurant.hours enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HoursOpen *h = (HoursOpen *)obj;
        if (h.openDay == weekday) {
            ho = h;
            *stop = YES;
        }
    }];
    
    NSString *hrsButtonText = [ho formattedHoursOpen];
    [_hoursButton setTitle:hrsButtonText forState:UIControlStateNormal];

    _hoursButton.hidden = (hrsButtonText.length) ? NO : YES;
    
    NSMutableString *hrs = [NSMutableString string];
    [_restaurant.hours enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HoursOpen *h = (HoursOpen *)obj;
        [hrs appendFormat:@"%@",[h formattedHoursOpen]];
        if (idx != [_restaurant.hours count]-1) {
            [hrs appendFormat:@"\n"];
        }
    }];
    _hoursView.text = hrs;
    
    [self setNeedsLayout];
}

- (void)doCuisineSearch:(id)sender
{
    [_delegate restaurantMainCVCell:self showListSearchingKeywords:@[_restaurant.cuisine]];
}

- (void)prepareForReuse {
}

- (void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    
    if (!_mediaItemObject) {
        _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
        //[self setNeedsUpdateConstraints];
        [self setNeedsLayout];
        return;
    }
    OOAPI *api = [[OOAPI alloc] init];

    __weak UIImageView *weakIV = _backgroundImage;
    __weak RestaurantMainCVCell *weakSelf = self;
    
    _requestOperation = [api getRestaurantImageWithMediaItem:mediaItemObject maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_backgroundImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                    placeholderImage:nil
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                 weakIV.image = [UIImageEffects imageByApplyingBlurToImage:image withRadius:10 tintColor:[UIColor colorWithWhite:0 alpha:0.4] saturationDeltaFactor:0.7 maskImage:nil];
                                                 
                                                 ON_MAIN_THREAD(^ {
                                                     [weakSelf setNeedsLayout];
                                                 });
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 ON_MAIN_THREAD(^ {
                                                     weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
                                                     [weakSelf setNeedsLayout];
                                                 });
                                             }];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ON_MAIN_THREAD(^ {
            weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
            [weakSelf setNeedsLayout];
        });
    }];
}

@end
