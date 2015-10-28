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

@end

@implementation PhotoCVCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImage = [[UIImageView alloc] init];
        _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_backgroundImage];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *metrics = @{@"height":@(kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter)};
    
    UIView *superview = self;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _backgroundImage);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}

-(void)setMediaItemObject:(MediaItemObject *)mediaItemObject {
    if (mediaItemObject == _mediaItemObject) return;
    _mediaItemObject = mediaItemObject;
    
    _backgroundImage.image = nil;
    
    OOAPI *api = [[OOAPI alloc] init];
    
    NSString *imageRef = mediaItemObject.reference;
    __weak UIImageView *weakIV = _backgroundImage;
    __weak PhotoCVCell *weakSelf = self;
    
    if (imageRef) {
        _requestOperation = [api getRestaurantImageWithImageRef:imageRef maxWidth:self.frame.size.width maxHeight:0 success:^(NSString *link) {
            
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
        } failure:^(NSError *error) {
            ;
        }];
    } else {
        
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_requestOperation cancel];
    _requestOperation = nil;
}




@end
