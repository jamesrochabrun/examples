//
//  UserObject.m
//  ooApp
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UserObject.h"

NSString *const kKeyID = @"user_id";
NSString *const kKeyFirstName = @"first_name";
NSString *const kKeyLastName = @"last_name";
NSString *const kKeyEmail = @"email";
NSString *const kKeyPhoneNumber = @"phone_number";
NSString *const kKeyToken = @"general_token";

@implementation UserObject

+ (UserObject *)userFromDict:(NSDictionary *)dict {
    UserObject *user =[[UserObject alloc] init];
    user.userID = [dict objectForKey:kKeyID];
    user.firstName = [dict objectForKey:kKeyFirstName];
    user.lastName = [dict objectForKey:kKeyLastName];
    user.email = [dict objectForKey:kKeyEmail];
    user.phoneNumber = [dict objectForKey:kKeyPhoneNumber];
    user.token = [dict objectForKey:kKeyToken];
    return user;
}

@end
