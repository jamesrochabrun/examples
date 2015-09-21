//
//  ProfileVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ProfileVC.h"
#import "UserObject.h"
#import "Settings.h"
#import "Common.h"
#import "ListTVCell.h"

@interface ProfileVC ()

@property (nonatomic, strong) UIView *firstCellHeaderView;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonNewList;
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelDescription;
@property (nonatomic, strong) UILabel *labelRestaurants;
@property (nonatomic, strong) UITableView *table;

@end

@implementation ProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // kFontIconAdd

    self.firstCellHeaderView= [UIView new];
    
    self.iv= makeImageView(self.firstCellHeaderView, nil);
    self.buttonFollow= makeButton(self.firstCellHeaderView,  @"FOLLOW",[UIColor  blackColor], [UIColor  clearColor],  self, @selector (userPressedFollow:));
    self.buttonNewList= makeButton(self.firstCellHeaderView,  @"NEW LIST",[UIColor blackColor], [UIColor  clearColor],  self, @selector (userPressedNewList:));
    
    self.table= [UITableView new];
    self.table.delegate= self;
    self.table.dataSource= self;
    [ self.view addSubview:_table];
    self.table.backgroundColor=[UIColor clearColor];

    self.iv.layer.borderColor=[UIColor redColor ].CGColor;
    self.iv.layer.borderWidth= 1;
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSString* first= userInfo.firstName ?:  @"";
    NSString* last= userInfo.lastName ?:  @"";
    NSString* name=  [NSString stringWithFormat: @"%@ %@", first, last ];
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader: name subHeader:nil];
    [self setNavTitle:  nto];
//    [self layout];
    [ self.view setNeedsLayout ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layout
{
//    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
//    UIView *superview = self.view;
//    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _iv,_buttonFollow,_buttonNewList);
//
//    NSArray* constraints= [NSLayoutConstraint constraintsWithVisualFormat:
//                                     @"V:|-(75)-[_iv(height)]-(75)-[_buttonFollow(50)][_buttonNewList(height)]|"
//                                                                            options:NSLayoutFormatDirectionLeadingToTrailing
//                                                                            metrics:metrics
//                                                                              views:views];
//    
//    // Vertical layout - note the options for aligning the top and bottom of all views
//    [self.view addConstraints: constraints];
//    
//    
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:@"H:|-(>=20)-[_iv(width)]-[_buttonFollow(80)]-[_buttonNewList(80)]-(>=20)-|"
//                               options:0
//                               metrics:metrics
//                               views:views]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_iv
//                                                          attribute:NSLayoutAttributeCenterX
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:_iv.superview
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.f
//                                                           constant:0.f]];
//    
    
}
- (void) viewWillLayoutSubviews
{
    // NOTE:  this is just temporary
    
    [ super viewWillLayoutSubviews ];
    
    float w=  self.view.bounds.size.width;
    self.table.frame=  self.view.bounds;
    
    const int margin=  kGeomSpaceEdge;
    const int spacer=  kGeomSpaceInter;
    const  int buttonWidth=  100;
    int x=  margin;
    int y=  margin;
    _iv.frame= CGRectMake(x, y,  buttonWidth,  100);
    _buttonFollow.frame=CGRectMake(w- margin-buttonWidth,y,buttonWidth,  kGeomHeightButton);
    y += 100 + spacer;
    
    _buttonNewList.frame=CGRectMake(x,y,180,  kGeomHeightButton); y +=  kGeomHeightButton+ spacer;
    
}
- (void)userPressedNewList: (id) sender
{
    message( @"you pressed new list");
}

- (void)userPressedFollow: (id) sender
{
    message( @"you pressed follow");
}

- (int) getNumberOfLists
{
    return 3;
}

- (NSString*)getNameOfList: ( int) which
{
    return  @[
              @"first", @"second", @"third"
              ] [which];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (!section) {
        return  300;
    }
    return  30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1 + [self getNumberOfLists];
}
- ( NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if  (!section) {
        return _firstCellHeaderView;
    }
    
    UILabel* titleLabel= [UILabel new];
    titleLabel.text=[ self getNameOfList:  section-1];
    return  titleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"pcell";
    
    if  (!indexPath.section) {
        return nil;
    }
    
    ListTVCell* cell= [[ListTVCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Facebook delegate methods

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self.revealViewController performSegueWithIdentifier:@"loginUISegue" sender:self];
    //performSegueWithIdentifier:@"loginUISegue" sender:self];
//    [self performSegueWithIdentifier:@"loginUISegue" sender:self];
}

@end
