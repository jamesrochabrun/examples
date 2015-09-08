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
#import "DiscoverVC.h"
#import "DefaultVC.h"
#import "PlayVC.h"

@interface MenuTVC ()

@property (nonatomic, strong) NSMutableArray *menuItems;

@end

@implementation MenuTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[MenuTVCell class] forCellReuseIdentifier:@"menuCell"];
    self.tableView.backgroundColor = UIColorRGBA(kColorGray);
    
    MenuObject *menuItem;
    _menuItems = [NSMutableArray array];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = nil;
    menuItem.name = nil;
    [_menuItems addObject:menuItem];

    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconDiscover;
    menuItem.name = @"Discover";
    menuItem.type = kMenuItemDiscover;
    [_menuItems addObject:menuItem];

    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconEat;
    menuItem.name = @"Eat";
    menuItem.type = kMenuItemEat;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconPlay;
    menuItem.name = @"Play";
    menuItem.type = kMenuItemPlay;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconMeet;
    menuItem.name = @"Meet";
    menuItem.type = kMenuItemMeet;
    [_menuItems addObject:menuItem];

    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconConnect;
    menuItem.name = @"Connect";
    menuItem.type = kMenuItemConnect;
    [_menuItems addObject:menuItem];
    
    menuItem = [[MenuObject alloc] init];
    menuItem.icon = kFontIconUserProfile;
    menuItem.name = @"User Profile";
    menuItem.type = kMenuItemProfile;
    [_menuItems addObject:menuItem];
    
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = UIColorRGBA(kColorGray);
    
    NSLog(@"tableView frame=%@", NSStringFromCGRect(self.tableView.frame));
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    MenuTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    if (indexPath.row !=0)
        cell.menuItem = [_menuItems objectAtIndex:indexPath.row];
    else {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"background-image.jpg"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    

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
    UIViewController *newFrontController = nil;
    UIViewController *fvc;
    
    if ([menuItem.type isEqualToString:kMenuItemProfile]) {
        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
        fvc = [[ProfileVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemDiscover]) {
        fvc = [[DiscoverVC alloc] init];
    } else if ([menuItem.type isEqualToString:kMenuItemPlay]) {
        fvc = [[PlayVC alloc] init];
    } else {
        //TODO AUG: fill in other cases
        fvc = [[DefaultVC alloc] init];
    }
    
    newFrontController = [[UINavigationController alloc] initWithRootViewController:fvc];
    [revealController pushFrontViewController:newFrontController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return (self.view.frame.size.height - (60 * ([_menuItems count]-1)));
    }
    return 60;
}



@end
