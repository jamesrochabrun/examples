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

@interface ProfileVCFirstRow : UITableViewCell

@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonNewList;
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelDescription;
@property (nonatomic, strong) UILabel *labelRestaurants;
@property (nonatomic, strong) UIButton *buttonNewListIcon;
@property (nonatomic, assign) float spaceNeededForFirstCell;

@end

@implementation  ProfileVCFirstRow
- (instancetype) init
{
    self = [super init];
    if (self) {
        
        // kFontIconAdd
        
        self.backgroundColor= [ UIColor  grayColor];
        
        self.iv= makeImageView (self,  @"placeholderProfile");
        self.buttonFollow= makeButton(self,  @"FOLLOW",[UIColor  blackColor], [UIColor  clearColor],  self, @selector (userPressedFollow:));
        self.buttonNewList= makeButton(self,  @"NEW LIST",[UIColor blackColor], [UIColor  clearColor],  self, @selector (userPressedNewList:));
        self.buttonNewListIcon= makeButton(self, @"b",[UIColor blackColor], [UIColor  clearColor],  self, @selector (userPressedNewList:));
        [_buttonNewListIcon.titleLabel setFont: [UIFont fontWithName:@"oomami-icons" size:17]];
        
        _buttonFollow.layer.borderColor=[UIColor  blackColor].CGColor;
        _buttonFollow.layer.borderWidth= 1;
        
        UserObject* userInfo= [Settings sharedInstance].userObject;
        NSString* username= userInfo.email.length? userInfo.email: @"user name";
        NSString * description= userInfo.about.length? userInfo.about: @"description";
        NSString* restaurants=  @"restaurants";
        self.labelUsername= makeLabelLeft(self, username);
        self.labelDescription= makeLabelLeft(self, description);
        self.labelRestaurants= makeLabelLeft(self, restaurants);
        
        self.iv.layer.borderColor=[UIColor  grayColor ].CGColor;
        self.iv.layer.borderWidth= 1;
        self.iv.contentMode=UIViewContentModeScaleAspectFit;
        
        self.backgroundColor=[ UIColor redColor];
    }
    return self;
}
- ( void)layoutsSubviews
{
    float w=  [UIScreen mainScreen].bounds.size.width;

    const  float kFollowButtonWidth=  80;
    const  float kProfileImageSize=  100;
    const  float kProfileLabelHeight=   20;
    
    const int margin=  kGeomSpaceEdge;
    const int spacer=  kGeomSpaceInter;
    int x=  margin;
    int y=  margin;
    _iv.frame= CGRectMake(x, y,  kProfileImageSize,  kProfileImageSize);
    int bottomOfImage= y + kProfileImageSize;
    x += kProfileImageSize+ spacer;
    _labelUsername.frame=CGRectMake(x,y,w-x,kProfileLabelHeight);
    y +=kProfileLabelHeight+ spacer;
    _labelDescription.frame=CGRectMake(x,y,w-x,kProfileLabelHeight);
    y +=kProfileLabelHeight+ spacer;
    _labelRestaurants.frame=CGRectMake(x,y,w-x,kProfileLabelHeight);
    y +=kProfileLabelHeight+ spacer;
    
    _buttonFollow.frame=CGRectMake(w- margin-kFollowButtonWidth,y,kFollowButtonWidth,  kGeomHeightButton);
    y += kGeomHeightButton + spacer;
    
    if  (y < bottomOfImage ) {
        y= bottomOfImage;
    }
    x = margin;
    [_buttonNewListIcon sizeToFit];
    float iconWith= _buttonNewListIcon.frame.size.width;
    _buttonNewListIcon.frame=CGRectMake(x,y, iconWith,  kGeomHeightButton);
    x += iconWith + spacer;
    [_buttonNewList sizeToFit];
    float textWidth= _buttonNewList.frame.size.width;
    _buttonNewList.frame=CGRectMake(x,y,textWidth,  kGeomHeightButton);
    y +=  kGeomHeightButton+ spacer;
    self.spaceNeededForFirstCell= y;
}

- (int)neededHeight
{
    if  (!_spaceNeededForFirstCell) {
        [self layoutsSubviews];
    }
    return self.spaceNeededForFirstCell;

}

@end

@interface ProfileVC ()

@property (nonatomic, strong) ProfileVCFirstRow* headerCell;
@property (nonatomic, strong) UITableView *table;

@end

@implementation ProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    
    self.headerCell=[[ProfileVCFirstRow  alloc] init];
    
    self.table= [UITableView new];
    self.table.delegate= self;
    self.table.dataSource= self;
    [ self.view addSubview:_table];
    self.table.backgroundColor=[UIColor clearColor];
    self.table.separatorStyle= UITableViewCellSeparatorStyleNone;

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
  
    self.table.frame=  self.view.bounds;
    
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
    UserObject *u= [Settings sharedInstance].userObject;
    return [u lists].count;
}

- (NSString*)getNameOfList: ( int) which
{
    UserObject *u= [Settings sharedInstance].userObject;
    NSMutableArray* a= [u  lists];
    if  (which < 0 ||  which >= a.count) {
        return  @"";
    }
    return [a objectAtIndex: which ];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:( NSIndexPath *)indexPath
{
    int row = indexPath.row;

    if (! row) {
        return [_headerCell neededHeight];
    }
    return 100;
}

- ( NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + [self getNumberOfLists];
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if  (!section) {
//        return _firstCellHeaderView;
//    }
//    
//    NSIndexPath *ip= [NSIndexPath indexPathForRow:0 inSection:section];
//    ListTVCell *l=  [self.table cellForRowAtIndexPath:ip];
//
//    NSString *name=   l.listItem.name;
//    UILabel* label= [UILabel new];
//    if  (!name) {
//         name=  @"untitled";
//    }
//    label.text=  name;
//    return  label;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"pcell";
    
    int row = indexPath.row;
    
    if  (!row) {
        return _headerCell;
    }
    
    ListTVCell* cell = [[ListTVCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell. backgroundColor=  ( indexPath.row & 1 ) ? [ UIColor   orangeColor]:[ UIColor yellowColor];
    
    UserObject *u= [Settings sharedInstance].userObject;
    NSMutableArray* a= [u  lists];
    cell.listItem= a[indexPath.row-1];
    [cell getRestaurants];
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
