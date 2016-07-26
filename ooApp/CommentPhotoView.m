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
        [_userNameButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [_userNameButton.titleLabel setFont:[UIFont fontWithName:kFontLatoRegular  size: kGeomFontSizeH4]];
        [self addSubview:_userNameButton];
        
        _userCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userCommentButton setTitleColor:UIColorRGBA(kColorBlack) forState:UIControlStateNormal];
        [_userCommentButton.titleLabel setFont:[UIFont fontWithName:kFontLatoRegular  size: kGeomFontSizeH4]];
        _userCommentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _userCommentButton.titleLabel.numberOfLines = 0;
        [self addSubview:_userCommentButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGFloat w = self.bounds.size.width;
    CGFloat margin = kGeomSpaceEdge + kGeomSpaceInter;
    
    frame = _userNameButton.frame;
    frame.size.height = kGeomDimensionsIconButton;
    CGFloat w2 = [_userNameButton sizeThatFits:CGSizeMake(0, frame.size.height)].width;
    frame.size.width = (kGeomDimensionsIconButton > w2) ? kGeomDimensionsIconButton : w2;
    frame.origin.x = margin;
    frame.origin.y = CGRectGetMinY(self.bounds);
    _userNameButton.frame = frame;
    
    frame = _userCommentButton.frame;
    frame.size.width = w - _userNameButton.frame.size.width - kGeomSpaceInter - margin * 3;
    CGFloat height = [_userCommentButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width, 0)].height;
    frame.size.height = height;
    frame.origin.x = CGRectGetMaxX(_userNameButton.frame) + kGeomSpaceInter;
    frame.origin.y = CGRectGetMidY(_userNameButton.frame);//CGRectGetMidY(_userNameButton.frame) - 8;
    _userCommentButton.frame = frame;
    
    NSLog(@"the height is f = %f", height);
    
    frame = self.frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = _userCommentButton.frame.size.height + margin + kGeomSpaceInter;
    self.frame = frame;
    
    [DebugUtilities addBorderToViews:@[_userNameButton, _userCommentButton, self]];
    
}





















@end
