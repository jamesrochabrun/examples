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
        [_emptyUserView withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorYellow backgroundColor:kColorBlack];
        [self addSubview:_emptyUserView];
        _emptyUserView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _imageView, _emptyUserView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|_imageView|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|_imageView|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|_emptyUserView|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|_emptyUserView|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _emptyUserView.layer.cornerRadius = width(_emptyUserView)/2;
    _imageView.layer.cornerRadius = width(_imageView)/2;
}

- (void)setUser:(UserObject *)user {
    if (user == _user) return;
    _user = user;
    
    if (_user.mediaItem) {
        OOAPI *api = [[OOAPI alloc] init];
        [api getRestaurantImageWithMediaItem:_user.mediaItem maxWidth:200 maxHeight:0 success:^(NSString *link) {
            __weak UIImageView *weakIV = _imageView;
            __weak OOUserView *weakSelf = self;
            [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]
                              placeholderImage:nil
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
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
                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                           ;
                                       }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end