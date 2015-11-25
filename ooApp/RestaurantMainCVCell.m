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

@interface RestaurantMainCVCell()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) TTTAttributedLabel *phoneNumber;
@property (nonatomic, strong) TTTAttributedLabel *website;
@property (nonatomic, strong) TTTAttributedLabel *address;
//@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *priceRange;
@property (nonatomic, strong) UILabel *isOpen;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UIButton *cuisine;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *imageOverlay;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *hoursButton;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *toTryButton;
@property (nonatomic, strong) UILabel *rating;
@property (nonatomic, strong) UIScrollView *hoursScroll;
@property (nonatomic, strong) UILabel *hoursView;
@property (nonatomic, strong) UIView *verticalLine1;
@property (nonatomic, strong) UIView *verticalLine2;
@property (nonatomic, strong) UIView *verticalLine3;
@property (nonatomic, strong) UIView *verticalLine4;

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
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _imageOverlay = [[UIView alloc] init];
        _imageOverlay.backgroundColor = UIColorRGBA(kColorOverlay50);
//        _imageOverlay.alpha = 1;
        [_backgroundImage addSubview:_imageOverlay];
        _imageOverlay.translatesAutoresizingMaskIntoConstraints = NO;
        
        _verticalLine1 = [[UIView alloc] init];
        _verticalLine2 = [[UIView alloc] init];
        _verticalLine3 = [[UIView alloc] init];
        _verticalLine4 = [[UIView alloc] init];
        [self addSubview:_verticalLine1];
        [self addSubview:_verticalLine2];
        [self addSubview:_verticalLine3];
        [self addSubview:_verticalLine4];
        
        _verticalLine1.backgroundColor = _verticalLine2.backgroundColor = UIColorRGBA(kColorWhite);
        _verticalLine3.backgroundColor = _verticalLine4.backgroundColor = UIColorRGBA(kColorWhite);
        _verticalLine1.translatesAutoresizingMaskIntoConstraints =
        _verticalLine2.translatesAutoresizingMaskIntoConstraints =
        _verticalLine3.translatesAutoresizingMaskIntoConstraints =
        _verticalLine4.translatesAutoresizingMaskIntoConstraints = NO;
        
        _hoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hoursButton withText:@"" fontSize:kGeomFontSizeDetail width:100 height:30 backgroundColor:kColorClear target:self selector:@selector(viewHours)];
        [_hoursButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
        _hoursButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_hoursButton setContentEdgeInsets:UIEdgeInsetsMake(0, kGeomSpaceEdge, 0, kGeomSpaceEdge)];
        _hoursButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_hoursButton];

        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton withIcon:kFontIconLocation fontSize:kGeomIconSize width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showOnMap)];
        _locationButton.layer.cornerRadius = 0;
        [self addSubview:_locationButton];
        [_locationButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        _locationButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        _hoursScroll = [[UIScrollView alloc] init];
        _hoursScroll.backgroundColor = UIColorRGBA(kColorBlack);
        _hoursScroll.translatesAutoresizingMaskIntoConstraints = NO;
        
        _hoursView = [[UILabel alloc] init];
        _hoursView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail];
        _hoursView.textColor = UIColorRGBA(kColorWhite);
        _hoursView.backgroundColor = UIColorRGBA(kColorBlack);
        _hoursView.numberOfLines = 0;
        _hoursView.lineBreakMode = NSLineBreakByWordWrapping;
        _hoursView.textAlignment = NSTextAlignmentCenter;
        [_hoursScroll addSubview:_hoursView];
        _hoursView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favoriteButton withIcon:kFontIconFavorite fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:0 backgroundColor:kColorClear target:self selector:@selector(listButtonTapped:)];
        _favoriteButton.layer.cornerRadius = 0;
        
        _toTryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toTryButton withIcon:kFontIconToTry fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:0 backgroundColor:kColorClear target:self selector:@selector(listButtonTapped:)];
        _toTryButton.layer.cornerRadius = 0;
        
        [_toTryButton setTitleColor:UIColorRGB(kColorYellow) forState:UIControlStateNormal];
        [_favoriteButton setTitleColor:UIColorRGB(kColorYellow) forState:UIControlStateNormal];
        [_toTryButton setTitle:kFontIconToTryFilled forState:UIControlStateSelected];
        [_favoriteButton setTitle:kFontIconFavoriteFilled forState:UIControlStateSelected];
        
        _favoriteButton.translatesAutoresizingMaskIntoConstraints = _toTryButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_favoriteButton];
        [self addSubview:_toTryButton];
        
        _locationButton.layer.borderWidth = _favoriteButton.layer.borderWidth = _toTryButton.layer.borderWidth = 1;
        _locationButton.layer.borderColor = _favoriteButton.layer.borderColor = _toTryButton.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
        
