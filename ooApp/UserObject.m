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
#import "AppDelegate.h"
#import "SpecialtyObject.h"

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
NSString *const kKeyUserAbout = @"about";
NSString *const kKeyUserIsFoodie = @"is_blogger";
NSString *const kKeyUserWebsite = @"website";
NSString *const kKeyUserType = @"user_type";
NSString *const kKeyUserPassword = @"password";
NSString *const kKeyUserIsVerified = @"is_verified";
NSString *const kKeyUserIsOfficial = @"is_official";

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

- (BOOL)isEqualToDeeply:(UserObject*) other;
{
    if  ( self.userID != other.userID)  return NO;
    if  ( self.userType != other.userType)  return NO;
    if  ( self.hasSpecialties != other.hasSpecialties)  return NO;
    if  ( self.isFoodie != other.isFoodie)  return NO;
    if  ( self.isOfficial != other.isOfficial)  return NO;
    
    if  ( self.mediaItem.mediaItemId != other.mediaItem.mediaItemId)  return NO;
    if  (![(self.mediaItem.url ?:  @"") isEqualToString: (other.mediaItem.url?:  @"")])  return NO;
    if  (![(self.mediaItem.reference ?:  @"") isEqualToString: (other.mediaItem.reference?:  @"")])  return NO;
    if  (![(_firstName ?:  @"") isEqualToString: (other.firstName?:  @"")])  return NO;
    if  (![(self.lastName?:  @"") isEqualToString: (other.lastName?:  @"")])  return NO;
    if  (![(self.email?:  @"") isEqualToString: (other.email?:  @"")])  return NO;
    if  (![(self.facebookIdentifier?:  @"") isEqualToString: (other.facebookIdentifier?:  @"")])  return NO;
    if  (![(self.about?:  @"") isEqualToString: (other.about?:  @"")])  return NO;
    if  (![(self.phoneNumber?:  @"") isEqualToString: (other.phoneNumber?:  @"")])  return NO;
    if  (![(self.gender?:  @"") isEqualToString: (other.gender?:  @"")])  return NO;
    if  (![(self.username?:  @"") isEqualToString: (other.username?:  @"")])  return NO;
    if  (![(self.website?:  @"") isEqualToString: (other.website?:  @"")])  return NO;

    return YES;
}

