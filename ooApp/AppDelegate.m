//
//  AppDelegate.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <HockeySDK/HockeySDK.h>
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"
#import "OOAPI.h"
#import "DebugUtilities.h"
#import "LoginVC.h"
#import "Settings.h"
#import "NSData+Conversion.h"
#import "Common.h"
#import "ProfileVC.h"
#import "RestaurantVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Instabug/Instabug.h>
#import "NotificationObject.h"
#import "RestaurantListVC.h"
#import "ViewPhotoVC.h"
#import "iRate.h"
#import "NSString+Util.h"
#import "UserObject.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSURL *launchedURL;
@end

@implementation AppDelegate

+ (void)initialize {
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 15;
    [iRate sharedInstance].appStoreID = 1053373398;
    [iRate sharedInstance].eventsUntilPrompt = 5;
    [iRate sharedInstance].messageTitle = @"Enjoying Oomami?";
    [iRate sharedInstance].message = @"Take a moment to let everyone know by rating us in the app store. The more friends that use the app the more useful it becomes!";
//    [iRate sharedInstance].previewMode = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ANALYTICS_INIT();

#ifdef DEBUG
    id object= [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUsingStagingServer];
    if  (!object) {
        // RULE: For the debug build the default server is Staging.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsUsingStagingServer];
    }
    
    self.window.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
//    NSDictionary *notification;
//    
//    notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (!notification) {
//        UIAlertView *av = [UIAlertView new];
//        av.message = @"no remote not";
//        [av show];
//    } else {
////        UIAlertView *av = [UIAlertView new];
////        av.message = [NSString stringWithFormat:@"%@", notification] ;
////        [av show];
//
//        NotificationObject *n = [self parseNotification:notification];
//        if (n) {
//            [_notifications addObject:n];
//            message([NSString stringWithFormat:@"type=%lu id=%lu", (unsigned long)n.type, (unsigned long)n.identifier]);
//        }
//    }

    _launchedURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    
    // uncomment to test deep link
    //_launchedURL = [NSURL URLWithString:@"oomami://oomami/restaurant?id=1"];
    
    _usingStagingServer= [[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsUsingStagingServer];
    
#else
    #define INTERNAL_RELEASE

    #ifndef INTERNAL_RELEASE
        _usingStagingServer= NO;
    #else
        _usingStagingServer= YES;
    #endif
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
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [GMSServices provideAPIKey:kAPIKeyGoogleMaps];
    [Instabug startWithToken:kAPIKeyInstabug invocationEvent:IBGInvocationEventNone];
    [Instabug setIntroMessageEnabled:NO];
    
    //TODO: If we asked the user for remote notifications already then register for remote notifications. This needs to be done every lauch to get a new token
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [self registerForPushNotifications];
    }
    
    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"4be2767211390447c381617f13fc2437"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    self.imageForNoProfileSilhouette= [UIImage  imageNamed: @"No-Profile_Image.png"];
    
    [[UINavigationBar appearance] setBackgroundColor:UIColorRGBA(kColorNavBar)];
    [[UINavigationBar appearance] setTintColor:UIColorRGBA(kColorTextActive)];
    [[UIBarButtonItem appearance] setTintColor:UIColorRGBA(kColorTextActive)];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)clearCache
{
    NSURLCache*  cache= [NSURLCache sharedURLCache];
    [cache  removeAllCachedResponses];
}


- (void)registerForPushNotifications {
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        ANALYTICS_EVENT_OTHER(@"Notification");
//        UIAlertView *av = [UIAlertView new];
//        av.message = [NSString stringWithFormat:@"%@", userInfo] ;
//        [av show];

        NotificationObject *n = [self parseNotification:userInfo];
        if (n) {
            if (!_notifications) _notifications = [NSMutableArray array];
            [_notifications addObject:n];
        }
    
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
            [self processNotifications];
        }
    }
}

- (NotificationObject *)parseNotification:(NSDictionary *)info {
    NotificationObject *notif = [[NotificationObject alloc] init];
    notif.type = (NotificationObjectType)parseIntegerOrNullFromServer([info objectForKey:kKeyNotificationType]);
    notif.identifier = parseUnsignedIntegerOrNullFromServer([info objectForKey:kKeyNotificationID]);
    return notif;
}

