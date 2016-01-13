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

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIButton *takeAction;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *yumButton;
@property (nonatomic, strong) UILabel *numYums;
@property (nonatomic, strong) UILabel *caption;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@end

@implementation PhotoCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _takeAction = [UIButton buttonWithType:UIButtonTypeCustom];
        _takeAction.translatesAutoresizingMaskIntoConstraints = NO;
        [_takeAction roundButtonWithIcon:kFontIconMore fontSize:25 width:25 height:0 backgroundColor:kColorBlack target:self selector:@selector(showOptions)];
        
        _yumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _yumButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_yumButton withIcon:kFontIconYumOutline fontSize:20 width:25 height:0 backgroundColor:kColorClear target:self selector:@selector(yumPhotoTapped)];
        [_yumButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        [_yumButton setTitle:kFontIconYum forState:UIControlStateSelected];
        _yumButton.contentEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);

        _caption = [[UILabel alloc] init];
        [_caption withFont:[UIFont fontWithName:kFontIcons size:15] textColor:kColorYellow backgroundColor:kColorClear];
        _caption.text = kFontIconCaptionFilled;
        _caption.translatesAutoresizingMaskIntoConstraints = NO;
        
        _numYums = [[UILabel alloc] init];
        [_numYums withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeH4] textColor:kColorWhite backgroundColor:kColorClear];
        _numYums.translatesAutoresizingMaskIntoConstraints = NO;
        
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userButton withText:@"" fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(showProfile)];
        _userButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_userButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        _userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_userButton setTitleColor:UIColorRGBA(kColorYellow) forState:UIControlStateNormal];
        _userButton.contentEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0);
        
        [self addSubview:_backgroundImage];
        [self addSubview:_takeAction];
        
        _gradient = [CAGradientLayer layer];
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNull null], @"bounds",
                                           [NSNull null], @"position",
                                           nil];
        _gradient.actions = newActions;
        
        [self.layer addSublayer:_gradient];
        _gradient.colors = [NSArray arrayWithObjects:(id)[UIColorRGBA(0x02000000) CGColor], (id)[UIColorRGBA((0xBB000000)) CGColor], nil];
        [self addSubview:_userButton];
        [self addSubview:_yumButton];
        [self addSubview:_numYums];
        [self addSubview:_caption];
        
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yumPhotoTapped)];
        [_doubleTapGesture setDelaysTouchesBegan:YES];
        [_doubleTapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:_doubleTapGesture];
        
//        [DebugUtilities addBorderToViews:@[_yumButton, _numYums, _userButton]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = CGRectMake(0, height(self)-50, width(self), 50);
}

- (void)showActionButton:(BOOL)show {
    _takeAction.hidden = !show;
}

- (void)showProfile {
    if ([_delegate respondsToSelector:@selector(photoCell:showProfile:)]) {
        [_delegate photoCell:self showProfile:_userObject];
    }
}

- (void)showOptions {
    if ([_delegate respondsToSelector:@selector(photoCell:showPhotoOptions:)]) {
        [_delegate photoCell:self showPhotoOptions:_mediaItemObject];
    }
}

- (void)yumPhotoTapped {
    __weak PhotoCVCell *weakSelf = self;
    if (_yumButton.isSelected) {
        NSLog(@"unlike photo");
        NSUInteger userID = [Settings sharedInstance].userObject.userID;
        [OOAPI unsetMediaItemLike:_mediaItemObject.mediaItemId forUser:userID success:^{
            ON_MAIN_THREAD(^{
                [_yumButton setSelected:NO];
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
            ON_MAIN_THREAD(^{
                [_yumButton setSelected:YES];
                [weakSelf updateNumYums];
                if ([weakSelf.delegate respondsToSelector:@selector(photoCell:likePhoto:)]) {
                    [weakSelf.delegate photoCell:weakSelf likePhoto:_mediaItemObject];
                }
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)updateYumButton {
    
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"iconButtonSmall": @(kGeomDimensionsIconButtonSmall), @"userNameLength" : @([_userButton sizeThatFits:CGSizeMake(200, 10)].width + 2)};

    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _backgroundImage,_numYums, _takeAction, _userButton, _yumButton, _caption);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    if (_userButton.titleLabel.text) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(userNameLength)-[_caption]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    }
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceCellPadding-[_userButton][_numYums][_yumButton(25)]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_takeAction(25)]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceCellPadding-[_takeAction(25)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userButton(35)]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_yumButton(35)]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_numYums]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_caption]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

-(void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    
    _userButton.hidden = _gradient.hidden = _yumButton.hidden = _numYums.hidden = _caption.hidden = YES;
    
    _backgroundImage.image = nil;
    if (_mediaItemObject.caption.length) _caption.hidden = NO;
    
    OOAPI *api = [[OOAPI alloc] init];
    
    __weak UIImageView *weakIV = _backgroundImage;
    __weak PhotoCVCell *weakSelf = self;
    
    _requestOperation = [api getRestaurantImageWithMediaItem:mediaItemObject maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
        
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

    if (_mediaItemObject.source == kMediaItemTypeOomami) {
        _yumButton.hidden = NO;
        
        [self updateNumYums];
        
        [OOAPI getMediaItemLiked:_mediaItemObject.mediaItemId byUser:[Settings sharedInstance].userObject.userID success:^(BOOL liked) {
            ON_MAIN_THREAD(^{
                [_yumButton setSelected:liked];
                _yumButton.hidden = NO;
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ON_MAIN_THREAD(^{
                [_yumButton setSelected:NO];
                _yumButton.hidden = NO;
            });
        }];
        //get the state of the yum button for this user
    }
    
    if (_mediaItemObject.sourceUserID) {
//        __weak PhotoCVCell *weakSelf = self;
        [OOAPI getUserWithID:_mediaItemObject.sourceUserID success:^(UserObject *user) {
            _userObject = user;
            NSString *userName = [NSString stringWithFormat:@"@%@", _userObject.username];
            ON_MAIN_THREAD(^{
                [_userButton setTitle:userName forState:UIControlStateNormal];
                _userButton.hidden = NO;
                _gradient.hidden = NO;
                [weakSelf setNeedsUpdateConstraints];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

- (void)updateNumYums {
    __weak PhotoCVCell *weakSelf = self;
    [OOAPI getNumMediaItemLikes:_mediaItemObject.mediaItemId success:^(NSUInteger count) {
        if (count) {
            _numYums.text = [NSString stringWithFormat:@"%lu", count];
            ON_MAIN_THREAD(^ {
                _numYums.hidden = NO;
                [weakSelf setNeedsUpdateConstraints];
            });
        } else {
            ON_MAIN_THREAD(^ {
                _numYums.hidden = YES;
                [weakSelf setNeedsUpdateConstraints];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ON_MAIN_THREAD(^ {
            _numYums.hidden = YES;
            [weakSelf setNeedsUpdateConstraints];
        });
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_requestOperation cancel];
    _requestOperation = nil;
}




@end
