//
//  ProfileVC.m
//  ooApp
//
//  Created by Zack Smith & Anuj Gujar on 8/27/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ProfileVC.h"
#import "UserObject.h"
#import "Settings.h"
#import "Common.h"
#import "ListTVCell.h"
#import "OOAPI.h"

@interface ProfileTableFirstRow : UITableViewCell

@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) UIButton *buttonFollow;
@property (nonatomic, strong) UIButton *buttonNewList;
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelDescription;
@property (nonatomic, strong) UILabel *labelRestaurants;
@property (nonatomic, strong) UIButton *buttonNewListIcon;
@property (nonatomic, assign) float spaceNeededForFirstCell;
@property (nonatomic, assign) UINavigationController *navigationController;

@end

#define BLACK UIColorRGB(kColorBlack)
#define WHITE UIColorRGB(kColorWhite)
#define GRAY UIColorRGB(kColorGray)
#define CLEAR UIColorRGBA(kColorClear)

@implementation ProfileTableFirstRow
- (instancetype) init
{
    self = [super init];
    if (self) {
        
        self.iv= makeImageView (self,  kImageNoProfileImage);
        self.buttonFollow= makeButton(self,  @"FOLLOW", kGeomFontSizeHeader,BLACK, CLEAR, self, @selector (userPressedFollow:), 1);
        self.buttonNewList= makeButton(self,  @"NEW LIST", kGeomFontSizeHeader,BLACK, CLEAR,  self, @selector (userPressedNewList:), 0);
        self.buttonNewListIcon= makeButton(self, @"b",kGeomFontSizeHeader,BLACK, CLEAR,  self, @selector (userPressedNewList:), 0);
        [_buttonNewListIcon.titleLabel setFont: [UIFont fontWithName:@"oomami-icons" size: kGeomFontSizeHeader]];
        
        UserObject* userInfo= [Settings sharedInstance].userObject;
        NSString* username= nil;
        if  (userInfo.username.length ) {
            username= userInfo.username;
        } else {
            username=  @"Missing username";
        }
        
        NSString * description= userInfo.about.length? userInfo.about: nil;
        NSString* restaurants=  nil;
        
        self.labelUsername= makeLabelLeft(self, username,kGeomFontSizeHeader);
        self.labelDescription= makeLabelLeft(self, description,kGeomFontSizeHeader);
        self.labelRestaurants= makeLabelLeft(self, restaurants,kGeomFontSizeHeader);
        
        self.iv.layer.borderColor= GRAY.CGColor;
        self.iv.layer.borderWidth= 1;
        self.iv.contentMode=UIViewContentModeScaleAspectFit;
        
        self.backgroundColor= WHITE;
    }
    return self;
}

- (void)userPressedNewList: (id) sender
{
    if (!_navigationController) {
        return;
    }
    BaseVC *vc=[[BaseVC  alloc]init ];
    vc.view.backgroundColor= [ UIColor  orangeColor];
    [_navigationController pushViewController:vc animated:YES];
}

- (void)userPressedFollow: (id) sender
{
    if (!_navigationController) {
        return;
    }
    
    BaseVC *vc=[[BaseVC  alloc]init ];
    vc.view.backgroundColor= [ UIColor   blueColor];
    [_navigationController pushViewController:vc animated:YES];
}

