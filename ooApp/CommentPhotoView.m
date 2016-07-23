//
//  CommentPhotoView.m
//
//  Created by James Rochabrun on 22-07-16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import "CommentPhotoView.h"
#import "DebugUtilities.h"


@implementation CommentPhotoView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _userNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userNameButton setTitle:@"foodie food foodo" forState:UIControlStateNormal];
        [_userNameButton.titleLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];
        [_userNameButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        
        [self addSubview:_userNameButton];
        
        _userCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userCommentButton.titleLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];
        [_userCommentButton setTitle:@"; klnkklnkklnkklnkklnk klnk klnk klnk klnk klnk klnk klnk klnk klnk  klnk klnk klnk esto es el final de esto y vamos a ver como se crece y crece " forState:UIControlStateNormal];
        _userCommentButton.titleLabel.numberOfLines = 0;
        _userCommentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        [_userCommentButton setTitleColor:UIColorRGBA(kColorGrayMiddle) forState:UIControlStateNormal];
        
        [self addSubview:_userCommentButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGFloat w = self.bounds.size.width;
    CGFloat margin = 8;
    CGFloat space = 4;
    
    //    frame = _userNameButton.frame;
    //    CGFloat width = [_userNameButton.titleLabel sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)].width;
    //    NSLog(@"THE WIDTH OF THE USERNAMEBUTTON IS %f", width);
    //    frame.size.width = width;
    //    frame.size.height = 0;
    //    frame.origin.x = margin;
    //    frame.origin.y = CGRectGetMinY(self.bounds) + 20;
    //    _userNameButton.frame = frame;
    
    frame = _userNameButton.frame;
    frame.size.height = kGeomDimensionsIconButton;
    CGFloat w2 = [_userNameButton sizeThatFits:CGSizeMake(0, frame.size.height)].width;
    frame.size.width = (kGeomDimensionsIconButton > w2) ? kGeomDimensionsIconButton : w2;
    frame.origin.x = margin;
    frame.origin.y = CGRectGetMinY(self.bounds);
    _userNameButton.frame = frame;
    
    
    frame = _userCommentButton.frame;
    frame.size.width = w - _userNameButton.frame.size.width - space - margin * 3;
    CGFloat height = [_userCommentButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width,0)].height;
    frame.size.height = height;
    frame.origin.x = CGRectGetMaxX(_userNameButton.frame) + space;
    frame.origin.y = CGRectGetMidY(_userNameButton.frame) - 8;
    _userCommentButton.frame = frame;
    
    frame = self.frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = _userCommentButton.frame.size.height + margin + space;
    self.frame = frame;
    
    [DebugUtilities addBorderToViews:@[_userNameButton, _userCommentButton, self]];
    
}





















@end
