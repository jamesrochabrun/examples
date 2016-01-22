//
//  OOUserView.m
//  ooApp
//
//  Created by Anuj Gujar on 11/19/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOUserView.h"
#import "OOAPI.h"

@interface OOUserView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *emptyUserView;

@end

@implementation OOUserView

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _emptyUserView = [[UILabel alloc] init];
        [_emptyUserView withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorGrayMiddle];
        _emptyUserView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emptyUserView];
        _emptyUserView.translatesAutoresizingMaskIntoConstraints = NO;
               self.clipsToBounds = YES;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _imageView, _emptyUserView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyUserView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyUserView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    _imageView.layer.cornerRadius = width(_imageView)/2;
    _imageView.layer.borderColor = UIColorRGBA(kColorWhite).CGColor;
    _imageView.layer.borderWidth = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    _emptyUserView.layer.cornerRadius = width(_emptyUserView)/2;
//    _imageView.layer.cornerRadius = width(_imageView)/2;
    self.layer.cornerRadius = width(_imageView)/2;
}

- (void)setUser:(UserObject *)user {
    if (user == _user) return;
    _user = user;
    if (!user) {
        self.imageView.image = nil;
        return;
    }
    
    NSString *first= _user.firstName.length? [_user.firstName substringToIndex:1] : @"";
    NSString *last=_user.lastName.length? [_user.lastName substringToIndex:1] : @"";
    NSString *initials = [NSString stringWithFormat:@"%@%@",  first, last];
    _emptyUserView.text = initials;
    UIImage *image= nil;
        
    if (_user.mediaItem) {
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantImageWithMediaItem:_user.mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            __weak UIImageView *weakIV = _imageView;
            __weak OOUserView *weakSelf = self;
            [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                              placeholderImage:nil
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 weakIV.image = image;
                                                 [weakIV setAlpha:1.0];
                                                 weakSelf.emptyUserView.alpha = 0;
                                                 [weakSelf updateConstraintsIfNeeded];
                                           });
                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                               [weakSelf displayEmptyView:YES];
                                           });
                                       }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayEmptyView:YES];
            });
        }];
    } else if (( image= [_user userProfilePhoto]) ) {
        // NOTE: This would have been fetched from Facebook when the app started.
        _imageView.image =  image;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayEmptyView:YES];
        });
    }
}

- (void)displayEmptyView:(BOOL)displayIt {
    if (displayIt) {
        _imageView.alpha = 0;
        _emptyUserView.alpha = 1;
        [self setNeedsUpdateConstraints];
    }
}

- (void) clear;
{
    _imageView.image=nil;
    _user= nil;
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
