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
//@property (nonatomic, strong) UILabel *rating;
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
@property (nonatomic, strong) UIButton *shareButton;
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
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _imageOverlay = [[UIView alloc] init];
        _imageOverlay.backgroundColor = UIColorRGBA(kColorOverlay50);
//        _imageOverlay.alpha = 1;
        [_backgroundImage addSubview:_imageOverlay];
        _imageOverlay.translatesAutoresizingMaskIntoConstraints = NO;
        
        _verticalLine1 = [[UIView alloc] init];
        _verticalLine2 = [[UIView alloc] init];
        [self addSubview:_verticalLine1];
        [self addSubview:_verticalLine2];
        
        _verticalLine1.backgroundColor = _verticalLine2.backgroundColor = UIColorRGBA(kColorWhite);
        _verticalLine1.translatesAutoresizingMaskIntoConstraints =
        _verticalLine2.translatesAutoresizingMaskIntoConstraints = NO;
        
        _hoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hoursButton withText:@"" fontSize:kGeomFontSizeH2 width:100 height:30 backgroundColor:kColorClear target:self selector:@selector(viewHours)];
        [_hoursButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
        _hoursButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_hoursButton setContentEdgeInsets:UIEdgeInsetsMake(0, kGeomSpaceEdge, 0, kGeomSpaceEdge)];
        _hoursButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_hoursButton];

        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton withIcon:kFontIconPin fontSize:kGeomIconSize width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showOnMap)];
        _locationButton.layer.cornerRadius = 0;
        [self addSubview:_locationButton];
        [_locationButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        _locationButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        _hoursScroll = [[UIScrollView alloc] init];
        _hoursScroll.backgroundColor = UIColorRGBA(kColorBlack);
        _hoursScroll.translatesAutoresizingMaskIntoConstraints = NO;
        
        _hoursView = [[UILabel alloc] init];
        _hoursView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
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
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton withIcon:kFontIconShare fontSize:kGeomIconSize width:kGeomDimensionsIconButton height:0 backgroundColor:kColorClear target:self selector:@selector(sharePressed)];
        _shareButton.layer.cornerRadius = 0;
        
        [_shareButton setTitleColor:UIColorRGB(kColorYellow) forState:UIControlStateNormal];
        
        [_favoriteButton setTitleColor:UIColorRGB(kColorYellow) forState:UIControlStateNormal];
        [_favoriteButton setTitle:kFontIconFavoriteFilled forState:UIControlStateSelected];
        
        _favoriteButton.translatesAutoresizingMaskIntoConstraints = _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_favoriteButton];
        [self addSubview:_shareButton];
        
        _locationButton.layer.borderWidth = _favoriteButton.layer.borderWidth = _shareButton.layer.borderWidth = 1;
        _locationButton.layer.borderColor = _favoriteButton.layer.borderColor = _shareButton.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
        
//        _rating = [[UILabel alloc] init];
//        _rating.translatesAutoresizingMaskIntoConstraints = NO;
//        [_rating withFont:[UIFont fontWithName:kFontIcons size:kGeomFontSizeH2] textColor:kColorWhite backgroundColor:kColorClear];
//        [self addSubview:_rating];
        
        _priceRange = [[UILabel alloc] init];
        _priceRange.translatesAutoresizingMaskIntoConstraints = NO;
        [_priceRange withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_priceRange];

        _cuisine = [UIButton buttonWithType:UIButtonTypeCustom];
        _cuisine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_cuisine];

        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_menuButton];
        
        _menuButton.layer.borderWidth = _cuisine.layer.borderWidth = 1;
        _menuButton.layer.borderColor = _cuisine.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
        _menuButton.layer.cornerRadius = _cuisine.layer.cornerRadius = 0;
        
        _distance = [[UILabel alloc] init];
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        [_distance withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorWhite backgroundColor:kColorClear];
        _distance.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_distance];
        
        _phoneNumber = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _phoneNumber.delegate = self;
        _phoneNumber.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber;
        [_phoneNumber withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorYellow backgroundColor:kColorClear];
        _phoneNumber.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_phoneNumber];

        _website = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_website withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorYellow backgroundColor:kColorClear];
        _website.translatesAutoresizingMaskIntoConstraints = NO;
        _website.delegate = self;
        [self addSubview:_website];
        
        _address = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_address withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2] textColor:kColorWhite backgroundColor:kColorClear];
        _address.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_address];
        self.backgroundColor = UIColorRGBA(kColorWhite);
        
        _hoursScroll.layer.borderColor = _hoursButton.layer.borderColor = UIColorRGBA(kColorGray).CGColor;
        _hoursScroll.layer.borderWidth = _hoursButton.layer.borderWidth = 1;
        _hoursScroll.hidden = YES;
        [self addSubview:_hoursScroll]; //should appear above everything
        
        self.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
