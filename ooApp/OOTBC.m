//
//  OOTBC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/11/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOTBC.h"
#import "ExploreVC.h"
#import "FoodFeedVC.h"
#import "SearchVC.h"
#import "ConnectVC.h"
#import "ProfileVC.h"
#import "AppDelegate.h"

@interface OOTBC ()
@property (nonatomic, strong) ExploreVC *exploreVC;
@property (nonatomic, strong) SearchVC *searchVC;
@property (nonatomic, strong) ProfileVC *profileVC;
@property (nonatomic, strong) ConnectVC *connectVC;
@end

@implementation OOTBC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tabBar.backgroundColor = UIColorRGBA(kColorBlack);
    self.tabBar.backgroundImage = [UIImage imageWithColor:UIColorRGBA(kColorBlack)];
    self.tabBar.tintColor = UIColorRGBA(kColorYellow);
    
    UINavigationController *nc;
    
    UILabel *image = [[UILabel alloc] init];
    UILabel *selectedImage = [[UILabel alloc] init];
    UITabBarItem *tbi;
    
//    NSMutableArray *childViewControllers = [NSMutableArray array];
    
    
    [image withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSizeSmall] textColor:kColorYellow backgroundColor:kColorClear];


    [selectedImage withFont:[UIFont fontWithName:kFontIcons size:kGeomIconSizeSmall] textColor:kColorBlue backgroundColor:kColorClear];
    selectedImage.layer.borderColor = UIColorRGBA(kColorYellowReallyFaded).CGColor;
    selectedImage.layer.borderWidth = 1;

    image.text = selectedImage.text = kFontIconFoodFeed;
    [image sizeToFit];
    [selectedImage sizeToFit];

    UINavigationController *ffNC = [[self childViewControllers] objectAtIndex:0];
    [ffNC.tabBarItem setImage:[UIImage imageFromView:image]];
    [ffNC.tabBarItem setSelectedImage:[UIImage imageFromView:selectedImage]];
    ffNC.tabBarItem.title = @"Food Feed";
    
    image.text = selectedImage.text = kFontIconSearch;
    [image sizeToFit];
    [selectedImage sizeToFit];

    tbi = [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageFromView:image] selectedImage:[UIImage imageFromView:selectedImage]];
    _searchVC = [[SearchVC alloc] init];
    _searchVC.tabBarItem = tbi;
    nc = [[UINavigationController alloc] initWithRootViewController:_searchVC];
    [self addChildViewController:nc];

    image.text = selectedImage.text = kFontIconMap;
    [image sizeToFit];
    [selectedImage sizeToFit];
    tbi = [[UITabBarItem alloc] initWithTitle:@"Explore" image:[UIImage imageFromView:image] selectedImage:[UIImage imageFromView:selectedImage]];

    _exploreVC = [[ExploreVC alloc] init];
    _exploreVC.tabBarItem = tbi;
    nc = [[UINavigationController alloc] initWithRootViewController:_exploreVC];
    [self addChildViewController:nc];
    
    image.text = selectedImage.text = kFontIconFeed;
    [image sizeToFit];
    [selectedImage sizeToFit];
    tbi = [[UITabBarItem alloc] initWithTitle:@"Connect" image:[UIImage imageFromView:image] selectedImage:[UIImage imageFromView:selectedImage]];
    
    _connectVC = [[ConnectVC alloc] init];
    _connectVC.tabBarItem = tbi;
    nc = [[UINavigationController alloc] initWithRootViewController:_connectVC];
    [self addChildViewController:nc];
    
    image.text = selectedImage.text = kFontIconPerson;
    [image sizeToFit];
    [selectedImage sizeToFit];
    tbi = [[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageFromView:image] selectedImage:[UIImage imageFromView:selectedImage]];

    _profileVC = [[ProfileVC alloc] init];
    _profileVC.tabBarItem = tbi;
    nc = [[UINavigationController alloc] initWithRootViewController:_profileVC];
    [self addChildViewController:nc];
    
    [self setSelectedIndex:0];
    APP.tabBar = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
