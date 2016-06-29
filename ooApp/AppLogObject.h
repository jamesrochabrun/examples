//
//  AppLogObject.h
//  ooApp
//
//  Created by Anuj Gujar on 6/15/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyAppLogAppLogID;
extern NSString *const kKeyAppLogDeviceType;
extern NSString *const kKeyAppLogOS;
extern NSString *const kKeyAppLogBuildNumber;
extern NSString *const kKeyAppLogAppVersion;
extern NSString *const kKeyAppLogLatitude;
extern NSString *const kKeyAppLogLongitude;
extern NSString *const kKeyAppLogUserID;
extern NSString *const kKeyAppLogOriginScreen;
extern NSString *const kKeyAppLogEventType;
extern NSString *const kKeyAppLogP1;
extern NSString *const kKeyAppLogP2;
extern NSString *const kKeyAppLogP3;
extern NSString *const kKeyAppLogP4;
extern NSString *const kKeyAppLogP5;

@interface AppLogObject : NSObject

@property (nonatomic) NSUInteger appLogID;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *OS;
@property (nonatomic, strong) NSString *buildNumber;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) NSUInteger userID;
@property (nonatomic, strong) NSString *originScreen;
@property (nonatomic, strong) NSString *eventType;
@property (nonatomic, strong) NSString *p1;
@property (nonatomic, strong) NSString *p2;
@property (nonatomic, strong) NSString *p3;
@property (nonatomic, strong) NSString *p4;
@property (nonatomic, strong) NSString *p5;

//App Log Events
extern NSString *const kAppEventScreenView;
extern NSString *const kAppEventPhotoYummed;
extern NSString *const kAppEventPhotoUploaded;
extern NSString *const kAppEventSharePressed;
extern NSString *const kAppEventListCreated;
extern NSString *const kAppEventPlaceAddedToList;
extern NSString *const kAppEventUserFollowed;
extern NSString *const kAppEventItemShared;

extern NSString *const kAppEventParameterKeyShareType;
extern NSString *const kAppEventParameterKeyUploadType;
extern NSString *const kAppEventParameterKeyListType;

extern NSString *const kAppEventParameterValueYes;
extern NSString *const kAppEventParameterValueNo;
extern NSString *const kAppEventParameterValuePlace;
extern NSString *const kAppEventParameterValueList;
extern NSString *const kAppEventParameterValueItem;
extern NSString *const kAppEventParameterValueUser;
extern NSString *const kAppEventParameterValueEvent;
extern NSString *const kAppEventParameterValueCustomList;
extern NSString *const kAppEventParameterValueSpecialList;


- (void)logEvent:(NSString *)eventType originScreen:(NSString *)originScreen p1:(NSString *)p1 p2:(NSString *)p2 p3:(NSString *)p3 p4:(NSString *)p4 p5:(NSString *)p5;

+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen;
+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen p1:(NSString *_Nullable)p1;
+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen p1:(NSString *_Nullable)p1 p2:(NSString *_Nullable)p2;
+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen p1:(NSString *_Nullable)p1 p2:(NSString *_Nullable)p2 p3:(NSString *_Nullable)p3;
@end
