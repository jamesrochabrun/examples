//
//  PhotoCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "PhotoCVCell.h"
#import "OOAPI.h"
#import "Settings.h"
#import "DebugUtilities.h"

@interface PhotoCVCell ()

@property (nonatomic, strong) AFHTTPRequestOperation *roGetImage;
@property (nonatomic, strong) AFHTTPRequestOperation *roGetLiked;
@property (nonatomic, strong) AFHTTPRequestOperation *roGetUser;
@property (nonatomic, strong) AFHTTPRequestOperation *roGetNumLikes;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *yumButton;
@property (nonatomic, strong) UILabel *numYums;
@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) NSArray *captionConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageContraint;
@property (nonatomic, strong) UILabel *yumIndicator;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, strong) UILabel *restaurantName;
@property (nonatomic, strong) UILabel *line2;
@property (nonatomic, strong) UILabel *caption;
@end

@implementation PhotoCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImage.clipsToBounds = YES;
        
        _yumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_yumButton withIcon:kFontIconYumOutline fontSize:20 width:25 height:0 backgroundColor:kColorClear target:self selector:@selector(yumPhotoTapped)];
        [_yumButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [_yumButton setTitle:kFontIconYum forState:UIControlStateSelected];
        _yumButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _yumIndicator = [[UILabel alloc] init];
        _yumIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [_yumIndicator withFont:[UIFont fontWithName:kFontIcons size:60] textColor:kColorBackgroundTheme backgroundColor:kColorClear];
        _yumIndicator.text = kFontIconYum;
        [_yumIndicator sizeToFit];
        _yumIndicator.alpha = 0;

        _restaurantName = [UILabel new];
        [_restaurantName withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH2] textColor:kColorText backgroundColor:kColorClear];
        _restaurantName.lineBreakMode = NSLineBreakByTruncatingTail;

        _line2 = [UILabel new];
        [_line2 withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH5] textColor:kColorGrayMiddle backgroundColor:kColorClear];
        _line2.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _caption = [[UILabel alloc] init];
        [_caption withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH5] textColor:kColorGrayMiddle backgroundColor:kColorClear numberOfLines:3 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
//        _caption.translatesAutoresizingMaskIntoConstraints = NO;
        
        _numYums = [[UILabel alloc] init];
        [_numYums withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH6] textColor:kColorTextActive backgroundColor:kColorClear];
        
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userButton withText:@"" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showProfile)];
        _userButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_userButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        _userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_userButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [_userButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateDisabled];
        _userButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [self addSubview:_backgroundImage];
        
        [self addSubview:_line2];
        [self addSubview:_restaurantName];
        [self addSubview:_userButton];
        [self addSubview:_yumButton];
        [self addSubview:_numYums];
        [self addSubview:_caption];
        [self addSubview:_yumIndicator];
        
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yumPhotoTapped)];
        [_doubleTapGesture setDelaysTouchesBegan:YES];
        [_doubleTapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:_doubleTapGesture];
        
        [self registerForNotification:kNotificationMediaItemAltered
                              calling:@selector(handleMediaItemAltered:)];
        self.layer.borderColor = UIColorRGBA(kColorBordersAndLines).CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = kGeomCornerRadius;
        self.clipsToBounds = YES;
//        [DebugUtilities addBorderToViews:@[_yumButton, _caption, _numYums, _userButton, _restaurantName]];
    }
    return self;
}

- (void)registerForNotification:(NSString*) name calling:(SEL)selector
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:selector
                   name:name
                 object:nil];
}

