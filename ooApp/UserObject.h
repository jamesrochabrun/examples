//
//  UserObject.h
//  Oomami
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *token;

+ (UserObject *)userFromDict:(NSDictionary *)dict;
- (NSDictionary*) dictionaryFromUser;

@end