//        [DebugUtilities addBorderToViews:@[_phoneNumber, _website, _verticalLine2]];
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

- (void)sharePressed {
    [_delegate restaurantMainCVCellSharePressed];
}

- (void)showOnMap {
    [_delegate restaurantMainCVCell:self showMapTapped:_restaurant.location];
}

- (void)listButtonTapped:(id)sender {
    if (sender == _favoriteButton) {
        [_delegate restaurantMainCVCell:self listButtonTapped:kListTypeFavorites];
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
        messageWithTitle (@"Alert", @"Your device doesn't support this feature.");// Uses UIAlertController.
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [_delegate restaurantMainCVCell:self gotoURL:url];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter":@(kGeomSpaceInter), @"spaceInterX2":@(2*kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"iconButtonDimensions":@(kGeomDimensionsIconButton), @"actionButtonWidth":@((width(self)- 2*kGeomSpaceInter)/3)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _verticalLine1, _verticalLine2, _priceRange, /*_rating,*/ _address, _website, _phoneNumber, _distance, _cuisine, _shareButton, _favoriteButton, _backgroundImage, _locationButton, _hoursButton, _hoursView, _hoursScroll, _imageOverlay, _menuButton);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageOverlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_backgroundImage]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageOverlay]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    UIView *centerView, *lastLineView, *currentLine;
    
    //1st line
    if ([_priceRange.text length] && [_distance.text length]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_priceRange]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_priceRange]-spaceInter-[_verticalLine1(1)]-spaceInter-[_distance]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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
        currentLine = _priceRange;
        centerView = _verticalLine1;
    } else if ([_priceRange.text length]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_priceRange]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_priceRange]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        currentLine = _priceRange;
        centerView = _priceRange;
    } else if ([_distance.text length]) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_distance]-(>=0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_distance]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        currentLine = _distance;
        centerView = _distance;
    }
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:currentLine
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:nil
                         attribute:0
                         multiplier:1
                         constant:30]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:centerView
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];

    //line 2 hour button
    lastLineView = currentLine;
    currentLine = _hoursButton;
    
    //hours button
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_hoursButton
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
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
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:currentLine
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:lastLineView
                         attribute:NSLayoutAttributeBottom
                         multiplier:1
                         constant:0]];

    //line 3 address
    lastLineView = currentLine;
    currentLine = _address;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceInterX2)-[_address]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:currentLine
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:nil
                         attribute:0
                         multiplier:1
                         constant:30]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_address
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1
                         constant:0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:currentLine
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:lastLineView
                         attribute:NSLayoutAttributeBottom
                         multiplier:1
                         constant:0]];
    
    //4th line phone/website
    lastLineView = currentLine;
    centerView = nil;
    currentLine = nil;

    if ([_phoneNumber.text length] && [_website.text length]) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_phoneNumber
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:_verticalLine2
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1
                             constant:0]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_website
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:_verticalLine2
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
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceInterX2)-[_phoneNumber]-[_verticalLine2(1)]-[_website]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        currentLine = _phoneNumber;
        centerView = _verticalLine2;
    } else if ([_phoneNumber.text length]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceInterX2)-[_phoneNumber]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        currentLine = _phoneNumber;
        centerView = _phoneNumber;
    } else if ([_website.text length]) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=spaceInterX2)-[_website]-(>=spaceInterX2)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        currentLine = _website;
        centerView = _website;
    } else {
        
    }
    if (currentLine) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:lastLineView
                             attribute:NSLayoutAttributeBottom
                             relatedBy:NSLayoutRelationEqual
                             toItem:currentLine
                             attribute:NSLayoutAttributeTop
                             multiplier:1
                             constant:0]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:centerView
                             attribute:NSLayoutAttributeCenterX
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterX
                             multiplier:1
                             constant:0]];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_hoursButton(25)][_hoursScroll]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hoursView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hoursView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_locationButton][_shareButton(actionButtonWidth)][_favoriteButton]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    lastLineView = currentLine;
    
    //line 5 cuisine/menu
    if (!_restaurant.cuisine && !_restaurant.mobileMenuURL) {
        
    } else if (_restaurant.cuisine && !_restaurant.mobileMenuURL) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cuisine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kGeomDimensionsIconButton]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_cuisine]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cuisine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_locationButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        currentLine = _cuisine;
        centerView = _cuisine;
    } else if (!_restaurant.cuisine && _restaurant.mobileMenuURL) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_menuButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kGeomDimensionsIconButton]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_menuButton]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_menuButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_locationButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        currentLine = _menuButton;
        centerView = _menuButton;
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spaceEdge)-[_cuisine][_menuButton]-(spaceEdge)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cuisine attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_menuButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cuisine attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_menuButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_menuButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kGeomDimensionsIconButton]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cuisine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kGeomDimensionsIconButton]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cuisine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_locationButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        currentLine = _verticalLine2;
        centerView = _verticalLine2;
    }
    
