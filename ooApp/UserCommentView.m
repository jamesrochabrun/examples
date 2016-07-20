//
//  UserCommentView.m
//  ooApp
//
//  Created by James Rochabrun on 20-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "UserCommentView.h"



@interface UserCommentView ()

@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIButton *commentButton;
@end


@implementation UserCommentView


- (instancetype)init {
    self = [super init];
    if (self) {
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
 
    }
    return self;
}

@end
