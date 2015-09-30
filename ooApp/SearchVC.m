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
#import "LocationManager.h"
#import "Settings.h"
#import "RestaurantHTVCell.h"
#import "RestaurantVC.h"

typedef enum: char {
    FILTER_NONE=  0,
    FILTER_PLACES=  1,
    FILTER_PEOPLE=  2,
    FILTER_LISTS=  3,
    FILTER_YOU=  4,
} FilterType;

@interface SearchVC ()
@property (nonatomic,strong)  UISearchBar* searchBar;
@property (nonatomic,strong)  UIButton* buttonList;
@property (nonatomic,strong)  UIButton* buttonPeople;
@property (nonatomic,strong)  UIButton* buttonCancel;
@property (nonatomic,strong)  UIButton* buttonPlaces;
@property (nonatomic,strong)  UIButton* buttonYou;
@property (nonatomic,strong)  UITableView*  table;
@property (nonatomic,assign) FilterType currentFilter;
@property (nonatomic,strong) NSArray* restaurantsArray;
@property (atomic,assign) BOOL doingSearchNow;
@property (nonatomic,strong) AFHTTPRequestOperation* fetchOperation;
@end

@implementation SearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= WHITE;
    
    _currentFilter=FILTER_NONE;
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Search" subHeader: @"for restaurants"];
    self.navTitle = nto;

	_searchBar= [ UISearchBar new];
	[ self.view  addSubview:_searchBar];
    _searchBar.searchBarStyle=  UISearchBarStyleMinimal;
    _searchBar.backgroundColor= WHITE;
    _searchBar.placeholder=  @"Search";
    _searchBar.barTintColor= WHITE;
    _searchBar.keyboardType= UIKeyboardTypeAlphabet;
    _searchBar.delegate= self;
    _buttonCancel=makeButton(self.view,  @"Cancel", kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(userPressedCancel:), .5);
    
#define SEARCH_TABLE_REUSE_IDENTIFIER  @"searchRestaurantsCell"

    _table= makeTable (self.view,self);
    [_table registerClass:[RestaurantHTVCell class] forCellReuseIdentifier:SEARCH_TABLE_REUSE_IDENTIFIER];

    _buttonList= makeAttributedButton(self.view,  @"List", kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(doSelectList:), 0);
    _buttonPeople= makeAttributedButton(self.view,  @"People", kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(doSelectPeople:), 0);
    _buttonPlaces= makeAttributedButton(self.view,  @"Places", kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(doSelectPlaces:), 0);
    _buttonYou= makeAttributedButton(self.view,  @"You", kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(doSelectYou:), 0);
    [self changeFilter: FILTER_PLACES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}

//------------------------------------------------------------------------------
// Name:    viewWillDisappear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (NSString*)currentFilterName
{
    switch (_currentFilter) {
        case FILTER_LISTS: return  @"Lists";
        case FILTER_PEOPLE: return  @"People";
        case FILTER_PLACES: return  @"Places";
        case FILTER_YOU: return  @"You";

        default:
            return  @"";
    }
}
//------------------------------------------------------------------------------
// Name:    keyboardHidden
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardHidden: (NSNotification*) not
{
    _table.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
}