//        _name = [[UILabel alloc] init];
//        _name.translatesAutoresizingMaskIntoConstraints = NO;
//        [_name withFont:[UIFont fontWithName:kFontLatoHeavy size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
//        [self addSubview:_name];
        
        _priceRange = [[UILabel alloc] init];
        _priceRange.translatesAutoresizingMaskIntoConstraints = NO;
        [_priceRange withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_priceRange];

        _cuisine = [UIButton buttonWithType:UIButtonTypeCustom];
        _cuisine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_cuisine];

        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_menuButton];

        _distance = [[UILabel alloc] init];
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear];
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_distance];
        
        _phoneNumber = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _phoneNumber.delegate = self;
        _phoneNumber.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber;
        [_phoneNumber withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _phoneNumber.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_phoneNumber];

        _website = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_website withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _website.translatesAutoresizingMaskIntoConstraints = NO;
        _website.delegate = self;
        [self addSubview:_website];
        
        _address = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_address withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear];
        _address.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_address];
        self.backgroundColor = UIColorRGBA(kColorWhite);
        
        _hoursScroll.layer.borderColor = _hoursButton.layer.borderColor = UIColorRGBA(kColorGray).CGColor;
        _hoursScroll.layer.borderWidth = _hoursButton.layer.borderWidth = 1;
        _hoursScroll.hidden = YES;
        [self addSubview:_hoursScroll]; //should appear above everything
        
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
//        [DebugUtilities addBorderToViews:@[_cuisine, _menuButton]];
    }
    return self;
}

- (void)viewHours {
    _hoursScroll.hidden = !_hoursScroll.hidden;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)goToMenuURL {
    NSURL *url = [NSURL URLWithString:_restaurant.mobileMenuURL];
    [_delegate restaurantMainCVCell:self gotoURL:url];
}

- (void)showOnMap {
    [_delegate restaurantMainCVCell:self showMapTapped:_restaurant.location];
}

- (void)listButtonTapped:(id)sender {
    if (sender == _favoriteButton) {
        [_delegate restaurantMainCVCell:self listButtonTapped:kListTypeFavorites];
    } else if (sender == _toTryButton) {
        [_delegate restaurantMainCVCell:self listButtonTapped:kListTypeToTry];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
        
        NSString *num = [@"telprompt://" stringByAppendingString:phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    } else {
        UIAlertView *notPermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notPermitted show];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [_delegate restaurantMainCVCell:self gotoURL:url];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter":@(kGeomSpaceInter), @"spaceInterX2":@(2*kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"iconButtonDimensions":@(kGeomDimensionsIconButton), @"actionButtonWidth":@((width(self)- 2*kGeomSpaceInter)/3)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _verticalLine1, _verticalLine2, _verticalLine3, _verticalLine4, _priceRange,/* _name*/ _address, _website, _phoneNumber, _distance, _cuisine, _toTryButton, _favoriteButton, _backgroundImage, _locationButton, _hoursButton, _hoursView, _hoursScroll, _imageOverlay, _menuButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageOverlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_backgroundImage]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageOverlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_verticalLine3]-[_priceRange]-(spaceInter)-[_hoursButton]-(spaceInter)-[_address]-[_phoneNumber]-[_locationButton(iconButtonDimensions)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_hoursButton(25)][_hoursScroll]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hoursView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hoursView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_locationButton][_favoriteButton(actionButtonWidth)][_toTryButton]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_priceRange]-spaceInter-[_verticalLine1(1)]-spaceInter-[_distance]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceInterX2)-[_phoneNumber]-[_verticalLine2(1)]-[_website]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceInterX2)-[_address]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    
    //name line
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_favoriteButton
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_favoriteButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_locationButton
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_toTryButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_locationButton
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_favoriteButton
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_locationButton
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_toTryButton
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_locationButton
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
    
    if (!_restaurant.cuisine && !_restaurant.mobileMenuURL) {
        
    } else if (_restaurant.cuisine && !_restaurant.mobileMenuURL) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_cuisine]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_cuisine
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];
    } else if (!_restaurant.cuisine && _restaurant.mobileMenuURL) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_menuButton]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_menuButton
                             attribute:NSLayoutAttributeCenterX
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterX
                             multiplier:1
                             constant:0]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_cuisine]-(spaceInter)-[_verticalLine3(1)]-(spaceInter)-[_menuButton]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_cuisine
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:_verticalLine3
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1
                             constant:0]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_menuButton
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:_verticalLine3
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1
                             constant:0]];

        
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_verticalLine3
                             attribute:NSLayoutAttributeCenterX
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterX
                             multiplier:1
                             constant:0]];
    }
    
    //distance line
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine1
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine1
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_distance
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine1
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_distance
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_priceRange
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_distance
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
//hours button
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_hoursButton
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];


    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_address
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];

    //phone number line
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine2
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine2
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_phoneNumber
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine2
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_phoneNumber
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_website
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_phoneNumber
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];

    //Hours button stuff
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_hoursScroll
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem:_hoursButton
                         attribute:NSLayoutAttributeLeft
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_hoursScroll
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:_hoursButton
                         attribute:NSLayoutAttributeWidth
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_hoursView
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:_hoursScroll
                         attribute:NSLayoutAttributeWidth
                         multiplier:1
                         constant:0]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize s = [_hoursView.text sizeWithAttributes:@{NSFontAttributeName:_hoursView.font}];
    _hoursScroll.contentSize = CGSizeMake(width(_hoursScroll), s.height);
    
    [self setNeedsUpdateConstraints];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    
