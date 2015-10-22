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
@property (nonatomic, strong) UIImageView *backgroundImage;

@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *toTryButton;

@end

@implementation RestaurantMainCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
        [self addSubview:_backgroundImage];
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _verticalLine1 = [[UIView alloc] init];
        [self addSubview:_verticalLine1];
        
        _verticalLine2 = [[UIView alloc] init];
        [self addSubview:_verticalLine2];
        
        _verticalLine1.backgroundColor = UIColorRGBA(kColorWhite);
        _verticalLine2.backgroundColor = UIColorRGBA(kColorWhite);
        _verticalLine1.translatesAutoresizingMaskIntoConstraints = NO;
        _verticalLine2.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        
//        [DebugUtilities addBorderToViews:@[_verticalLine1, _verticalLine2, _priceRange, _name, _address, _website, _phoneNumber, _distance]];
    }
    return self;
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
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"spaceInterX2": @(2*kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _verticalLine1, _verticalLine2, _priceRange, _name, _address, _website, _phoneNumber, _distance, _backgroundImage);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_name]-[_distance]-[_address]-[_phoneNumber]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_backgroundImage]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_name]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_distance]-spaceInter-[_verticalLine2(1)]-spaceInter-[_priceRange]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_phoneNumber]-[_verticalLine1(1)]-[_website]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceInterX2-[_address]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_distance
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_priceRange
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];

    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine1
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_phoneNumber
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];

    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine2
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:_priceRange
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1
                         constant:0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_verticalLine1
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
                         constraintWithItem:_verticalLine2
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_priceRange
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
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
    } else if (_restaurant.priceRange > 1) {
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
    
    [self updateConstraintsIfNeeded];
}


-(void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    OOAPI *api = [[OOAPI alloc] init];
    
//    NSString *imageRef = mediaItemObject.reference;
//
//    if (imageRef) {
//        _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_iv setImageWithURL:[NSURL URLWithString:link]];
//                [self setNeedsUpdateConstraints];
//            });
//        } failure:^(NSError *error) {
//            ;
//        }];
//    } else {
//        
//    }
}



@end
