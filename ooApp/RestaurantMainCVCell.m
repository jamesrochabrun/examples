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

@interface RestaurantMainCVCell()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) TTTAttributedLabel *phoneNumber;
@property (nonatomic, strong) TTTAttributedLabel *website;
@property (nonatomic, strong) TTTAttributedLabel *address;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *priceRange;
@property (nonatomic, strong) UILabel *isOpen;
@property (nonatomic, strong) UILabel *distance;
@property (nonatomic, strong) UIView *verticalLine1;
@property (nonatomic, strong) UIView *verticalLine2;
@property (nonatomic, strong) UIView *verticalLine3;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *imageOverlay;
@property (nonatomic, strong) UIButton *hoursButton;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *toTryButton;
@property (nonatomic, strong) UILabel *rating;
@property (nonatomic, strong) UIScrollView *hoursScroll;
@property (nonatomic, strong) UILabel *hoursView;
@property (nonatomic, strong) UIView *horizontalLine1;
@property (nonatomic) CGFloat hoursViewWidth;

@end

@implementation RestaurantMainCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImage.image = nil;// [UIImage imageNamed:@"background-image.jpg"];
        _backgroundImage.clipsToBounds = YES;
        [self addSubview:_backgroundImage];
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _imageOverlay = [[UIView alloc] init];
        _imageOverlay.backgroundColor = UIColorRGBA(kColorOverlay35);
        [_backgroundImage addSubview:_imageOverlay];
        _imageOverlay.translatesAutoresizingMaskIntoConstraints = NO;

        _verticalLine1 = [[UIView alloc] init];
        _verticalLine2 = [[UIView alloc] init];
        _verticalLine3 = [[UIView alloc] init];
        [self addSubview:_verticalLine1];
        [self addSubview:_verticalLine2];
        [self addSubview:_verticalLine3];
        
        _verticalLine1.backgroundColor = _verticalLine2.backgroundColor = _verticalLine3.backgroundColor = UIColorRGBA(kColorWhite);
        _verticalLine1.translatesAutoresizingMaskIntoConstraints = _verticalLine2.translatesAutoresizingMaskIntoConstraints = _verticalLine3.translatesAutoresizingMaskIntoConstraints = NO;

        _hoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hoursButton withText:@"" fontSize:kGeomFontSizeDetail width:100 height:30 backgroundColor:kColorClear target:self selector:@selector(viewHours)];
        [_hoursButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
        _hoursButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _hoursButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_hoursButton];
        
        
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
        [_favoriteButton withIcon:kFontIconFavorite fontSize:kGeomIconSize width:kGeomWidthMenuButton height:0 backgroundColor:kColorClear target:self selector:@selector(listButtonTapped:)];
        
        _toTryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toTryButton withIcon:kFontIconToTry fontSize:kGeomIconSize width:kGeomWidthMenuButton height:0 backgroundColor:kColorClear target:self selector:@selector(listButtonTapped:)];
        
        [_toTryButton setTitleColor:UIColorRGB(kColorYellow) forState:UIControlStateNormal];
        [_favoriteButton setTitleColor:UIColorRGB(kColorYellow) forState:UIControlStateNormal];
        [_toTryButton setTitle:kFontIconToTryFilled forState:UIControlStateSelected];
        [_favoriteButton setTitle:kFontIconFavoriteFilled forState:UIControlStateSelected];
        
        _favoriteButton.translatesAutoresizingMaskIntoConstraints = _toTryButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_favoriteButton];
        [self addSubview:_toTryButton];
        
        _name = [[UILabel alloc] init];
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        [_name withFont:[UIFont fontWithName:kFontLatoHeavyItalic size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_name];
        
        _priceRange = [[UILabel alloc] init];
        _priceRange.translatesAutoresizingMaskIntoConstraints = NO;
        [_priceRange withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_priceRange];
        
        _distance = [[UILabel alloc] init];
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_distance];
        
        _phoneNumber = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _phoneNumber.delegate = self;
        _phoneNumber.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber;
        [_phoneNumber withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _phoneNumber.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_phoneNumber];

        _website = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_website withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _website.translatesAutoresizingMaskIntoConstraints = NO;
        _website.delegate = self;
        [self addSubview:_website];
        
        _address = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_address withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _address.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_address];
        self.backgroundColor = UIColorRGBA(kColorWhite);
        
        _hoursScroll.layer.borderColor = _hoursButton.layer.borderColor = UIColorRGBA(kColorGray).CGColor;
        _hoursScroll.layer.borderWidth = _hoursButton.layer.borderWidth = 1;
        _hoursScroll.hidden = YES;
        [self addSubview:_hoursScroll]; //should appear above everything
        
        _horizontalLine1 = [[UIView alloc] init];
        [self addSubview:_horizontalLine1];
        _horizontalLine1.translatesAutoresizingMaskIntoConstraints = NO;
        
