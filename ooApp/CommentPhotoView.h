//
//  CommentPhotoView.h
//
//  Created by James Rochabrun on 22-07-16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentPhotoViewDelegate <NSObject>
@optional
- (void)didUserPostComment;
@end

@interface CommentPhotoView : UIView
@property (nonatomic, strong) UIButton *userNameButton;
@property (nonatomic, strong) UIButton *userCommentButton;
@property CommentObject *comment;

@end
