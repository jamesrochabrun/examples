//
//  UserObject.m
//  Oomami
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
NSString *const kKeyGender = @"gender";

@implementation UserObject

//------------------------------------------------------------------------------
// Name:    +userFromDict
// Purpose: Instantiates user object from user dictionary.
//------------------------------------------------------------------------------
+ (UserObject *)userFromDict:(NSDictionary *)dict
{
    UserObject *user =[[UserObject alloc] init];
    user.userID = [dict objectForKey:kKeyID];
    user.firstName = [dict objectForKey:kKeyFirstName];
    user.lastName = [dict objectForKey:kKeyLastName];
    user.email = [dict objectForKey:kKeyEmail];
    user.phoneNumber = [dict objectForKey:kKeyPhoneNumber];
    user.token = [dict objectForKey:kKeyToken];
    user.gender = [dict objectForKey:kKeyGender];

    return user;
}

//------------------------------------------------------------------------------
// Name:    dictionaryFromUser
// Purpose: Provides dict from user object.
//------------------------------------------------------------------------------
- (NSDictionary*) dictionaryFromUser;
{
    return @{
             kKeyID : self.userID ?: @"",
             kKeyFirstName:self.firstName ?: @"",
             kKeyLastName:self.lastName ?: @"",
             kKeyEmail: self.email ?: @"",
             kKeyPhoneNumber:self.phoneNumber ?: @"",
             kKeyToken:self.token ?: @"",
             kKeyGender:self.gender ?: @""
             };
}

@end
