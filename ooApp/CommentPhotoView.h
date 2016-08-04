//
//  CommentPhotoView.h
//
//  Created by James Rochabrun on 22-07-16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserObject;

@protocol CommentPhotoViewDelegate <NSObject>
@optional

- (void)goToUserProfile:(UserObject *)user;
@end

@interface CommentPhotoView : UIView
@property (nonatomic, strong) UIButton *userNameButton;
@property (nonatomic, strong) UIButton *userCommentButton;
@property (nonatomic, strong) CommentObject *comment;
@property (nonatomic, strong) UserObject *user;
@property (nonatomic, weak) id<CommentPhotoViewDelegate> delegate;

@end
