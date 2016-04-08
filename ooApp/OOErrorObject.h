//
//  OOErrorObject.h
//  ooApp
//
//  Created by Anuj Gujar on 3/28/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyError;
extern NSString *const kKeyErrorDescription;
extern NSString *const kKeyErrorType;

/*
 Error Codes:
 900 - Unique Constraint Error
 901 - Invalid Password
 902 - Invalid Username
 903 - Invalid Email Address
 904 - Missing Body Params For User Creation
 ​
 800 - Failed Authorization
 ​
 700 - User Not Found
 */

typedef enum : NSUInteger {
    //user not found
    kOOErrorCodeTypeUserNotFound = 700,
    
    //failed authorization - i.e. user|password incorrect
    kOOErrorCodeTypeAuthorizationFailed = 800,
    
    kOOErrorCodeTypeConnectingAccountToUnverifiedUser = 801,
    
    kOOErrorCodeTypeFacebookNeedEmailPermission = 802,
    
    //unique constraint - e.g. username in use, email in use
    kOOErrorCodeTypeUniqueConstraint = 900,
    
    //invalid password - e.g. password not long enough
    kOOErrorCodeTypeInvalidPassword = 901,
    
    //invalid username - e.g. username too short or to long
    kOOErrorCodeTypeInvalidUsername = 902,
    
    //invalid email - e.g. not a real email
    kOOErrorCodeTypeInvalidEmail = 903,
    
    //missing information on user creation
    kOOErrorCodeTypeMissingInformation = 904,
} OOErrorCodeType;

@interface OOErrorObject : NSObject

@property (nonatomic, strong) NSString *errorDescription;
@property (nonatomic) OOErrorCodeType type;

+ (OOErrorObject *)errorFromDict:(NSDictionary *)dict;

@end
