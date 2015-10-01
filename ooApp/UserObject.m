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
NSString *const kKeyMiddleName = @"middle_name";
NSString *const kKeyEmail = @"email";
NSString *const kKeyPhoneNumber = @"phone_number";
NSString *const kKeyUsername = @"username";
NSString *const kKeyToken = @"backend_auth_token";
NSString *const kKeyGender = @"gender";
NSString *const kKeyImageURL = @"imageURL";
NSString *const kKeyImageIdentifier = @"imageIdentifier";

@interface UserObject()

@end

@implementation UserObject

- (instancetype) init
{
    self = [super init];
    if (self) {
     }
    return self;
}

//------------------------------------------------------------------------------
// Name:    +userFromDict
// Purpose: Instantiates user object from user dictionary.
//------------------------------------------------------------------------------
+ (UserObject *)userFromDict:(NSDictionary *)dict
{
    UserObject *user =[[UserObject alloc] init];
    user.userID = [dict objectForKey:kKeyID];
    user.firstName = [dict objectForKey:kKeyFirstName];
    user.middleName = [dict objectForKey:kKeyMiddleName];
    user.lastName = [dict objectForKey:kKeyLastName];
    user.email = [dict objectForKey:kKeyEmail];
    user.phoneNumber = [dict objectForKey:kKeyPhoneNumber];
    user.backendAuthorizationToken = [dict objectForKey:kKeyToken];
    user.gender = [dict objectForKey:kKeyGender];
    user.username=[dict objectForKey:kKeyUsername];
    user.imageURLString=[dict objectForKey:kKeyImageURL];
    user.imageIdentifier=[dict objectForKey:kKeyImageIdentifier];
    
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
             kKeyMiddleName:self.middleName ?: @"",
             kKeyFirstName:self.firstName ?: @"",
             kKeyLastName:self.lastName ?: @"",
             kKeyEmail: self.email ?: @"",
             kKeyPhoneNumber:self.phoneNumber ?: @"",
             kKeyToken:self.backendAuthorizationToken ?: @"",
             kKeyGender:self.gender ?: @"",
             kKeyUsername:self.username ?: @"",
             kKeyImageIdentifier:self.imageIdentifier ?: @"",
             kKeyImageURL:self.imageURLString ?: @"",
             };
}

@end