//    _name.text = _restaurant.name;
    _address.text = _restaurant.address;
    _website.text = @"Website";
    _phoneNumber.text = _restaurant.phone;
    
    if (_restaurant.cuisine) {
        [_cuisine withText:[NSString stringWithFormat:@"#%@", _restaurant.cuisine] fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(doCuisineSearch:)];
    } else {
        [_cuisine setTitle:@"" forState:UIControlStateNormal];
    }
    [_cuisine setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];

    if (_restaurant.mobileMenuURL) {
        [_menuButton withText:@"Menu" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(goToMenuURL)];
    } else {
        [_menuButton setTitle:@"" forState:UIControlStateNormal];
    }
    [_menuButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];

    _priceRange.text = [_restaurant priceRangeText];
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];

    
    NSRange range;
    range = [_restaurant.phone rangeOfString:_restaurant.phone];
    _phoneNumber.linkAttributes = @{NSFontAttributeName : [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader], NSForegroundColorAttributeName : UIColorRGBA(kColorYellow)};
    [_phoneNumber addLinkToPhoneNumber:_restaurant.phone withRange:range];

    range = [_website.text rangeOfString:_website.text];
    [_website setLinkAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader], NSFontAttributeName,
                                     UIColorRGBA(kColorYellow), NSForegroundColorAttributeName,
                                     nil]];
    [_website addLinkToURL:[NSURL URLWithString:_restaurant.website] withRange:range];

    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
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
    
    [self updateConstraintsIfNeeded];
}

- (void)setToTry:(BOOL)on {
    [_toTryButton setSelected:on];
}

- (void)setFavorite:(BOOL)on {
    [_favoriteButton setSelected:on];
}

- (void)doCuisineSearch:(id)sender {
    [_delegate restaurantMainCVCell:self showListSearchingKeywords:@[_restaurant.cuisine]];
}

- (void)prepareForReuse {
}

- (void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    
    if (!_mediaItemObject) {
        _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
        [self setNeedsUpdateConstraints];
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
//                                                     weakIV.image = image;
                                                     
                                                     [weakSelf setNeedsUpdateConstraints];
                                                     [weakSelf setNeedsLayout];
                                                 });
                                             }
                                             failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 ON_MAIN_THREAD(^ {
                                                     weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
                                                     [weakSelf setNeedsUpdateConstraints];
                                                     [weakSelf setNeedsLayout];
                                                 });
                                             }];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ON_MAIN_THREAD(^ {
            weakIV.image = [UIImage imageNamed:@"background-image.jpg"];
            [weakSelf setNeedsUpdateConstraints];
            [weakSelf setNeedsLayout];
        });
    }];
}

@end
