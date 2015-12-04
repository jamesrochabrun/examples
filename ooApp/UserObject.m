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

NSString *const kKeyUserID = @"user_id";
NSString *const kKeyUserFirstName = @"first_name";
NSString *const kKeyUserLastName = @"last_name";
NSString *const kKeyUserMiddleName = @"middle_name";
NSString *const kKeyUserEmail = @"email";
NSString *const kKeyUserPhoneNumber = @"phone_number";
NSString *const kKeyUserUsername = @"username";
NSString *const kKeyUserToken = @"backend_auth_token";
NSString *const kKeyUserGender = @"gender";
NSString *const kKeyUserImageURL = @"image_url";
NSString *const kKeyUserImageIdentifier = @"image_identifier";
NSString *const kKeyUserParticipantType = @"participant_type";
NSString *const kKeyUserParticipantState = @"participant_state";
NSString *const kKeyUserMediaItem = @"media_item";

@interface UserObject()

@end

@implementation UserObject
{
    UIImage *profilePhoto;
}

BOOL isUserObject (id  object)
{
    return [ object isKindOfClass:[UserObject  class]];
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
    user.userID = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyUserID]);
    user.firstName = parseStringOrNullFromServer([dict objectForKey:kKeyUserFirstName]);
    user.middleName = parseStringOrNullFromServer([dict objectForKey:kKeyUserMiddleName]);
    user.lastName = parseStringOrNullFromServer([dict objectForKey:kKeyUserLastName]);
    user.email = parseStringOrNullFromServer([dict objectForKey:kKeyUserEmail]);
    user.phoneNumber = parseStringOrNullFromServer([dict objectForKey:kKeyUserPhoneNumber]);
    user.backendAuthorizationToken = parseStringOrNullFromServer([dict objectForKey:kKeyUserToken]);
    user.gender = parseStringOrNullFromServer([dict objectForKey:kKeyUserGender]);
    user.username = parseStringOrNullFromServer([dict objectForKey:kKeyUserUsername]);
    user.facebookProfileImageURLString = parseStringOrNullFromServer([dict objectForKey:kKeyUserImageURL]);
    user.imageIdentifier = parseStringOrNullFromServer([dict objectForKey:kKeyUserImageIdentifier]);
    user.participantType = parseIntegerOrNullFromServer(dict[kKeyUserParticipantType]);
    user.participantState = parseIntegerOrNullFromServer(dict[kKeyUserParticipantState]);
    
    // RULE: If the server referred to the current user and
    // we have more information about the current user then fill it in.
    //
    if  (!user.facebookProfileImageURLString) {
        UserObject* currentUser= [Settings sharedInstance].userObject;
        if  (user.userID==currentUser.userID ) {
            user.facebookProfileImageURLString= currentUser.facebookProfileImageURLString;
        }
    }
    if ([dict objectForKey:kKeyUserMediaItem]) {
        user.mediaItem = [MediaItemObject mediaItemFromDict:[dict objectForKey:kKeyUserMediaItem]];
    }
    
    return user;
}

//------------------------------------------------------------------------------
// Name:    dictionaryFromUser
// Purpose: Provides dict from user object.
//------------------------------------------------------------------------------
- (NSMutableDictionary *)dictionaryFromUser;
{
    NSMutableDictionary*dictionary=  @{
             kKeyUserID : @(self.userID ),
             kKeyUserMiddleName:self.middleName ?: @"",
             kKeyUserFirstName:self.firstName ?: @"",
             kKeyUserLastName:self.lastName ?: @"",
             kKeyUserEmail: self.email ?: @"",
             kKeyUserPhoneNumber:self.phoneNumber ?: @"",
             kKeyUserToken:self.backendAuthorizationToken ?: @"",
             kKeyUserGender:self.gender ?: @"",
             kKeyUserUsername:self.username ?: @"",
             kKeyUserImageIdentifier:self.imageIdentifier ?: @"",
             kKeyUserImageURL:self.facebookProfileImageURLString ?: @"",
             kKeyUserParticipantType: @(self.participantType),
             kKeyUserParticipantState: @(self.participantState)
             
             // Some data are not uploaded.
             
             }.mutableCopy;
    
    if  (self.mediaItem ) {
        dictionary[kKeyUserMediaItem]= [MediaItemObject dictionaryOfMediaItem];
    }
    
    return dictionary;
}

- (void)setUserProfilePhoto:(UIImage *)userProfilePhoto andUpload:(BOOL)doUpload
{
    if (!userProfilePhoto) {
        return;
    }
    
    profilePhoto= userProfilePhoto;
    
    if (doUpload) {
        // NOTE: The caller makes sure this is seldomly called.

        UserObject *user = [Settings sharedInstance].userObject;
        if (user.userID) {
            [OOAPI uploadPhoto:profilePhoto
                        forObject:[Settings sharedInstance].userObject
                   success:^() {
                       NSLog (@"SUCCEEDED IN UPLOADING PROFILE PHOTO.");
                   }
                   failure:^(NSError *e) {
                       NSLog (@"UNABLE TO UPLOAD PROFILE PHOTO.");
                   }];
        }
    }
}

- (void) refreshWithSuccess: (void (^)())success
                    failure:(void (^)())failure;
{
    [OOAPI getUserWithID:self.userID
                  success:^(UserObject *user) {
                      self.mediaItem=user.mediaItem;
                      self.userID= user.userID ;
                      self.firstName=  user.firstName;
                      self.middleName=  user.middleName;
                      self.lastName=  user.lastName ;
                      self.email=  user.email;
                      self.phoneNumber=  user.phoneNumber;
                      self.gender= user.gender;
                      self.username= user.username;
                      self.facebookProfileImageURLString= user.facebookProfileImageURLString;
                      self.imageIdentifier= user.imageIdentifier;
                    
                      success();
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      failure();
                  }];
}

- (UIImage *)userProfilePhoto;
{
    return profilePhoto;
}

@end
