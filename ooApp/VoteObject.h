//
//  VoteObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
@interface VoteObject: NSObject
@property (nonatomic,assign) NSInteger eventID;
@property (nonatomic,assign) NSInteger userID;
@property (nonatomic,assign) NSInteger venueID;
@property (nonatomic,assign) NSInteger vote; // 1 => NO, 5 => YES6

+ (instancetype) voteFromDictionary: (NSDictionary*)dictionary;

@end

