//
//  ViewPhotoCommentSubView.m
//  ooApp
//
//  Created by James Rochabrun on 7/28/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "ViewPhotoCommentSubView.h"

@implementation ViewPhotoCommentSubView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _commentPhotoView = [CommentPhotoView new];
        [self addSubview:_commentPhotoView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
    
    
}


@end