- (void)unregisterFromNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)dealloc {
    [self unregisterFromNotifications];
    _delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame;
    CGSize size;
    CGFloat w = width(self) - 2*kGeomSpaceCellPadding;
    CGFloat y;

    frame = _yumButton.frame;
    frame.size = CGSizeMake(25, 25);
    frame.origin = CGPointMake(width(self)-CGRectGetWidth(frame), CGRectGetMaxY(_backgroundImage.frame) + kGeomSpaceCellPadding);
    _yumButton.frame = frame;
    
    frame = _numYums.frame;
    frame.origin.x = CGRectGetMinX(_yumButton.frame) - CGRectGetWidth(_numYums.frame) + 4;
    frame.origin.y = CGRectGetMaxY(_yumButton.frame) - CGRectGetHeight(_numYums.frame) - 5;
    _numYums.frame = frame;

    y = CGRectGetMaxY(_backgroundImage.frame) + kGeomSpaceCellPadding;
    
    frame = _restaurantName.frame;
    frame.origin = CGPointMake(kGeomSpaceCellPadding, y);
    frame.size = CGSizeMake(CGRectGetMinX(_numYums.frame)-CGRectGetMinX(frame), CGRectGetHeight(frame));
    _restaurantName.frame = frame;
    
    frame = _line2.frame;
    frame.origin = CGPointMake(kGeomSpaceCellPadding, (_restaurantObject) ? CGRectGetMaxY(_restaurantName.frame):y);
    frame.size = CGSizeMake(w, CGRectGetHeight(frame));
    _line2.frame = frame;

    size = [_caption sizeThatFits:CGSizeMake(w, 200)];
    frame = _caption.frame;
    frame.origin = CGPointMake(kGeomSpaceCellPadding, CGRectGetMaxY(_line2.frame) + kGeomSpaceCellPadding);
    frame.size = size;
    _caption.frame = frame;
}

- (void)showProfile {
    __weak PhotoCVCell *weakSelf = self;
    if ([_delegate respondsToSelector:@selector(photoCell:showProfile:)]) {
        _roGetUser = [OOAPI getUserWithID:_mediaItemObject.sourceUserID success:^(UserObject *user) {
            weakSelf.userObject = user;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate photoCell:self showProfile:_userObject];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Could not get the user");
        }];
    }
}

- (void)showOptions {
    if ([_delegate respondsToSelector:@selector(photoCell:showPhotoOptions:)]) {
        [_delegate photoCell:self showPhotoOptions:_mediaItemObject];
    }
}

- (void)yumPhotoTapped {
    if (_mediaItemObject.source != kMediaItemTypeOomami) return;
    
    [OOAPI isCurrentUserVerifiedSuccess:^(BOOL result) {
        if (!result) {
            [_delegate photoCell:self userNotVerified:_mediaItemObject];
        } else {
            __weak PhotoCVCell *weakSelf = self;
            if (_yumButton.isSelected) {
                NSLog(@"unlike photo");
                NSUInteger userID = [Settings sharedInstance].userObject.userID;
                [OOAPI unsetMediaItemLike:_mediaItemObject.mediaItemId forUser:userID success:^{
                    ON_MAIN_THREAD(^{
                        [_yumButton setSelected:NO];
                        _mediaItemObject.isUserYummed = NO;
                        [weakSelf updateNumYums];
                        if ([weakSelf.delegate respondsToSelector:@selector(photoCell:likePhoto:)]) {
                            [weakSelf.delegate photoCell:weakSelf likePhoto:_mediaItemObject];
                        }
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    ;
                }];
            } else {
                NSLog(@"like photo");
                NSUInteger userID = [Settings sharedInstance].userObject.userID;
                [OOAPI setMediaItemLike:_mediaItemObject.mediaItemId forUser:userID success:^{
                    [FBSDKAppEvents logEvent:kAppEventPhotoYummed];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.yumIndicator.alpha = 1;
                        weakSelf.yumIndicator.center = weakSelf.center;
                        [UIView animateKeyframesWithDuration:1 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                            weakSelf.yumIndicator.alpha = 0;
                        } completion:^(BOOL finished) {
                            [_yumButton setSelected:YES];
                        }];
                        _mediaItemObject.isUserYummed = YES;
                        [weakSelf updateNumYums];
                        if ([weakSelf.delegate respondsToSelector:@selector(photoCell:likePhoto:)]) {
                            [weakSelf.delegate photoCell:weakSelf likePhoto:_mediaItemObject];
                        }
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    ;
                }];
            }
            
            UserObject* myself= [Settings sharedInstance].userObject;
            if ( _mediaItemObject.sourceUserID==myself.userID) {
                // RULE: If I like or unlike my own photo, I will need to update my profile screen.
                NOTIFY(kNotificationOwnProfileNeedsUpdate);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*** Problem verifying user");
        if (error.code == kCFURLErrorNotConnectedToInternet) {
            message(@"You do not appear to be connected to the internet.");
        } else {
            message(@"There was a problem verifying your account.");
        }
        return;
    }];
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"iconButtonSmall": @(kGeomDimensionsIconButtonSmall), @"userNameLength" : @([_userButton sizeThatFits:CGSizeMake(200, 10)].width + 2)};

    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _backgroundImage, _userButton, /*_yumButton*/ _yumIndicator);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]-infoHeight-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    if (_userButton.titleLabel.text) {
//        if (_captionConstraint) {
//            [self removeConstraints:_captionConstraint];
//        }
//        _captionConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(userNameLength)-[_caption]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
//        [self addConstraints:_captionConstraint];
//    }
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceCellPadding-[_userButton][_numYums]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userButton]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_numYums]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_caption]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_yumIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_yumIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    CGFloat infoHeight = (_mediaItemObject.source == kMediaItemTypeOomami)? 77:0;
    
    [self removeConstraint:_imageContraint];
    _imageContraint = [NSLayoutConstraint constraintWithItem:_backgroundImage
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                   attribute:0
                                                  multiplier:1
                                                    constant:height(self)-infoHeight];
    
    [self addConstraint:_imageContraint];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_userButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1
                                                      constant:30]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_caption
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_userButton
//                                                     attribute:NSLayoutAttributeHeight
//                                                    multiplier:1
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_numYums
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:_userButton
//                                                     attribute:NSLayoutAttributeHeight
//                                                    multiplier:1
//                                                      constant:0]];
}

