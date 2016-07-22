//
//  CommentPhotoView.m
//
//  Created by James Rochabrun on 22-07-16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import "CommentPhotoView.h"

@implementation CommentPhotoView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _userNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userNameButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
        [_userNameButton setTitle:@"foodie foodie" forState:UIControlStateNormal];
        _userNameButton.backgroundColor = [UIColor greenColor];
  
        [self addSubview:_userNameButton];
        
        _userCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userCommentButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
        [_userNameButton setTintColor:[UIColor blueColor]];
        [_userCommentButton setTitle:@"helll  12341234123412341234 1234 1234 1234 1234 12341234 1234 1234 1234 1234 1234 1234 last item" forState:UIControlStateNormal];
        _userCommentButton.titleLabel.numberOfLines = 0;
        _userCommentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
     
        _userCommentButton.backgroundColor = [UIColor purpleColor];
        [self addSubview:_userCommentButton];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat margin = 8;
    CGFloat space = 4;
    
    frame = _userNameButton.frame;
    CGFloat width = [_userNameButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width, FLT_MAX)].width;
    frame.size.width = width;
    frame.size.height = 0;
    frame.origin.x = margin;
    frame.origin.y = CGRectGetMinY(self.bounds) + 20;
    _userNameButton.frame = frame;
    
    frame = _userCommentButton.frame;
    frame.size.width = w - _userNameButton.frame.size.width - space - margin * 3;
    CGFloat height = [_userCommentButton.titleLabel sizeThatFits:CGSizeMake(frame.size.width,FLT_MAX)].height;
    frame.size.height = height;
    frame.origin.x = CGRectGetMaxX(_userNameButton.frame) + space;
    frame.origin.y = CGRectGetMidY(_userNameButton.frame) - 7;
    _userCommentButton.frame = frame;
    
    frame = self.frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = _userCommentButton.frame.size.height + margin + space;
    self.frame = frame;
    
}








@end