//------------------------------------------------------------------------------
// Name:    keyboardShown
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardShown: (NSNotification*) not
{
    NSDictionary* info = [not userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float keyboardHeight = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? kbSize.width : kbSize.height;
    _table.contentInset= UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
//    [_scrollView scrollRectToVisible:_fieldUsername.frame animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)doSearch
{
    if ( self.doingSearchNow) {
        NSLog (@"CANNOT SEARCH NOW");
        return;
    }
    OOAPI *api= [[OOAPI  alloc] init];
    CLLocationCoordinate2D location=[LocationManager sharedInstance].currentUserLocation;
    if (!location.latitude && !location.longitude) {
        // XX
        NSLog (@"NOTE: WE DO NOT HAVE USERS LOCATION... USING SAN FRAN.");
        location.latitude = 37.775;
        location.longitude = -122.4183333;
    }
    
    self.doingSearchNow= YES;
    __weak SearchVC* weakSelf= self;
    
    self.fetchOperation= [api getRestaurantsWithKeyword:_searchBar.text
                                              andFilter:[self currentFilterName]
                                            andLocation:location
                                                success:^(NSArray *restaurants) {
                                                    [weakSelf performSelectorOnMainThread:@selector(loadRestaurants:)
                                                                               withObject:restaurants
                                                                            waitUntilDone:NO];
                                                    
                                                } failure:^(NSError *e) {
                                                    NSLog  (@"ERROR FETCHING RESTAURANTS: %@",e );
                                                }
                          ];
    
}

- (void)changeFilter: (FilterType)which
{
    if  (which ==_currentFilter ) {
        return;
    }
    
    const  float fs= kGeomFontSizeHeader;
    switch ( which) {
        case FILTER_LISTS:
            [_buttonList setAttributedTitle:underlinedAttributedStringOf( @"List", fs) forState:UIControlStateNormal];
            [_buttonPeople setAttributedTitle:attributedStringOf( @"People", fs) forState:UIControlStateNormal];
            [_buttonPlaces setAttributedTitle:attributedStringOf( @"Places", fs) forState:UIControlStateNormal];
            [_buttonYou setAttributedTitle:attributedStringOf( @"You", fs) forState:UIControlStateNormal];
            break;
            
        case FILTER_PEOPLE:
            [_buttonList setAttributedTitle:attributedStringOf( @"List", fs) forState:UIControlStateNormal];
            [_buttonPeople setAttributedTitle:underlinedAttributedStringOf( @"People", fs) forState:UIControlStateNormal];
            [_buttonPlaces setAttributedTitle:attributedStringOf( @"Places", fs) forState:UIControlStateNormal];
            [_buttonYou setAttributedTitle:attributedStringOf( @"You", fs) forState:UIControlStateNormal];
            break;
            
        case FILTER_PLACES:
            [_buttonList setAttributedTitle:attributedStringOf( @"List", fs) forState:UIControlStateNormal];
            [_buttonPeople setAttributedTitle:attributedStringOf( @"People", fs) forState:UIControlStateNormal];
            [_buttonPlaces setAttributedTitle:underlinedAttributedStringOf( @"Places", fs) forState:UIControlStateNormal];
            [_buttonYou setAttributedTitle:attributedStringOf( @"You", fs) forState:UIControlStateNormal];
            break;
            
        case FILTER_YOU:
            [_buttonList setAttributedTitle:attributedStringOf( @"List", fs) forState:UIControlStateNormal];
            [_buttonPeople setAttributedTitle:attributedStringOf( @"People", fs) forState:UIControlStateNormal];
            [_buttonPlaces setAttributedTitle:attributedStringOf( @"Places", fs) forState:UIControlStateNormal];
            [_buttonYou setAttributedTitle:underlinedAttributedStringOf( @"You", fs) forState:UIControlStateNormal];
            break;
            
        default: return;
    }
    
    self.currentFilter=  which;
    
    // RULE: If the user was searching for "Fred" in the people category and
    //  then switched to the places category, then we should redo the search
    //  in the new category.
    //
    if (_searchBar.text.length) {
        [self doSearch];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString* text= _searchBar.text;
    if (!text.length) {
        [self  loadRestaurants: @[]];
        return;
    }
    
    if ( self.doingSearchNow) {
        [self cancelSearch];
    }
    [self doSearch];
}

- (void)loadRestaurants: (NSArray*)array
{
    self.doingSearchNow= NO;
    self.fetchOperation= nil;
    self.restaurantsArray= array;
    [self.table reloadData];
}

//------------------------------------------------------------------------------
// Name:    cancelSearch
// Purpose:
//------------------------------------------------------------------------------
- (void)cancelSearch
{
    [self.fetchOperation  cancel];
    self.fetchOperation= nil;
    self.doingSearchNow= NO;
}

//------------------------------------------------------------------------------
// Name:    userPressedCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedCancel: (id) sender
{
    _searchBar.text=@"";
    [_searchBar resignFirstResponder];
    [self.fetchOperation  cancel];
    self.fetchOperation= nil;
    self.restaurantsArray= nil;
    self.doingSearchNow= NO;
    [self.table reloadData];
}

//------------------------------------------------------------------------------
// Name:    doSelectList
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectList: (id) sender
{
    if  (_currentFilter==FILTER_LISTS ) {
        return;
    }
    if  (self.doingSearchNow ) {
        [self cancelSearch];
    }
    [self changeFilter: FILTER_LISTS];
}

//------------------------------------------------------------------------------
// Name:    doSelectPeople
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectPeople: (id) sender
{
    if  (_currentFilter==FILTER_PEOPLE ) {
        return;
    }
    if  (self.doingSearchNow ) {
        [self cancelSearch];
    }
    [self changeFilter: FILTER_PEOPLE];
}

//------------------------------------------------------------------------------
// Name:    doSelectPlaces
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectPlaces: (id) sender
{
    if  (_currentFilter==FILTER_PLACES ) {
        return;
    }
    if  (self.doingSearchNow ) {
        [self cancelSearch];
    }
    [self changeFilter:FILTER_PLACES];
}

//------------------------------------------------------------------------------
// Name:    doSelectYou
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectYou: (id) sender
{
    if  (_currentFilter==FILTER_YOU ) {
        return;
    }
    if  (self.doingSearchNow ) {
        [self cancelSearch];
    }
    [self changeFilter: FILTER_YOU];
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

    float x= 0;
    _searchBar.frame=  CGRectMake(0,y,w-kGeomButtonWidth,kGeomHeightButton);
    _buttonCancel.frame=  CGRectMake( w-kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     y+kGeomCancelButtonInteriorPadding,
                                     kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     kGeomHeightButton-2*kGeomCancelButtonInteriorPadding);
    y += kGeomHeightButton;
    
    int buttonWidth= w/4;
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
    RestaurantHTVCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell=  [[RestaurantHTVCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SEARCH_TABLE_REUSE_IDENTIFIER ];
    }
    NSString *name = nil;
    NSInteger row = indexPath.row;
    name=  @[  @"testing",@"foo"][1&row];
    cell.header.text=  name;
    if  (!self.doingSearchNow) {
        cell.restaurant= _restaurantsArray[row];

    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightHorizontalListRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if  (self.doingSearchNow) {
        return;
    }
    
    NSInteger row= indexPath.row;
    if  (row >= _restaurantsArray.count ) {
        return;
    }
    RestaurantObject *ro = [_restaurantsArray objectAtIndex:indexPath.row];
    
    RestaurantVC *vc = [[RestaurantVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = trimString (ro.name);
    vc.restaurant = ro;
    [vc getRestaurant];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if  (self.doingSearchNow) {
        return 0;
    }
    return self.restaurantsArray.count;
}

@end