//    if (centerView) {
//        [self addConstraint:[NSLayoutConstraint
//                             constraintWithItem:currentLine
//                             attribute:NSLayoutAttributeTop
//                             relatedBy:NSLayoutRelationEqual
//                             toItem:lastLineView
//                             attribute:NSLayoutAttributeBottom
//                             multiplier:1
//                             constant:0]];
//    }
    
    //line 6 location/share/favorite
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_shareButton
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
                         constraintWithItem:_shareButton
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
                         constraintWithItem:_shareButton
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:_locationButton
                         attribute:NSLayoutAttributeHeight
                         multiplier:1
                         constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_locationButton(iconButtonDimensions)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
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
    
//    _rating.text = @"JJJ";// (![_rating.text length]) ? [_restaurant ratingText] : _rating.text; //Not a fan of this, but the repsonse by getting the rest through place_id does not seem to be returning the rating
//    NSLog(@"rating=%@", _rating.text);
    _address.text = _restaurant.address;
    _phoneNumber.text = _restaurant.phone;
    
    if (_restaurant.cuisine) {
        [_cuisine withText:[NSString stringWithFormat:@"#%@", _restaurant.cuisine] fontSize:kGeomFontSizeH2 width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(doCuisineSearch:)];
        _cuisine.hidden = NO;
    } else {
        [_cuisine setTitle:@"" forState:UIControlStateNormal];
        _cuisine.hidden = YES;
    }
    [_cuisine setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
    [_cuisine sizeToFit];

    if (_restaurant.mobileMenuURL) {
        [_menuButton withText:@"Menu" fontSize:kGeomFontSizeH2 width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(goToMenuURL)];
        [_menuButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        [_menuButton sizeToFit];
        _menuButton.hidden = NO;
    } else {
        [_menuButton setTitle:@"" forState:UIControlStateNormal];
        _menuButton.frame = CGRectZero;
        _menuButton.hidden = YES;
    }
    
    _priceRange.text = [_restaurant priceRangeText];
    
    CLLocationCoordinate2D loc = [[LocationManager sharedInstance] currentUserLocation];
    
    CLLocation *locationA = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    CLLocation *locationB = [[CLLocation alloc] initWithLatitude:restaurant.location.latitude longitude:restaurant.location.longitude];
    
    CLLocationDistance distanceInMeters = [locationA distanceFromLocation:locationB];
    _distance.text = [NSString stringWithFormat:@"%0.1f mi.", metersToMiles(distanceInMeters)];

    
    NSRange range;
    range = [_restaurant.phone rangeOfString:_restaurant.phone];
    _phoneNumber.linkAttributes = @{NSFontAttributeName : [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2], NSForegroundColorAttributeName : UIColorRGBA(kColorYellow)};
    [_phoneNumber addLinkToPhoneNumber:_restaurant.phone withRange:range];

    if (_restaurant.website) {
        _website.text = @"Website";
        range = [_website.text rangeOfString:_website.text];
        [_website setLinkAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeH2], NSFontAttributeName,
                                         UIColorRGBA(kColorYellow), NSForegroundColorAttributeName,
                                         nil]];
        [_website addLinkToURL:[NSURL URLWithString:_restaurant.website] withRange:range];
//        _verticalLine2.hidden = _website.hidden = NO;
    } else {
        _website.text = @"";
//        _verticalLine2.hidden = _website.hidden = YES;
    }
    
    [_website sizeToFit];
    [_phoneNumber sizeToFit];
    
    _verticalLine2.hidden = (_website.text && _phoneNumber.text) ? NO : YES;

    
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
    
    [self needsUpdateConstraints];
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
