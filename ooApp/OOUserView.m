//
//  OOUserView.m
//  ooApp
//
//  Created by Anuj Gujar on 11/19/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOUserView.h"
#import "OOAPI.h"
#import "DebugUtilities.h"

@interface OOUserView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *viewHalo;
@property (nonatomic, strong) UIImageView *ivFoodie;
@property (nonatomic, strong) UILabel *emptyUserView;
@property (nonatomic, strong) UILabel *circle;
@property (nonatomic, strong) UIButton *buttonSettings, *buttonSettingsInner;
@property (nonatomic, assign) BOOL isFoodie;
@property (nonatomic, assign) BOOL showCog;
@end

@implementation OOUserView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds= NO;
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds= YES;
        
        _emptyUserView = [[UILabel alloc] init];
        [_emptyUserView withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH1] textColor:kColorWhite backgroundColor:kColorGrayMiddle];
        _emptyUserView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emptyUserView];
        _emptyUserView.clipsToBounds= YES;
        
        _ivFoodie = makeImageView(self,  nil);
        _ivFoodie.contentMode = UIViewContentModeScaleAspectFit;
        _ivFoodie.clipsToBounds = NO;
        
        _viewHalo= makeView(self, UIColorRGBA(kColorClear));
        addBorder(_viewHalo, 1.5, UIColorRGBA(kColorTextActive));
        _viewHalo.userInteractionEnabled=NO;
        
        _buttonSettings = makeIconButton(self, kFontIconSettingsFilled, kGeomFontSizeH1, UIColorRGBA(kColorTextActive), UIColorRGBA(kColorClear), self, @selector(userPressedSettings:) , 0);
        _buttonSettingsInner = makeIconButton(self, kFontIconSettings, kGeomFontSizeH1, UIColorRGBA(kColorTextReverse), UIColorRGBA(kColorClear), self, @selector(userPressedSettings:) , 0);
        _buttonSettingsInner.frame = CGRectMake(0,0,100,100);
        _buttonSettingsInner.hidden = NO;
        
        _circle = [[UILabel alloc] init];
        [_circle withFont:[UIFont fontWithName:kFontIcons size:kGeomFontSizeH3] textColor:kColorBackgroundTheme backgroundColor:kColorClear];
        _circle.text = kFontIconFilledCircle;
        _circle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_circle];
        
        //[DebugUtilities addBorderToViews:@[_buttonSettings, _circle, _emptyUserView, self]];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // If the hitView is THIS view, return the view that you want to receive the touch instead:
    if (hitView == self) {
        return hitView;
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView;
}

//- (void)updateConstraints {
//    [super updateConstraints];
//    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButton)};
//    
//    UIView *superview = self;
//    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _imageView, _emptyUserView);
//    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyUserView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyUserView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    
//    _imageView.layer.cornerRadius = width(_imageView)/2;
//    _imageView.layer.borderColor = UIColorRGBA(kColorWhite).CGColor;
//    _imageView.layer.borderWidth = 0;
//}

- (void)setIsFoodie
{
    _isFoodie = YES;
    _ivFoodie.image = [UIImage imageNamed:@"FoodieBubble.png"];
    _viewHalo.hidden = YES;
//    [self sendSubviewToBack:_ivFoodie];
    [self setNeedsLayout];
}

- (void)setShowCog
{
    _showCog = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = width(self);
    CGFloat h = height(self);
    
    [_emptyUserView sizeToFit];
    if (CGRectGetWidth(_emptyUserView.frame) > 0.5*w) {
        _emptyUserView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH3];
    }
    _emptyUserView.frame = self.bounds;
    _imageView.frame = self.bounds;
    _viewHalo.frame = self.bounds;
    _ivFoodie.frame = self.bounds;

    _viewHalo.layer.cornerRadius = w/2;
    _emptyUserView.layer.cornerRadius = w/2;
    _imageView.layer.cornerRadius = w/2;

    const float buttonSettingsSize = _showCog ? kGeomProfileSettingsBadgeSize:0;
    
    _buttonSettings.frame = CGRectMake(w-buttonSettingsSize,
                                       6+h-buttonSettingsSize,
                                       buttonSettingsSize,
                                       buttonSettingsSize);
    _buttonSettingsInner.frame = _buttonSettings.frame;
    CGRect frame = _buttonSettings.frame;
    frame.origin.y -=1;
    _circle.frame = frame;
}

- (void)setUser:(UserObject *)user
{
    if (_user == user) return;
    _user = user;
    
    NSString *first = _user.firstName.length? [_user.firstName substringToIndex:1] : @"";
    NSString *last =_user.lastName.length? [_user.lastName substringToIndex:1] : @"";
    NSString *initials = [NSString stringWithFormat:@"%@%@",  first, last];
    _emptyUserView.text = initials;
    UIImage *image = nil;
    __weak OOUserView *weakSelf = self;
    __weak UIImageView *weakIV = _imageView;
    
    if (_user.mediaItem) {
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantImageWithMediaItem:_user.mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            [weakIV setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                              placeholderImage:nil
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 weakIV.image = image;
                                                 [weakIV setAlpha:1.0];
                                                 weakSelf.emptyUserView.alpha = 0;
                                                 if (user.isFoodie) {
                                                     [weakSelf setIsFoodie];
                                                 }
                                             });
                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                               [weakSelf displayEmptyView:YES];
                                                 if (user.isFoodie) {
                                                     [weakSelf setIsFoodie];
                                                 }
                                             });
                                       }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf displayEmptyView:YES];
                
                if (user.isFoodie) {
                    [weakSelf setIsFoodie];
                }
            });
        }];
    } else if (( image= [_user userProfilePhoto]) ) {
        // NOTE: This would have been fetched from Facebook when the app started.
        _imageView.image = image;
        
        if (user.isFoodie) {
            [self setIsFoodie];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf displayEmptyView:YES];
            
            if (user.isFoodie) {
                [weakSelf setIsFoodie];
            }
        });
    }
}

- (void)displayEmptyView:(BOOL)displayIt {
    if (displayIt) {
        _imageView.alpha = 0;
        
        _emptyUserView.alpha = 1;
        [self setNeedsLayout];
    }
}

- (void)clear;
{
    _imageView.image = nil;
    _user = nil;
    _ivFoodie.image = nil;
    _viewHalo.hidden = NO;
    _isFoodie = NO;
    _showCog = NO;
}

- (void)userPressedSettings:(id)sender {
    [self userTapped];
}

- (void)userTapped {
    if ([_delegate respondsToSelector:@selector(oOUserViewTapped:forUser:)]) {
        [_delegate oOUserViewTapped:self forUser:_user];
    }
}

- (void)setDelegate:(id<OOUserViewDelegate>)delegate {
    if (_delegate == delegate) return;
    _delegate = delegate;
   [self addTarget:self action:@selector(userTapped) forControlEvents:UIControlEventTouchUpInside]; 
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