- (void)setRestaurantObject:(RestaurantObject *)restaurantObject {
    if (restaurantObject == _restaurantObject) return;
    _restaurantObject = restaurantObject;
    _restaurantName.text = _restaurantObject.name;
    _line2.text = [self line2String];
    
    [_restaurantName sizeToFit];
    [_line2 sizeToFit];
    [self setNeedsLayout];
}

- (NSString *)line2String {
    NSString *s;
    if (!_restaurantObject) return @"";
    
    NSMutableArray *components = [NSMutableArray array];
    if (_restaurantObject.cuisine) [components addObject:[NSString stringWithFormat:@"#%@", _restaurantObject.cuisine]];
    if ([_restaurantObject distanceOrAddressString]) [components addObject:[_restaurantObject distanceOrAddressString]];
    
    s = [components componentsJoinedByString:@" | "];
    
    if (![s length]) {
        s = @" ";
    }
    return s;
}

- (void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) {
        return;
    }

    _mediaItemObject = mediaItemObject;
    
    _userButton.hidden = _caption.hidden = _numYums.hidden = _yumButton.hidden = YES;
    _backgroundImage.image = nil;

    OOAPI *api = [[OOAPI alloc] init];
    
    __weak UIImageView *weakIV = _backgroundImage;
    __weak PhotoCVCell *weakSelf = self;
    
    _roGetImage = [api getRestaurantImageWithMediaItem:mediaItemObject maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
        
        [_backgroundImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                                placeholderImage:nil
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             ON_MAIN_THREAD(^ {
                                                 [weakIV setAlpha:0.0];
                                                 weakIV.image = image;
                                                 [UIView beginAnimations:nil context:NULL];
                                                 [UIView setAnimationDuration:0.3];
                                                 [weakIV setAlpha:1.0];
                                                 [UIView commitAnimations];
                                                 [weakSelf setNeedsUpdateConstraints];
                                                 [weakSelf setNeedsLayout];
                                             });
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             ;
                                         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];

    //[self updateLikedState];
    [_yumButton setSelected:_mediaItemObject.isUserYummed];
    _yumButton.hidden = (_mediaItemObject.source == kMediaItemTypeOomami) ? NO : YES;
    
    if (_mediaItemObject.sourceUserID) {
        [_userButton setTitle:[NSString stringWithFormat:@"@%@", _mediaItemObject.sourceUsername] forState:UIControlStateNormal];
        _userButton.hidden = YES;
        [self setNeedsUpdateConstraints];
        _numYums.text = [NSString stringWithFormat:@"%lu", (unsigned long)_mediaItemObject.yumCount];
        [_numYums sizeToFit];
        _numYums.hidden = (_mediaItemObject.yumCount) ? NO : YES;
        
        _caption.hidden = NO;
        _caption.text = [self captionString];
    } else {
        _userButton.hidden = YES;
        _caption.hidden = YES;
    }
    
    if (_mediaItemObject.sourceUserID == [Settings sharedInstance].userObject.userID) {
        _userButton.enabled = NO;
    } else {
        _userButton.enabled = YES;
    }
    
    [self setNeedsLayout];
    //Disable for now to solve the phantom nav bar issue
//    _userButton.enabled = NO;
}

