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
#import "LocationManager.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    _usingStagingServer= YES;
    self.diagnosticLogString= [NSMutableString new ];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *applicationName = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    [_diagnosticLogString appendFormat: @"%@\r",platformString()];
    [_diagnosticLogString appendFormat:  @"%@ %@ build %@\r\r",applicationName,majorVersion, minorVersion];
#else
    _usingStagingServer= NO;
#endif
    
    // Override point for customization after application launch.
    NSLog(@"application finished launching");
//    [DebugUtilities displayAllFonts];

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                            diskCapacity:10 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    CLLocationCoordinate2D location= [[Settings sharedInstance] mostRecentLocation ];
    NSLog  (@"Last known location: %g,%g", location.latitude,location.longitude);
    [_diagnosticLogString appendFormat: @"LAST LOCATION: %.6g,%.6g\r", location.latitude,location.longitude];

    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [GMSServices provideAPIKey:kAPIKeyGoogleMaps];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"4be2767211390447c381617f13fc2437"];
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator
     authenticateInstallation];

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[Settings sharedInstance] save];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
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
    [[Settings sharedInstance] save];

    [_diagnosticLogString appendString: @"MEMORY WARNING\r"];
}

@end