//------------------------------------------------------------------------------
// Name:    +userFromDict
// Purpose: Instantiates user object from user dictionary.
//------------------------------------------------------------------------------
+ (UserObject *)userFromDict:(NSDictionary *)dict
{
    UserObject *user =[[UserObject alloc] init];
    user.userID = parseUnsignedIntegerOrNullFromServer(dict [kKeyUserID]);
    user.firstName = parseStringOrNullFromServer(dict [kKeyUserFirstName]);
    user.middleName = parseStringOrNullFromServer(dict [kKeyUserMiddleName]);
    user.lastName = parseStringOrNullFromServer(dict [kKeyUserLastName]);
    user.email = parseStringOrNullFromServer(dict [kKeyUserEmail]);
    user.phoneNumber = parseStringOrNullFromServer(dict [kKeyUserPhoneNumber]);
    user.backendAuthorizationToken = parseStringOrNullFromServer(dict [kKeyUserToken]);
    user.gender = parseStringOrNullFromServer(dict [kKeyUserGender]);
    user.username = parseStringOrNullFromServer(dict [kKeyUserUsername]);
    user.facebookProfileImageURLString = parseStringOrNullFromServer(dict [kKeyUserImageURL]);
    user.imageIdentifier = parseStringOrNullFromServer(dict [kKeyUserImageIdentifier]);
    user.participantType = parseIntegerOrNullFromServer(dict[kKeyUserParticipantType]);
    user.participantState = parseIntegerOrNullFromServer(dict[kKeyUserParticipantState]);
    user.about = parseStringOrNullFromServer(dict [kKeyUserAbout]);
    user.website = parseStringOrNullFromServer(dict [kKeyUserWebsite]);
    user.userType = parseNumberOrNullFromServer(dict [kKeyUserType]);
    user.isVerified = parseBoolOrNullFromServer(dict [kKeyUserIsVerified]);
    user.isFoodie = user.userType == kUserTypeFoodie;
    user.specialties= nil;
    user.isOfficial = parseBoolOrNullFromServer(dict [kKeyUserIsOfficial]);

    if (user.about.length > kUserObjectMaximumAboutTextLength) {
        user.about= [user.about substringToIndex: kUserObjectMaximumAboutTextLength-1];
    }
    
    // RULE: If the server referred to the current user and
    // we have more information about the current user then fill it in.
    //
    if  (!user.facebookProfileImageURLString) {
        UserObject* currentUser= [Settings sharedInstance].userObject;
        if  (user.userID==currentUser.userID ) {
            user.facebookProfileImageURLString= currentUser.facebookProfileImageURLString;
        }
    }
    if (dict [kKeyUserMediaItem]) {
        user.mediaItem = [MediaItemObject mediaItemFromDict:dict [kKeyUserMediaItem]];
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
             kKeyUserAbout: self.about ?: @"",
             kKeyUserPhoneNumber:self.phoneNumber ?: @"",
             kKeyUserToken:self.backendAuthorizationToken ?: @"",
             kKeyUserGender:self.gender ?: @"",
             kKeyUserUsername:self.username ?: @"",
             kKeyUserImageIdentifier:self.imageIdentifier ?: @"",
             kKeyUserImageURL:self.facebookProfileImageURLString ?: @"",
             kKeyUserParticipantType: @(self.participantType),
             kKeyUserIsFoodie: @(self.isFoodie),
             kKeyUserParticipantState: @(self.participantState),
             kKeyUserWebsite: self.website ?:  @"",
             kKeyUserType:  @(self.userType),
             
             // Some data are not uploaded.
             
             }.mutableCopy;
    
    if  (self.mediaItem ) {
        dictionary[kKeyUserMediaItem]= [self.mediaItem dictionaryOfMediaItem];
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

//AUG: Is this code required?
- (AFHTTPRequestOperation *)refreshSpecialtiesWithSuccess:(void (^)(BOOL))success
                                                  failure:(void (^)())failure;
{
    __weak UserObject *weakSelf = self;
    return [OOAPI getUserSpecialties:self.userID
                 success:^(NSArray *specialties) {
                     NSUInteger previousCount=weakSelf.specialties.count;
                     BOOL previousFlag=weakSelf.hasSpecialties;
                     weakSelf.specialties = specialties;
                     weakSelf.hasSpecialties = specialties.count>0;
                     NSLog (@"USER HAS %lu SPECIALTIES", (unsigned long)specialties.count);
                     success( previousCount != specialties.count  ||
                             previousFlag != weakSelf.hasSpecialties);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure();
                 }];
}

//AUG: Is this code required?
- (void)refreshWithSuccess:(void (^)(BOOL ))success
                    failure:(void (^)())failure;
{
    __weak UserObject *weakSelf = self;
    [OOAPI getUserWithID:self.userID
                  success:^(UserObject *user) {
                      BOOL changed= ![weakSelf isEqualToDeeply: user];
                      
                      weakSelf.mediaItem = user.mediaItem;
                      weakSelf.userID = user.userID;
                      weakSelf.about = user.about;
                      weakSelf.firstName = user.firstName;
                      weakSelf.middleName = user.middleName;
                      weakSelf.lastName = user.lastName ;
                      weakSelf.email = user.email;
                      weakSelf.phoneNumber = user.phoneNumber;
                      weakSelf.gender = user.gender;
                      weakSelf.isFoodie = user.isFoodie;
                      weakSelf.username = user.username;
                      weakSelf.facebookProfileImageURLString = user.facebookProfileImageURLString;
                      weakSelf.imageIdentifier = user.imageIdentifier;
                      weakSelf.website = user.website;
                      weakSelf.userType = user.userType;
                      weakSelf.isOfficial = user.isOfficial;
                    
                      success( changed);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      failure();
                  }];
}

- (UIImage *)userProfilePhoto;
{
    return profilePhoto;
}

@end