- (void)setNc:(UINavigationController *)nc {
    if (_nc == nc) return;
    _nc = nc;
}

- (void)processNotifications {
    if (![self makeSureNCIsSet]) return;
    NotificationObject *notif =[_notifications firstObject];
    [_notifications removeObject:notif];

    ANALYTICS_EVENT_OTHER(@"ProcessNotification");
    
    switch (notif.type) {
        case kNotificationTypeViewUser:
            //show user profile
        {
            NSLog(@"Show user: %lu", (unsigned long)notif.identifier);
            [self showUserwithUserId:(unsigned long)notif.identifier];
        }
            break;
        case kNotificationTypeViewEvent:
            //show event
            //message([NSString stringWithFormat:@"Show event: %lu", (unsigned long)notif.identifier]);
            break;
        case kNotificationTypeViewList:
            //show list
        {
            NSLog(@"Show list: %lu", (unsigned long)notif.identifier);
            [self showList:(unsigned long)notif.identifier];
        }
            break;
        case kNotificationTypeViewRestaurant:
            //show restaurant
        {
            NSLog(@"Show restaurant: %lu", (unsigned long)notif.identifier);
            [self showRestaurant:(unsigned long)notif.identifier];
        }
            break;
        case kNotificationTypeViewMediaItem:
            //show restaurant
        {
            NSLog(@"Show media item: %lu", (unsigned long)notif.identifier);
            [self showMediaItem:(unsigned long)notif.identifier];
        }
            break;
        default:
            break;
    }
}

