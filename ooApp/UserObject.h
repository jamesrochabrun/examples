//
//  UserObject.h
//  Oomami
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListObject.h"
#import "MediaItemObject.h"
#import "OONetworkManager.h"

static NSUInteger kUserObjectMaximumAboutTextLength = 140;

typedef enum: int {
    PARTICIPANT_TYPE_NONE = 0,
    PARTICIPANT_TYPE_CREATOR = 1,
    PARTICIPANT_TYPE_ORGANIZER = 2,
    PARTICIPANT_TYPE_ATTENDEE = 3,
} ParticipantType;

typedef enum: NSUInteger {
    USER_TYPE_NONE = 0,
    USER_TYPE_ADMIN = 1,
    USER_TYPE_NORMAL = 2,
    USER_TYPE_INACTIVE = 3,
    USER_TYPE_FOODIE = 4,
} UserType;

typedef enum: NSUInteger {
    PARTICIPANT_STATE_NONE = 0,
    PARTICIPANT_STATE_ATTENDING = 1, // accepted
    PARTICIPANT_STATE_NOT_ATTENDING = 2,// declined
    PARTICIPANT_STATE_NO_RESPONSE= 3,
    PARTICIPANT_STATE_MAYBE = 4,
} ParticipantState;

extern NSString *const kKeyUserID;
extern NSString *const kKeyUserFirstName;
extern NSString *const kKeyUserLastName;
extern NSString *const kKeyUserMiddleName;
extern NSString *const kKeyUserEmail;
extern NSString *const kKeyUserPhoneNumber;
extern NSString *const kKeyUserUsername;
extern NSString *const kKeyUserToken;
extern NSString *const kKeyUserGender;
extern NSString *const kKeyUserImageURL;
extern NSString *const kKeyUserImageIdentifier;
extern NSString *const kKeyUserParticipantType;
extern NSString *const kKeyUserParticipantState;
extern NSString *const kKeyUserAbout;
extern NSString *const kKeyUserPassword;

@interface UserObject : NSObject

@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, assign) UserType userType;
@property (nonatomic, assign) BOOL isFoodie, hasSpecialties;
@property (nonatomic, strong) NSArray *specialties;
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
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *facebookIdentifier;
@property (nonatomic, strong) NSString *facebookProfileImageURLString;// e.g. from FB.
@property (nonatomic, strong) NSString *imageIdentifier;// i.e. from OO.
@property (nonatomic, assign) NSInteger participantType, participantState;
@property (nonatomic, strong) MediaItemObject *mediaItem;

+ (UserObject *)userFromDict:(NSDictionary *)dict;
- (NSMutableDictionary *)dictionaryFromUser;

- (void)setUserProfilePhoto:(UIImage *)userProfilePhoto andUpload:(BOOL)doUpload;
- (UIImage *)userProfilePhoto;

- (NSUInteger)hash;

- (BOOL)isEqualToDeeply:(UserObject*) user;

- (void) refreshWithSuccess: (void (^)(BOOL changed))success
                   failure:(void (^)())failure;

- (AFHTTPRequestOperation *)refreshSpecialtiesWithSuccess:(void (^)(BOOL  changed))success
                                                      failure:(void (^)())failure;
@end

extern BOOL isUserObject (id  object);

