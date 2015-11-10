//
//  VoteObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
@interface VoteObject: NSObject
@property (nonatomic, assign) NSUInteger eventID;
@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, assign) NSUInteger venueID;
@property (nonatomic, assign) NSUInteger vote; // 1 => NO, 5 => YES6

+ (instancetype)voteFromDictionary:(NSDictionary *)dictionary;

enum  {
    VOTE_STATE_DONT_CARE= 0,
    VOTE_STATE_YES= 1,
    VOTE_STATE_NO=  -1,
};

@end