- (NSString *)captionString {
    NSString *s;
    if (!_mediaItemObject) return @"";
    
    s = [NSString stringWithFormat:@" says \"%@\"", trimString(_mediaItemObject.caption)];
    s = [NSString stringWithFormat:@"@%@%@", _mediaItemObject.sourceUsername, [_mediaItemObject.caption length]?s:@""];
    
    return s;
}

- (void)handleMediaItemAltered:(NSNotification*)not
{
    id object = not.object;
    if ([object isKindOfClass:[MediaItemObject class]]) {
        MediaItemObject *mio = (MediaItemObject *)object;
        if (mio && mio.mediaItemId == _mediaItemObject.mediaItemId) {
            
            _mediaItemObject.caption = mio.caption;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateLikedState];
                [self setNeedsUpdateConstraints];
            });
            
        }
    }
}

- (void)updateLikedState {
    __weak PhotoCVCell *weakSelf = self;
    
    if (_mediaItemObject.source == kMediaItemTypeOomami) {
        //get the state of the yum button for this user
        _roGetLiked = [OOAPI getMediaItemLiked:_mediaItemObject.mediaItemId byUser:[Settings sharedInstance].userObject.userID success:^(BOOL liked) {
            ON_MAIN_THREAD(^{
                [weakSelf.yumButton setSelected:liked];
                weakSelf.yumButton.hidden = NO;
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ON_MAIN_THREAD(^{
                [weakSelf.yumButton setSelected:NO];
                weakSelf.yumButton.hidden = YES;
            });
        }];
        [self updateNumYums];
    } else {
        _yumButton.hidden = YES;
        _numYums.hidden = YES;
    }
}

- (void)updateNumYums {
    __weak PhotoCVCell *weakSelf = self;
    _roGetNumLikes = [OOAPI getNumMediaItemLikes:_mediaItemObject.mediaItemId success:^(NSUInteger count) {
        _mediaItemObject.yumCount = count;
        if (count) {
            _numYums.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
            ON_MAIN_THREAD(^ {
                weakSelf.numYums.hidden = NO;
                [weakSelf.numYums sizeToFit];
                [weakSelf setNeedsLayout];
            });
        } else {
            ON_MAIN_THREAD(^ {
                weakSelf.numYums.hidden = YES;
                [weakSelf setNeedsLayout];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ON_MAIN_THREAD(^ {
            weakSelf.numYums.hidden = YES;
            [weakSelf setNeedsUpdateConstraints];
        });
    }];
}

- (UIImage *)shareImage {
    UIView *shareView = [UIView new];
    //shareView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    CGRect frame;
    UIImageView *iv = [UIImageView new];
    iv.frame = _backgroundImage.frame;
    iv.image = _backgroundImage.image;
    if (!iv.image) return nil;
    
    if (_mediaItemObject.source == kMediaItemTypeOomami) {
        UILabel *logo = [UILabel new];
        [logo withFont:[UIFont fontWithName:kFontIcons size:50] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentRight];
        logo.text = kFontIconLogoFull;
        [logo sizeToFit];
        frame = logo.frame;
        frame.size.width = CGRectGetWidth(iv.frame)-8;
        frame.origin = CGPointMake(0, height(iv) - height(logo) + 15);
        logo.frame = frame;
        [iv addSubview:logo];
    }
    
    [shareView addSubview:iv];
    
    frame = iv.bounds;
    shareView.frame = frame;
    [shareView setNeedsLayout];
    
    _imageToShare = [UIImage imageFromView:shareView];
    
    return _imageToShare;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_backgroundImage.layer removeAllAnimations];
    [_backgroundImage cancelImageRequestOperation];
    
    [_roGetImage cancel];
    _roGetImage = nil;

    [_roGetLiked cancel];
    _roGetLiked = nil;

    [_roGetNumLikes cancel];
    _roGetNumLikes = nil;

    [_roGetUser cancel];
    _roGetUser = nil;
}




@end