//        [DebugUtilities addBorderToViews:@[_hoursView, _hoursScroll]];
    }
    return self;
}

- (void)viewHours {
    _hoursScroll.hidden = !_hoursScroll.hidden;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
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
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"spaceInterX2": @(2*kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"hoursViewWidth" : @(_hoursViewWidth)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _verticalLine1, _verticalLine2, _verticalLine3, _priceRange, _name, _address, _website, _phoneNumber, _distance, _toTryButton, _favoriteButton, _backgroundImage, _hoursButton, _hoursView, _hoursScroll, _imageOverlay, _horizontalLine1);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageOverlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_horizontalLine1]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_backgroundImage]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageOverlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_toTryButton]-[_horizontalLine1(1)]-(spaceInter)-[_hoursButton]-[_address]-[_phoneNumber]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_hoursButton(25)][_hoursScroll]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hoursView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hoursView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_name]-(>=0)-[_toTryButton]-spaceInter-[_favoriteButton]-spaceInterX2-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_distance]-spaceInter-[_verticalLine1(1)]-spaceInter-[_priceRange]-(>=spaceInter)-[_hoursButton]-spaceInterX2-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_phoneNumber]-[_verticalLine2(1)]-[_website]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_address]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    
    //name line
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_favoriteButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_name
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_toTryButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_name
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    
    //distance line
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
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_hoursButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_distance
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];

    //phone number line
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
    _hoursViewWidth = width(_hoursScroll);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0.0)];
    [path addLineToPoint:CGPointMake(width(_backgroundImage), 0.0)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = UIColorRGBA(kColorGray).CGColor;
    shapeLayer.lineWidth = 1;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [_horizontalLine1.layer addSublayer:shapeLayer];

//    NSLog(@"hoursViewWidth=%f", _hoursViewWidth);
    [self setNeedsUpdateConstraints];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    
    _name.text = _restaurant.name;
    _address.text = _restaurant.address;
    _website.text = @"Website";
    _phoneNumber.text = _restaurant.phone;
    
    if (_restaurant.priceRange >= 4) {
        _priceRange.text = @"$$$$$";
    } else if (_restaurant.priceRange >= 3) {
        _priceRange.text = @"$$$$";
    } else if (_restaurant.priceRange >= 2) {
        _priceRange.text = @"$$$";
    } else if (_restaurant.priceRange >= 1) {
        _priceRange.text = @"$$";
    } else {
        _priceRange.text = @"$";
    }
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];

    
    NSRange range;
    
    range = [_phoneNumber.text rangeOfString:_phoneNumber.text];
    [_phoneNumber addLinkToPhoneNumber:_restaurant.phone withRange:range];
    [_phoneNumber setTextColor:UIColorRGBA(kColorYellow)];
    [_phoneNumber setLinkAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader], NSFontAttributeName,
                                    UIColorRGBA(kColorYellow), NSForegroundColorAttributeName,
                                     nil]];

    range = [_website.text rangeOfString:_website.text];
    [_website addLinkToURL:[NSURL URLWithString:_restaurant.website] withRange:range];
    [_website setLinkAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader], NSFontAttributeName,
                                     UIColorRGBA(kColorYellow), NSForegroundColorAttributeName,
                                     nil]];

    range = [_address.text rangeOfString:_address.text];

    [_address setLinkAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader], NSFontAttributeName,
                                 UIColorRGBA(kColorYellow), NSForegroundColorAttributeName,
                                 nil]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    
    [_hoursButton setTitle:[(HoursOpen *)[_restaurant.hours objectAtIndex:weekday] formattedHoursOpen] forState:UIControlStateNormal];
    
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

- (void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    OOAPI *api = [[OOAPI alloc] init];
    
    NSString *imageRef = mediaItemObject.reference;

    if (imageRef) {
        _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_backgroundImage setImageWithURL:[NSURL URLWithString:link]];
                [self setNeedsUpdateConstraints];
            });
        } failure:^(NSError *error) {
            ;
        }];
    } else {
        
    }
}

@end
