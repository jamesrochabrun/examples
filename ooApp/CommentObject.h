//
//  CommentObject.h
//  ooApp
//
//  Created by James Rochabrun on 18-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyCommentMediaItemCommentID;
extern NSString *const kKeyCommentUserID;
extern NSString *const kKeyCommentMediaItemID;
extern NSString *const kKeyCommentContent;
extern NSString *const kKeyCommentCreatedAt;
extern NSString *const kKeyCommentUpdatedAt;

@interface CommentObject : NSObject

@property (nonatomic, assign) NSUInteger mediaItemCommentID;
@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, assign) NSUInteger mediaItemID;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

+ (CommentObject *)commentFromDict:(NSDictionary *)dict;
@end