- ( void)layoutsSubviews
{
    float w=  [UIScreen mainScreen].bounds.size.width;
    
    const int spacer=  kGeomSpaceInter;
    int x=  kGeomSpaceEdge;
    int y=  kGeomSpaceEdge;
    _iv.frame= CGRectMake(x, y,  kProfileImageSize,  kProfileImageSize);
    int bottomOfImage= y + kProfileImageSize;
    
    // Place the image
    x += kProfileImageSize+ spacer;
    _labelUsername.frame=CGRectMake(x,y,w-x,kGeomProfileInformationHeight);
    y +=kGeomProfileInformationHeight+ spacer;
    
    // Place the labels
    if (_labelDescription.text.length ) {
        _labelDescription.frame=CGRectMake(x,y,w-x,kGeomProfileInformationHeight);
        y += kGeomProfileInformationHeight+ spacer;
    } else {
        _labelDescription.hidden= YES;
    }
    
    if (_labelRestaurants.text.length ) {
        _labelRestaurants.frame=CGRectMake(x,y,w-x,kGeomProfileInformationHeight);
        y += kGeomProfileInformationHeight + spacer;
    } else {
        _labelRestaurants.hidden= YES;
    }
    
    // Place the follow button
    _buttonFollow.frame=CGRectMake(w- kGeomSpaceEdge-kGeomButtonWidth,y,kGeomButtonWidth,  kGeomHeightButton);
    y += kGeomHeightButton + spacer;
    
    if  (y < bottomOfImage ) {
        y= bottomOfImage;
    }
    
    // Place the new list buttons
    x = kGeomSpaceEdge;
    [_buttonNewListIcon sizeToFit];
    float iconWith= _buttonNewListIcon.frame.size.width;
    _buttonNewListIcon.frame=CGRectMake(x,y, iconWith,  kGeomHeightButton);
    x += iconWith + spacer;
    [_buttonNewList sizeToFit];
    float textWidth= _buttonNewList.frame.size.width;
    _buttonNewList.frame=CGRectMake(x,y,textWidth,  kGeomHeightButton);
    y +=  kGeomHeightButton + spacer;
    
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

@property (nonatomic, strong) ProfileTableFirstRow* headerCell;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *lists;

@end

@implementation ProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _lists = [NSMutableArray array];
    
    OOAPI *api = [[OOAPI alloc] init];
    [api getUserListsWithSuccess:^(NSArray *foundLists) {
        NSLog (@" number of lists for this user:  %ld", ( long) foundLists.count);
        if  (!foundLists.count) {
            ListObject *list;
            
            list = [[ListObject alloc] init];
            list.name = @"Featured";
            list.listType = kListTypeFeatured;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Thai";
            list.listType = KListTypeStrip;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Chinese";
            list.listType = KListTypeStrip;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Vegetarian";
            list.listType = kListTypeFeatured;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Burgers";
            list.listType = KListTypeStrip;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Vietnamese";
            list.listType = KListTypeStrip;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"New";
            list.listType = kListTypeFeatured;
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Mexican";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Peruvian";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Delivery";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Date Night";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Party";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Drinks";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Mediterranean";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Steak";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Indian";
            [_lists addObject:list];
            
            list = [[ListObject alloc] init];
            list.name = @"Tandoor";
            [_lists addObject:list];
        }else {
            ListObject *list;

            for (NSDictionary* item  in foundLists ) {
                NSLog (@" user list:  %@", item);

                if (![item isKindOfClass:[NSDictionary class]]) {
                    NSLog  (@" item is not a dictionary");
                    continue;
                }
                
                NSString* name=  item[ @"name"];
                if (!name) {
                    NSLog  (@" missing listing name");
                    continue;
                }
                
                list = [[ListObject alloc] init];
                list.name =  name;
                [_lists addObject:list];
            }
            
            
            list = [[ListObject alloc] init];
            list.name = @"Indian";
            [_lists addObject:list];
        }
        
        [self.table reloadData];
    }
                         failure:^(NSError *e) {
        NSLog  (@" error while getting lists for user:  %@",e);
    }];
    // NOTE:  these will later be stored in user defaults.
    
    
    self.view.backgroundColor= WHITE;
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    
    self.headerCell=[[ProfileTableFirstRow  alloc] init];
    self.headerCell.navigationController= self.navigationController;
    
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
    
    [ self.view setNeedsLayout ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillLayoutSubviews
{
    // NOTE:  this is just temporary
    
    [ super viewWillLayoutSubviews ];
  
    self.table.frame=  self.view.bounds;
}

- (int) getNumberOfLists
{
    return self.lists.count;
}

- (NSString*)getNameOfList: ( int) which
{
    NSMutableArray* a= self.lists;
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
    return kGeomHeightListRow;
}

- ( NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + [self getNumberOfLists];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"pcell";
    
    int row = indexPath.row;
    
    if  (!row) {
        return _headerCell;
    }
    
    ListTVCell* cell = [[ListTVCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell. backgroundColor= GRAY;
    
    NSMutableArray* a= self.lists;
    cell.listItem= a[indexPath.row-1];
    [cell getRestaurants];
    return cell;
}

@end
