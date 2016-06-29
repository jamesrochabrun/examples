//
//  AppLogObject.m
//  ooApp
//
//  Created by Anuj Gujar on 6/15/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "AppLogObject.h"
#import "LocationManager.h"

NSString *const kKeyAppLogAppLogID = @"app_log_id";
NSString *const kKeyAppLogDeviceType = @"device_type"; //iPhone, etc
NSString *const kKeyAppLogOS = @"os"; //iOS version
NSString *const kKeyAppLogBuildNumber = @"build_number"; //build number
NSString *const kKeyAppLogAppVersion = @"app_version";
NSString *const kKeyAppLogLatitude = @"latitude";
NSString *const kKeyAppLogLongitude = @"longitude";
NSString *const kKeyAppLogUserID = @"user_id";
NSString *const kKeyAppLogOriginScreen = @"origin_screen";
NSString *const kKeyAppLogEventType = @"event_type";
NSString *const kKeyAppLogP1 = @"p1";
NSString *const kKeyAppLogP2 = @"p2";
NSString *const kKeyAppLogP3 = @"p3";
NSString *const kKeyAppLogP4 = @"p4";
NSString *const kKeyAppLogP5 = @"p5";

//App Log Events
NSString *const kAppEventScreenView = @"Screen View";
NSString *const kAppEventPhotoYummed = @"Photo Yummed";
NSString *const kAppEventPhotoUploaded = @"Photo Uploaded";
NSString *const kAppEventSharePressed = @"Share Pressed";
NSString *const kAppEventListCreated = @"List Created";
NSString *const kAppEventPlaceAddedToList = @"Place Added To List";
NSString *const kAppEventUserFollowed = @"User Followed";
NSString *const kAppEventItemShared = @"Item Shared";

NSString *const kAppEventParameterKeyShareType = @"Share Type";
NSString *const kAppEventParameterKeyUploadType = @"Upload Type";
NSString *const kAppEventParameterKeyListType = @"List Type";

NSString *const kAppEventParameterValueYes = @"Yes";
NSString *const kAppEventParameterValueNo = @"No";
NSString *const kAppEventParameterValuePlace = @"Place";
NSString *const kAppEventParameterValueList = @"List";
NSString *const kAppEventParameterValueItem = @"Item";
NSString *const kAppEventParameterValueUser = @"User";
NSString *const kAppEventParameterValueEvent = @"Event";
NSString *const kAppEventParameterValueCustomList = @"Custom List";
NSString *const kAppEventParameterValueSpecialList = @"Special List";

@interface AppLogObject ()
- (void)logEvent:(NSString *)eventType originScreen:(NSString *)originScreen p1:(NSString *)p1 p2:(NSString *)p2 p3:(NSString *)p3 p4:(NSString *)p4 p5:(NSString *)p5;
@end

@implementation AppLogObject

- (void)logEvent:(NSString *)eventType originScreen:(NSString *)originScreen p1:(NSString *)p1 p2:(NSString *)p2 p3:(NSString *)p3 p4:(NSString *)p4 p5:(NSString *)p5 {
    
    UserObject *currentUser = [Settings sharedInstance].userObject;
    if (!currentUser || !eventType) return;
    
    UIDevice *dev = [UIDevice currentDevice];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CLLocationCoordinate2D location = [LocationManager sharedInstance].currentUserLocation;
    
    self.deviceType = [Common platformRawString];// dev.model;
    self.OS = [NSString stringWithFormat:@"%@ %@", dev.systemName, dev.systemVersion];
    self.buildNumber = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.location = location;
    self.userID = currentUser.userID;
    self.eventType = eventType;
    self.originScreen = originScreen?originScreen:@"";
    self.p1 = p1?p1:@"";
    self.p2 = p2?p2:@"";
    self.p3 = p3?p3:@"";
    self.p4 = p4?p4:@"";
    self.p5 = p5?p5:@"";

    NSLog(@"App Log: %@ %@", self.eventType, self.originScreen);

    [OOAPI sendAppLog:self success:^{
        NSLog(@"event logged: %@", self.eventType);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"could not log event: %@", self.eventType);
    }];
}

+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen {
    AppLogObject *alo = [AppLogObject new];
    [alo logEvent:eventType originScreen:originScreen p1:nil p2:nil p3:nil p4:nil p5:nil];
}

+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen p1:(NSString *_Nullable)p1 {
    AppLogObject *alo = [AppLogObject new];
    [alo logEvent:eventType originScreen:originScreen p1:p1 p2:nil p3:nil p4:nil p5:nil];
}

+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen p1:(NSString *_Nullable)p1 p2:(NSString *_Nullable)p2 {
    AppLogObject *alo = [AppLogObject new];
    [alo logEvent:eventType originScreen:originScreen p1:p1 p2:p2 p3:nil p4:nil p5:nil];
}

+ (void)logEvent:(NSString *_Nonnull)eventType originScreen:(NSString *_Nullable)originScreen p1:(NSString *_Nullable)p1 p2:(NSString *_Nullable)p2 p3:(NSString *_Nullable)p3 {
    AppLogObject *alo = [AppLogObject new];
    [alo logEvent:eventType originScreen:originScreen p1:p1 p2:p2 p3:p3 p4:nil p5:nil];
}



@end
