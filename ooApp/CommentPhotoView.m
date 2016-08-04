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
        _userNameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        //[_userNameButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        _userNameButton.titleEdgeInsets = UIEdgeInsetsMake(-6, 0, 0, 0);
        [_userNameButton setTitleColor:UIColorRGBA(kColorTextActive) forState:UIControlStateNormal];
        [_userNameButton.titleLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];
        [_userNameButton addTarget:self action:@selector(userNameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_userNameButton];
        
        _userCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userCommentButton setTitleColor:UIColorRGBA(kColorBlack) forState:UIControlStateNormal];
        [_userCommentButton.titleLabel setFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4]];
        _userCommentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _userCommentButton.titleLabel.numberOfLines = 0;
        [self addSubview:_userCommentButton];
        
        //[DebugUtilities addBorderToViews:@[_userNameButton, _userCommentButton]];
        //[DebugUtilities addBorderToViews:@[self]];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGFloat w = self.bounds.size.width;
    
    [_userNameButton sizeToFit];
    frame = _userNameButton.frame;
    frame.origin.x = kGeomSpaceEdge;
    frame.origin.y = CGRectGetMinY(self.bounds);
    _userNameButton.frame = frame;

    frame = _userCommentButton.frame;
    frame.origin.x = CGRectGetMaxX(_userNameButton.frame) + kGeomSpaceInter;
    frame.size.width = w - kGeomSpaceEdge - CGRectGetMinX(frame);
    frame.size.height = [_userCommentButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width, 200)].height;
    frame.origin.y = CGRectGetMinY(_userNameButton.frame);
    _userCommentButton.frame = frame;
    
    frame = self.frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = MAX(CGRectGetMaxY(_userCommentButton.frame), CGRectGetMaxY(_userNameButton.frame)) + kGeomSpaceInter;
    self.frame = frame;
    
    NSLog(@"self.frame = %@", NSStringFromCGRect(self.frame));
//    [DebugUtilities addBorderToViews:@[_userNameButton]];
//    _userCommentButton.layer.borderColor = [UIColor blueColor].CGColor;
//    _userCommentButton.layer.borderWidth = 1;
//    self.layer.borderColor = [UIColor redColor].CGColor;
//    self.layer.borderWidth = 1;
    
}

- (void)setComment:(CommentObject *)comment {
    
    if (comment == _comment) return;
    _comment = comment;
    __weak CommentPhotoView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.userCommentButton setTitle:weakSelf.comment.content forState:UIControlStateNormal];
        [weakSelf setNeedsLayout];
    });
}

- (void)setUser:(UserObject *)user {
    
    if (user == _user) return;
    _user = user;
    __weak CommentPhotoView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.userNameButton setTitle:[NSString stringWithFormat:@"@%@", weakSelf.user.username] forState:UIControlStateNormal];
        [weakSelf setNeedsLayout];
    });
}

- (void)userNameButtonTapped:(id)sender {
    
    [self.delegate goToUserProfile:_user];
}

















@end
