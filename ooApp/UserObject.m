//
//  UserObject.m
//  Oomami
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UserObject.h"
#import "OOAPI.h"
#import "Settings.h"

const NSInteger kHashUser= 0x40000000;

NSString *const kKeyID = @"user_id";
NSString *const kKeyFirstName = @"first_name";
NSString *const kKeyLastName = @"last_name";
NSString *const kKeyMiddleName = @"middle_name";
NSString *const kKeyEmail = @"email";
NSString *const kKeyPhoneNumber = @"phone_number";
NSString *const kKeyUsername = @"username";
NSString *const kKeyToken = @"backend_auth_token";
NSString *const kKeyGender = @"gender";
NSString *const kKeyImageURL = @"image_url";
NSString *const kKeyImageIdentifier = @"image_identifier";
NSString *const kKeyParticipantType = @"participant_type";
NSString *const kKeyParticipantState = @"participant_state";

@interface UserObject()

@end

@implementation UserObject
{
    UIImage *profilePhoto;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
     }
    return self;
}

- (NSUInteger)hash;
{
    return kHashUser + (_userID & 0xffffff);
}

- (BOOL)isEqual: (NSObject*)other
{
    return self.hash == other.hash;
}

//------------------------------------------------------------------------------
// Name:    +userFromDict
// Purpose: Instantiates user object from user dictionary.
//------------------------------------------------------------------------------
+ (UserObject *)userFromDict:(NSDictionary *)dict
{
    UserObject *user =[[UserObject alloc] init];
    user.userID = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyID] );
    user.firstName = parseStringOrNullFromServer( [dict objectForKey:kKeyFirstName] );
    user.middleName = parseStringOrNullFromServer( [dict objectForKey:kKeyMiddleName] );
    user.lastName = parseStringOrNullFromServer( [dict objectForKey:kKeyLastName] );
    user.email = parseStringOrNullFromServer( [dict objectForKey:kKeyEmail] );
    user.phoneNumber = parseStringOrNullFromServer( [dict objectForKey:kKeyPhoneNumber]);
    user.backendAuthorizationToken = parseStringOrNullFromServer( [dict objectForKey:kKeyToken]);
    user.gender =parseStringOrNullFromServer( [dict objectForKey:kKeyGender] );
    user.username= parseStringOrNullFromServer( [dict objectForKey:kKeyUsername] );
    user.imageURLString= parseStringOrNullFromServer( [dict objectForKey:kKeyImageURL] );
    user.imageIdentifier= parseStringOrNullFromServer( [dict objectForKey:kKeyImageIdentifier] );
    user.participantType = parseIntegerOrNullFromServer(dict [kKeyParticipantType]);
    user.participantState =parseIntegerOrNullFromServer(dict [kKeyParticipantState]);
    
    // RULE: If the server referred to the current user and
    // we have more information about the current user then fill it in.
    //
    if  (!user.imageURLString) {
        UserObject* currentUser= [Settings sharedInstance].userObject;
        if  (user.userID==currentUser.userID ) {
            user.imageURLString= currentUser.imageURLString;
        }
    }
    
    return user;
}

//------------------------------------------------------------------------------
// Name:    dictionaryFromUser
// Purpose: Provides dict from user object.
//------------------------------------------------------------------------------
- (NSDictionary *)dictionaryFromUser;
{
    return @{
             kKeyID : @(self.userID ),
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
             kKeyParticipantType: @(self.participantType),
             kKeyParticipantState: @(self.participantState)
             
             // Some data are not uploaded.
             
             };
}

- (void) setUserProfilePhoto:(UIImage *)userProfilePhoto;
{
    if (!userProfilePhoto) {
        return;
    }
    
    profilePhoto= userProfilePhoto;
#if 0
    [OOAPI uploadUserPhoto:profilePhoto //NOTE: upoading the photo everytime floods S3 with images we don't need
                   success:^() {
                       NSLog (@"SUCCEEDED IN UPLOADING PROFILE PHOTO.");
                   }
                   failure:^(NSError *e) {
                       NSLog (@"UNABLE TO UPLOAD PROFILE PHOTO.");
                   }];
#endif
}

- (UIImage *)userProfilePhoto;
{
    return profilePhoto;
}

@end
