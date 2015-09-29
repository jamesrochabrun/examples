//
//  SearchVC.m
//  ooApp
//
//  Created by Zack Smith on 9/28/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "SearchVC.h"
#import "Settings.h"

@interface SearchVC ()
@property (nonatomic,strong)  UISearchBar* searchBar;
@property (nonatomic,strong)  UIButton* buttonList;
@property (nonatomic,strong)  UIButton* buttonPeople;
@property (nonatomic,strong)  UIButton* buttonPlaces;
@property (nonatomic,strong)  UIButton* buttonYou;
@property (nonatomic,strong)  UITableView*  table;
@end

@implementation SearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets= NO;

    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Search" subHeader: @"for Restaurants"];
    self.navTitle = nto;

	_searchBar= [ UISearchBar new];
	[ self.view  addSubview:_searchBar];
    
#define SEARCH_TABLE_REUSE_IDENTIFIER  @"searchcell"
    self.view.backgroundColor= [UIColor lightGrayColor];
    _table= makeTable (self.view,self);
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:SEARCH_TABLE_REUSE_IDENTIFIER];

    _buttonList= makeButton(self.view,  @"List", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSelectList:), 0);
    _buttonPeople= makeButton(self.view,  @"People", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSelectPeople:), 0);
    _buttonPlaces= makeButton(self.view,  @"Places", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSelectPlaces:), 0);
    _buttonYou= makeButton(self.view,  @"You", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSelectYou:), 0);

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

//------------------------------------------------------------------------------
// Name:    doSelectList
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectList: (id) sender
{
}

//------------------------------------------------------------------------------
// Name:    doSelectPeople
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectPeople: (id) sender
{
}

//------------------------------------------------------------------------------
// Name:    doSelectPlaces
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectPlaces: (id) sender
{
}

//------------------------------------------------------------------------------
// Name:    doSelectYou
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectYou: (id) sender
{
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float spacing= kGeomSpaceInter;
    float y=  0;
    
    _searchBar.frame=  CGRectMake(0,y,w,kGeomHeightButton);
    y += kGeomHeightButton;
    
    int buttonWidth= w/4;
    float x= 0;
    _buttonList.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    x+=   buttonWidth;
    _buttonPeople.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    x+=   buttonWidth;
    _buttonPlaces.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    x+=   buttonWidth;
    _buttonYou.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=kGeomHeightButton + spacing;
    
    _table.frame=  CGRectMake(0,y,w, h-y);

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell=  [[UITableViewCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SEARCH_TABLE_REUSE_IDENTIFIER ];
    }
    NSString *name = nil;
    NSInteger row = indexPath.row;
        name=  @[  @"testing"][0];
    cell.textLabel.text= name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name= nil;
    NSInteger row= indexPath.row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

@end
