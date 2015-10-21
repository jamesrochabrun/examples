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

@interface RestaurantMainCVCell()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) TTTAttributedLabel *phoneNumber;
@property (nonatomic, strong) TTTAttributedLabel *website;
@property (nonatomic, strong) TTTAttributedLabel *address;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *priceRange;
@property (nonatomic, strong) UILabel *isOpen;
@property (nonatomic, strong) UILabel *distance;

@end

@implementation RestaurantMainCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _name = [[UILabel alloc] init];
        _name.translatesAutoresizingMaskIntoConstraints = NO;
        [_name withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_name];

        _priceRange = [[UILabel alloc] init];
        _priceRange.translatesAutoresizingMaskIntoConstraints = NO;
        [_priceRange withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];
        [self addSubview:_priceRange];
        
        _phoneNumber = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _phoneNumber.delegate = self;
        _phoneNumber.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber;
        [_phoneNumber withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _phoneNumber.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_phoneNumber];

        _website = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_website withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _website.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_website];
        
        _address = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [_address withFont:[UIFont fontWithName:kFontLatoSemiboldItalic size:kGeomFontSizeSubheader] textColor:kColorYellow backgroundColor:kColorClear];
        _address.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_address];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-image.jpg"]];
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
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
}


- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"imageWidth":@(120), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _name, _address, _website, _phoneNumber);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_iv]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_name]-[_phoneNumber]-[_website]-[_address]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_name]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_phoneNumber]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_website]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_address]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    
//    NSLayoutConstraint *constraint = [NSLayoutConstraint
//                                      constraintWithItem:_iv
//                                      attribute:NSLayoutAttributeWidth
//                                      relatedBy:NSLayoutRelationEqual
//                                      toItem:_iv
//                                      attribute:NSLayoutAttributeHeight
//                                      multiplier:1
//                                      constant:0];
//    [self addConstraint:constraint];
}

- (void)setRestaurant:(RestaurantObject *)restaurant {
    if (_restaurant == restaurant) return;
    _restaurant = restaurant;
    
    _name.text = _restaurant.name;
    _address.text = _restaurant.address;
    _website.text = @"Website";
    _phoneNumber.text = _restaurant.phone;
    
    //if (_restaurant.priceRange
    
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
//    [_website addLinkToAddress:
    [_website setLinkAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
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
