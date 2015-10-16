//
//  UserObject.h
//  Oomami
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListObject.h"

typedef enum: int {
    PARTICIPANT_TYPE_NONE = 0,
    PARTICIPANT_TYPE_CREATOR = 1,
    PARTICIPANT_TYPE_ORGANIZER = 2,
    PARTICIPANT_TYPE_ATTENDEE = 3,
} ParticipantType;

typedef enum: int {
    PARTICIPANT_STATE_NONE = 0,
    PARTICIPANT_STATE_ATTENDING  = 1, // accepted
    PARTICIPANT_STATE_NOT_ATTENDING = 2,// declined
    PARTICIPANT_STATE_NO_RESPONSE= 3,
    PARTICIPANT_STATE_MAYBE = 4,
} ParticipantState;

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
@property (nonatomic, assign) NSInteger participantType;
@property (nonatomic, assign) BOOL isAttending;

+ (UserObject *)userFromDict:(NSDictionary *)dict;
- (NSDictionary *)dictionaryFromUser;

- (void)setUserProfilePhoto:(UIImage *)userProfilePhoto;
- (UIImage *)userProfilePhoto;

- (NSUInteger)hash;

@end
