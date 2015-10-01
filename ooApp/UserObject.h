//
//  UserObject.h
//  Oomami
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListObject.h"

@interface UserObject : NSObject

@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *backendAuthorizationToken;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *facebookIdentifier;
@property (nonatomic, strong) NSString *imageURLString;// e.g. from FB.
@property (nonatomic, strong) NSString *imageIdentifier;// i.e. from OO.

+ (UserObject *)userFromDict:(NSDictionary *)dict;
- (NSDictionary*) dictionaryFromUser;

@end
