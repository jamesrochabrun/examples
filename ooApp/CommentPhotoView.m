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
        [_userNameButton addTarget:self action:@selector(userNameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
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
    frame.origin.y = CGRectGetMidY(_userNameButton.frame) - kGeomSpaceEdge - 1;
    _userCommentButton.frame = frame;
    
    frame = self.frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = (kGeomDimensionsIconButton > height) ? kGeomDimensionsIconButton : height + 15;
    self.frame = frame;
    
//    [DebugUtilities addBorderToViews:@[_userNameButton]];
//    _userCommentButton.layer.borderColor = [UIColor blueColor].CGColor;
//    _userCommentButton.layer.borderWidth = 1;
//    self.layer.borderColor = [UIColor redColor].CGColor;
//    self.layer.borderWidth = 1;
    
}

- (void)setComment:(CommentObject *)comment {
    
    if (comment == _comment) return;
    _comment = comment;
}

- (void)setUser:(UserObject *)user {
    
    if (user == _user) return;
    _user = user;
}

- (void)userNameButtonTapped:(id)sender {
    
    //[self.delegate getUserFromComment:_comment];
    [self.delegate goToUserProfile:_user];
}

















@end
