//
//  AppDelegate.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <HockeySDK/HockeySDK.h>
#import "AppDelegate.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "LoginVC.h"
#import "Settings.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    _usingStagingServer= YES;
    self.diagnosticLogString= [NSMutableString new ];
    ENTRY;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *applicationName = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    [_diagnosticLogString appendFormat: @"PLATFORM %@\r",platformString()];
    [_diagnosticLogString appendFormat:  @"APPLICATION %@ %@ build %@\r\r",applicationName,majorVersion, minorVersion];
#else
    _usingStagingServer= NO;
#endif
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Override point for customization after application launch.
    NSLog(@"application finished launching");
//    [DebugUtilities displayAllFonts];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                            diskCapacity:100 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    CLLocationCoordinate2D location= [[Settings sharedInstance] mostRecentLocation ];
    NSLog  (@"Last known location: %g,%g", location.latitude,location.longitude);
    [_diagnosticLogString appendFormat: @"LAST LOCATION: %.6g,%.6g\r", location.latitude,location.longitude];

    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [GMSServices provideAPIKey:kAPIKeyGoogleMaps];
    
    //TODO: If we asked the user for remote notifications already then register for remote notifications. This needs to be done every lauch to get a new token
    //[self registerForPushNotifications];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"4be2767211390447c381617f13fc2437"];
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator
     authenticateInstallation];
    
    self.imageForNoProfileSilhouette= [UIImage  imageNamed: @"No-Profile_Image.png"];

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)registerForPushNotifications {
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSLog(@"device token: %@", devToken);
//    const void *devTokenBytes = [devToken bytes];

    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userID = userInfo.userID;

//    TODO: store that we asked in settings so that we can register again on launch in the future
//    TODO: send the device token and user ID to the OO server using OOAPI
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in remote notification registration. Error: %@", err);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    ENTRY;
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ])
    {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    ENTRY;
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ENTRY;
   [[Settings sharedInstance] save];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    ENTRY;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    ENTRY;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[Settings sharedInstance] save];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    ENTRY;
    [[Settings sharedInstance] save];

}

@end