- (void)showRestaurant:(NSUInteger)restaurantID {
    if (![self makeSureNCIsSet]) return;

    __weak UINavigationController *weakNC = _nc;
    
    OOAPI *api = [[OOAPI alloc] init];
    
    [api getRestaurantWithID:[NSString stringWithFormat:@"%lu", (unsigned long)restaurantID] source:kRestaurantSourceTypeOomami success:^(RestaurantObject *restaurant) {
        if (restaurant) {
            RestaurantVC *vc = [[RestaurantVC alloc] init];
            vc.title = trimString(restaurant.name);
            vc.restaurant = restaurant;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakNC pushViewController:vc animated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)showMediaItem:(NSUInteger)mediaItemID {
    if (![self makeSureNCIsSet]) return;
    
    OOAPI *api = [[OOAPI alloc] init];
    __weak AppDelegate *weakSelf = self;
    
    [OOAPI getMediaItem:mediaItemID success:^(MediaItemObject *mio){
        [api getRestaurantWithID:[NSString stringWithFormat:@"%lu", (unsigned long)mio.restaurantID] source:kRestaurantSourceTypeOomami success:^(RestaurantObject *restaurant) {
            if (restaurant) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf launchViewPhoto:mio restaurant:restaurant originFrame:CGRectMake(0, 0, 0, 0)];
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
        ;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];

}

- (void)showUserwithUserId:(NSUInteger)userID {
    if (![self makeSureNCIsSet]) return;
    
    __weak UINavigationController *weakNC = _nc;
    
    [OOAPI getUserWithID:userID success:^(UserObject *user) {
        ProfileVC *vc = [[ProfileVC alloc] init];
        vc.userInfo = user;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakNC pushViewController:vc animated:YES];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)showUserWithUsername:(NSString *)username {
    if (![self makeSureNCIsSet]) return;
    
    __weak UINavigationController *weakNC = _nc;
    
    [OOAPI getUserWithUsername:username success:^(UserObject *user) {
        ProfileVC *vc = [[ProfileVC alloc] init];
        vc.userInfo = user;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakNC pushViewController:vc animated:YES];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)showList:(NSUInteger)listID {
    if (![self makeSureNCIsSet]) return;
    
    __weak UINavigationController *weakNC = _nc;
    
    OOAPI *api = [[OOAPI alloc] init];
    
    [api getList:listID success:^(ListObject *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RestaurantListVC *vc = [[RestaurantListVC alloc] init];
            [weakNC pushViewController:vc animated:YES];
            vc.title = list.name;
            vc.listItem = list;
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (BOOL)makeSureNCIsSet {
    UIViewController *vc = [_tabBar.viewControllers objectAtIndex:_tabBar.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        _nc = (UINavigationController *)vc;
    }
    
    if (!_nc) {
        NSLog(@"*** NC not set yet");
        return NO;
    }
    
    [_nc popToRootViewControllerAnimated:NO];
    return YES;
}

- (void)launchViewPhoto:(MediaItemObject*)mediaObject restaurant:(RestaurantObject *)restaurant originFrame:(CGRect)originFrame
{
    ViewPhotoVC *vc = [[ViewPhotoVC alloc] init];
    vc.originRect = CGRectZero;// originRect;
    vc.mio = mediaObject;
    vc.restaurant = restaurant;
    vc.items = nil;
    vc.currentIndex = 0;//indexPath.row;
    [_nc pushViewController:vc animated:YES];
}

- (void)testRemoteNotification {
    NotificationObject *n = [[NotificationObject alloc] init];
    n.identifier = 117128;
    n.type = kNotificationTypeViewMediaItem;
    [_notifications addObject:n];
    [self processNotifications];
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSLog(@"DEV TOKEN: %@", devToken);
    
    [OOAPI uploadAPNSDeviceToken:[devToken hexadecimalString] success:^(id response) {
        NSLog(@"SUCCESS IN UPLOADING DEV TOKEN");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE IN UPLOADING DEV TOKEN");
    }];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in remote notification registration. Error: %@", err);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSString *sourceApplication = [options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey];
    
    if ([[FBSDKApplicationDelegate sharedInstance] application:app
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:nil
         ])
    {
        ANALYTICS_EVENT_OTHER(@"FacebookLink");
        return YES;
    } else {
        //Handle deep link to Oomami
        if ([[url scheme] isEqualToString:@"oomami"]) {
/* deep linking logic handles
        oomami://oomami/profile?username=<username>
        oomami://oomami/restaurant?id=<restaurantID>
        oomami://oomami/mediaItem?id=<mediaItemID>
        oomami://oomami/list?id=<listID>
*/
            BOOL result = [self openLink:url];
            return result;
        }
        
        return NO;
    }
}

- (BOOL)openLink:(NSURL *)url {
//    NSString *host = [url host];
    NSString *page = [url path];
    NSString *query = [url query];
    NSDictionary *parameters = [query parseURLParams];
    
    ANALYTICS_EVENT_OTHER(@"OomamiDeepLink");
    BOOL result = NO;
    
    if ([page isEqualToString:@"/profile"]) {
        NSString *username = [parameters valueForKey:kKeyUserUsername];
        if ([username length]) {
            [self showUserWithUsername:username];
        } else {
            [self showUserwithUserId:parseUnsignedIntegerOrNullFromServer([parameters valueForKey:@"id"])];
        }
        result = YES;
    } else if ([page isEqualToString:@"/restaurant"]) {
        [self showRestaurant:parseUnsignedIntegerOrNullFromServer([parameters valueForKey:@"id"])];
        result = YES;
    } else if ([page isEqualToString:@"/mediaItem"]) {
        [self showMediaItem:parseUnsignedIntegerOrNullFromServer([parameters valueForKey:@"id"])];
        result = YES;
    } else if ([page isEqualToString:@"/list"]) {
        [self showList:parseUnsignedIntegerOrNullFromServer([parameters valueForKey:@"id"])];
        result = YES;
    }
    return result;
}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[Settings sharedInstance] save];
    ANALYTICS_EVENT_OTHER(@"Background");
    ANALYTICS_FORCE_SYNC();
    
    _dateLeft = [NSDate date];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ANALYTICS_EVENT_OTHER(@"Foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    
//This should not be enabled in production
    //[FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorAppEvents];
    


//    [self testRemoteNotification];
}

- (void)openLink {
    if (_launchedURL) {
        [self openLink:_launchedURL];
        _launchedURL = nil;
    } else if ([_notifications count]) {
        [self processNotifications];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // NOTE: I've found attempting to save data from here results in data getting lost. -ZS
    
    ANALYTICS_EVENT_OTHER(@"Terminate");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[Settings sharedInstance] save];
    ANALYTICS_EVENT_OTHER(@"Memory");
    ANALYTICS_FORCE_SYNC();
}

@end
