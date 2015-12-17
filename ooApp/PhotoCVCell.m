//
//  PhotoCVCell.m
//  ooApp
//
//  Created by Anuj Gujar on 10/14/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "PhotoCVCell.h"
#import "OOAPI.h"

@interface PhotoCVCell ()

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIButton *takeAction;

@end

@implementation PhotoCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        _takeAction = [UIButton buttonWithType:UIButtonTypeCustom];
        _takeAction.translatesAutoresizingMaskIntoConstraints = NO;
        [_takeAction roundButtonWithIcon:kFontIconMore fontSize:15 width:25 height:0 backgroundColor:kColorBlack target:self selector:@selector(showOptions)];
        
        [self addSubview:_backgroundImage];
        [self addSubview:_takeAction];
    }
    return self;
}

- (void)showActionButton:(BOOL)show {
    _takeAction.hidden = !show;
}

- (void)showOptions {
    [_delegate photoCell:self showPhotoOptions:_mediaItemObject];
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _backgroundImage, _takeAction);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_takeAction(25)]-spaceCellPadding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceCellPadding-[_takeAction(25)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

-(void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    
    _backgroundImage.image = nil;
    
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
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_requestOperation cancel];
    _requestOperation = nil;
}




@end
