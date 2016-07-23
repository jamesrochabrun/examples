//
//  CommentObject.m
//  ooApp
//
//  Created by James Rochabrun on 18-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "CommentObject.h"

@implementation CommentObject

NSString *const kKeyCommentMediaItemCommentID = @"media_item_comment_id";
NSString *const kKeyCommentUserID = @"user_id";
NSString *const kKeyCommentMediaItemID = @"media_item_id";
NSString *const kKeyCommentContent = @"content";



+ (CommentObject *)commentFromDict:(NSDictionary *)dict {
    CommentObject *comment = [CommentObject new];
    comment.mediaItemCommentID = parseUnsignedIntegerOrNullFromServer(dict [kKeyCommentMediaItemCommentID]);
    comment.userID = parseUnsignedIntegerOrNullFromServer(dict[kKeyCommentUserID]);
    comment.mediaItemID = parseUnsignedIntegerOrNullFromServer(dict[kKeyCommentMediaItemID]);
    comment.content = parseStringOrNullFromServer(dict[kKeyCommentContent]);
    return comment;
}

@end
