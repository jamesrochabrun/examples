//
//  MenuTVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/26/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "MenuTVC.h"
#import "MenuTVCell.h"
#import "MenuObject.h"
#import "SWRevealViewController.h"
#import "ProfileVC.h"
#import "SettingsVC.h"
#import "WhatsNewVC.h"
#import "DefaultVC.h"
#import "FeedVC.h"
#import "PlayVC.h"
#import "ExploreVC.h"
#import "DiagnosticVC.h"
#import "SearchVC.h"
#import "EventsListVC.h"
#import "Common.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "ConnectVC.h"
#import "FoodFeedVC.h"

@interface MenuTVC ()
@property (nonatomic, strong) NSMutableArray *menuItems;
@end

static NSString * const cellIdentifier = @"menuCell";

@implementation MenuTVC

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

static NSString * const MenuCellIdentifier = @"menuCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = UIColorRGBA(kColorClear);
    [self.tableView registerClass:[MenuTVCell class] forCellReuseIdentifier:MenuCellIdentifier];
    
    MenuObject *menuItem;
    _menuItems = [NSMutableArray array];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconSearch;
    menuItem.name = @"SEARCH";
    menuItem.type = kMenuItemSearch;
    [_menuItems addObject:menuItem];

    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconMap;
    menuItem.name = @"EXPLORE";
    menuItem.type = kMenuItemExplore;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconPlay;
    menuItem.name = @"PLAY";
    menuItem.type = kMenuItemPlay;
    [_menuItems addObject:menuItem];

    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconFoodFeed;
    menuItem.name = @"FOOD FEED";
    menuItem.type = kMenuItemFoodFeed;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconWhatsNew;
    menuItem.name = @"HOT LISTS";
    menuItem.type = kMenuItemWhatsNew;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconEvent;
    menuItem.name = @"EVENTS";
    menuItem.type = kMenuItemMeet;
    [_menuItems addObject:menuItem];
    
    menuItem = [MenuObject new];
    menuItem.icon = kFontIconFeed;
    menuItem.name = @"CONNECT";
    menuItem.type = kMenuItemConnect;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconPerson;
    menuItem.name = @"PROFILE";
    menuItem.type = kMenuItemProfile;
    [_menuItems addObject:menuItem];

// Move settings functionality into profile
//    menuItem = [[MenuObject alloc] init];
//    menuItem.icon = kFontIconSettings;
//    menuItem.name = @"SETTINGS";
//    menuItem.type = kMenuItemSettings;
//    [_menuItems addObject:menuItem];

#if 0
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconFeed;
    menuItem.name = @"FRIEND FEED";
    menuItem.type = kMenuItemFeed;
    [_menuItems addObject:menuItem];
#endif
    
#ifdef DEBUG
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconSettings;
    menuItem.name = @"DIAGNOSTICS";
    menuItem.type = kMenuItemDiagnostic;
    [_menuItems addObject:menuItem];
#endif
    
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.tableView.scrollEnabled = NO;
//    self.tableView.separatorColor = UIColorRGBA(kColorClear);
    
    NSLog(@"tableView frame=%@", NSStringFromCGRect(self.tableView.frame));
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    backgroundView.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    self.tableView.backgroundView = backgroundView;
    UIImage *image = [UIImage imageNamed:@"Oomami_Logo_Spork(Nov24) (1) w.png"];

    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, height(backgroundView)-60 , image.size.width/image.size.height*60, 60)];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.image = image;
    [self.tableView.backgroundView addSubview:iv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_menuItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuTVCell *cell = [tableView dequeueReusableCellWithIdentifier:MenuCellIdentifier forIndexPath:indexPath];

    cell.menuItem = [_menuItems objectAtIndex:indexPath.row];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation
*/
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    
    // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
    // we'll just set position and return
    MenuObject *menuItem = [_menuItems objectAtIndex:indexPath.row];

    UINavigationController *frontViewController;
    frontViewController = nil;
    
    ANALYTICS_EVENT_UI(@"Menu");

    if ([menuItem.type isEqualToString:kMenuItemProfile]) {
//        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
        _fvc = [[ProfileVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemSettings]) {
        _fvc = [[SettingsVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemWhatsNew]) {
        _fvc = [[WhatsNewVC alloc] init];
    }else if ([menuItem.type isEqualToString:kMenuItemSearch]) {
        _fvc = [[SearchVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemConnect]) {
        _fvc = [[ConnectVC alloc] init];
        if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            [APP registerForPushNotifications];
        }
    } else if ([menuItem.type isEqualToString:kMenuItemExplore]) {
        _fvc = [[ExploreVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemPlay]) {
        _fvc = [[PlayVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemFeed]) {
        _fvc = [[FeedVC alloc] init];
        if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            [APP registerForPushNotifications];
        }
    } else if ([menuItem.type isEqualToString:kMenuItemDiagnostic]) {
        _fvc = [[DiagnosticVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemFoodFeed]) {
        _fvc = [[FoodFeedVC alloc] init];
        [(FoodFeedVC *)_fvc selectAll];
    } else if ([menuItem.type isEqualToString:kMenuItemMeet]) {
        _fvc = [[EventsListVC alloc] init];
        if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            [APP registerForPushNotifications];
        }
    } else {
        //TODO AUG: fill in other cases
        _fvc = [[DefaultVC alloc] init];
    }
    
    frontViewController = [[UINavigationController alloc] initWithRootViewController:_fvc];
    
    [revealController pushFrontViewController:frontViewController animated:YES];
    APP.nc = frontViewController;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}



@end
