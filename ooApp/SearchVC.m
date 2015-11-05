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
#import "RestaurantTVCell.h"
#import "RestaurantVC.h"
#import "UserTVCell.h"
#import "ProfileVC.h"
#import "OOFilterView.h"

typedef enum: char {
    FILTER_NONE=  -1,
    FILTER_PLACES=  2,
    FILTER_PEOPLE=  1,
    FILTER_LISTS=  0,
    FILTER_YOU=  3,
} FilterType;

#define SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER  @"searchRestaurantsCell"
#define SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER  @"searchPeopleCell"

@interface SearchVC ()
@property (nonatomic,strong) UISearchBar* searchBar;
@property (nonatomic,strong) OOFilterView* filterView;
@property (nonatomic,strong) UIButton* buttonCancel;
@property (nonatomic,strong) UITableView*  tableRestaurants;
@property (nonatomic,strong) UITableView*  tablePeople;
@property (nonatomic,assign) FilterType currentFilter;
@property (nonatomic,strong) NSArray* restaurantsArray;
@property (nonatomic,strong) NSArray* peopleArray;
@property (atomic,assign) BOOL doingSearchNow;
@property (nonatomic,strong) AFHTTPRequestOperation* fetchOperation;
@property (nonatomic,strong) NSArray* arrayOfFilterNames;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@end

@implementation SearchVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= WHITE;
    
    _arrayOfFilterNames=  @[
                            LOCAL(@"None"),
                             LOCAL(@"Places"),
                             LOCAL(@"People"),
                             LOCAL(@"Lists"),
                             LOCAL(@"You")
                             ];
    
    _currentFilter=FILTER_NONE;
    
    NavTitleObject *nto;
    if  (_addingRestaurantsToEvent ) {
        nto= [[NavTitleObject alloc]
              initWithHeader:LOCAL( @"Search")
              subHeader: nil];
    } else {
        nto= [[NavTitleObject alloc]
              initWithHeader:LOCAL( @"Search")
              subHeader: LOCAL(@"for restaurants and people")];
    }
    
    self.navTitle = nto;

	_searchBar= [ UISearchBar new];
	[ self.view  addSubview:_searchBar];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = WHITE;
    _searchBar.placeholder = LOCAL( @"Type your search here");
    _searchBar.barTintColor = WHITE;
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.delegate= self;
    _buttonCancel=makeButton(self.view, LOCAL(@"Cancel") , kGeomFontSizeHeader, BLACK, CLEAR, self, @selector(userPressedCancel:), .5);
    
    self.filterView = [[OOFilterView alloc] init];
    [ self.view addSubview:_filterView];
    [_filterView addFilter:LOCAL(@"Lists") target:self selector:@selector(doSelectList:)];
    [_filterView addFilter:LOCAL(@"People") target:self selector:@selector(doSelectPeople:)];
    [_filterView addFilter:LOCAL(@"Places") target:self selector:@selector(doSelectPlaces:)];
    [_filterView addFilter:LOCAL(@"You") target:self selector:@selector(doSelectYou:)];
    _currentFilter = FILTER_PLACES;
    [_filterView setCurrent:2];
    
    self.tableRestaurants= makeTable (self.view,self);
    [_tableRestaurants registerClass:[RestaurantTVCell class]
              forCellReuseIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER];

    self.tablePeople= makeTable (self.view,self);
    [_tablePeople registerClass:[UserTVCell class]
         forCellReuseIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER];
    _tablePeople.backgroundColor=  UIColorRGB(0xfff8f8f8);
    
    if ( _addingRestaurantsToEvent) {
        self.navigationItem.leftBarButtonItem=nil;
    }
    
    self.activityView=[UIActivityIndicatorView new];
    [self.view addSubview: _activityView ];
    _activityView.hidden= YES;
    [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    [self changeFilter: FILTER_PLACES];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
// Name:    currentFilterName
// Purpose:
//------------------------------------------------------------------------------
- (NSString *)currentFilterName
{
    return _arrayOfFilterNames [_currentFilter ];
}

//------------------------------------------------------------------------------
// Name:    keyboardHidden
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardHidden:(NSNotification *)not
{
    _tableRestaurants.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
    _tablePeople.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
}

//------------------------------------------------------------------------------
// Name:    keyboardShown
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardShown:(NSNotification *)not
{
    NSDictionary *info = [not userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float keyboardHeight = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
    ? kbSize.width : kbSize.height;
    _tableRestaurants.contentInset= UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    _tablePeople.contentInset= UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//------------------------------------------------------------------------------
// Name:    showSpinner
// Purpose: Mechanism to give me diagnostic feedback.
//------------------------------------------------------------------------------
- (void)showSpinner: (id)show
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    CGRect r= CGRectMake(w/2-50,h/3,100,100);
    _activityView.frame= r;
    _activityView.hidden=  show ? NO:YES;
    if ( show) {
        [_activityView startAnimating];
    } else {
        [_activityView stopAnimating];
    }
    [self.view bringSubviewToFront:_activityView];
}

//------------------------------------------------------------------------------
// Name:    doSearch
// Purpose:
//------------------------------------------------------------------------------
- (void)doSearch
{
    if ( self.doingSearchNow) {
        NSLog (@"CANNOT SEARCH NOW");
        return;
    }
    self.doingSearchNow= YES;
    __weak SearchVC* weakSelf= self;
    
    switch (_currentFilter) {
        case  FILTER_NONE:
            break;
            
        case FILTER_PEOPLE:  {
            [self showSpinner: @""];
            
            NSString *searchText=_searchBar.text;
            NSLog (@"SEARCHING FOR USER:  %@",searchText);
            
            self.fetchOperation= [OOAPI getUsersWithKeyword:searchText
                                                    success:^(NSArray *users) {
                                                        [weakSelf performSelectorOnMainThread:@selector(loadPeople:)
                                                                                   withObject:users
                                                                                waitUntilDone:NO];
                                                        
                                                    } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                                                        NSLog  (@"ERROR FETCHING USERS BY KEYWORD: %@",e );
                                                        
                                                        [weakSelf performSelectorOnMainThread:@selector(showSpinner:)
                                                                                   withObject:nil
                                                                                waitUntilDone:NO];
                                                    }
                                  ];
        }break;
            
        case FILTER_LISTS: {

        } break;
            
        case FILTER_YOU: {

        }break;
            
        case  FILTER_PLACES: {
            [self showSpinner: @""];
    
            CLLocationCoordinate2D location=[LocationManager sharedInstance].currentUserLocation;
            if (!location.latitude && !location.longitude) {
                // XX
                NSLog (@"NOTE: WE DO NOT HAVE USERS LOCATION... USING SAN FRAN.");
                location.latitude = 37.775;
                location.longitude = -122.4183333;
            }
            
            OOAPI *api= [[OOAPI  alloc] init];
            
            self.fetchOperation= [api getRestaurantsWithKeyword:_searchBar.text
                                                    andLocation:location
                                                      andFilter:[self currentFilterName]
                                                    andOpenOnly:NO
                                                        andSort:kSearchSortTypeBestMatch
                                                        success:^(NSArray *restaurants) {
                                                            [weakSelf performSelectorOnMainThread:@selector(loadRestaurants:)
                                                                                       withObject:restaurants
                                                                                    waitUntilDone:NO];
                                                            
                                                        } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                                                            NSLog  (@"ERROR FETCHING RESTAURANTS: %@",e );
                                                            
                                                            [weakSelf performSelectorOnMainThread:@selector(showSpinner:)
                                                                                       withObject:nil
                                                                                    waitUntilDone:NO];
                                                        }
                                  ];
        } break;
    }
    
}

//------------------------------------------------------------------------------
// Name:    changeFilter
// Purpose:
//------------------------------------------------------------------------------
- (void)changeFilter: (FilterType)which
{
    if  (which ==_currentFilter ) {
        return;
    }
    
    [_filterView selectFilter:which];
    
    self.currentFilter=  which;
    
    [self updateWhichTableIsVisible];
    
    // RULE: If the user was searching for "Fred" in the people category and
    //  then switched to the places category, then we should redo the search
    //  in the new category.
    //
    if (_searchBar.text.length) {
        [self doSearch];
    }
}

//------------------------------------------------------------------------------
// Name:    textDidChange
// Purpose:
//------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString* text= _searchBar.text;
    if (!text.length) {
        // Clear the appropriate table; no need to start a search.
        
        if  (_currentFilter==FILTER_PEOPLE ) {
            [self  loadPeople: @[]];
        } else {
            [self  loadRestaurants: @[]];
        }
        return;
    }
    
    if ( self.doingSearchNow) {
        [self cancelSearch];
    }
    [self doSearch];
}

//------------------------------------------------------------------------------
// Name:    updateWhichTableIsVisible
// Purpose:
//------------------------------------------------------------------------------
- (void) updateWhichTableIsVisible
{
    if  (_currentFilter==FILTER_PEOPLE ) {
        _tablePeople.hidden= NO;
        _tableRestaurants.hidden= YES;
    } else {
        _tablePeople.hidden= YES;
        _tableRestaurants.hidden= NO;
    }
}

- (void)clearResultsTables
{
    self.restaurantsArray= nil;
    [self.tableRestaurants reloadData];
    
    self.peopleArray= nil;
    [self.tablePeople reloadData];
}

//------------------------------------------------------------------------------
// Name:    loadRestaurants
// Purpose:
//------------------------------------------------------------------------------
- (void)loadRestaurants: (NSArray*)array
{
    [ self showSpinner:nil];
    self.doingSearchNow= NO;
    self.fetchOperation= nil;
    
    self.restaurantsArray= array;
    [self.tableRestaurants reloadData];
    
    self.peopleArray= nil;
    [self.tablePeople reloadData];

    _tablePeople.hidden= YES;
    _tableRestaurants.hidden= NO;
}

//------------------------------------------------------------------------------
// Name:    loadPeople
// Purpose:
//------------------------------------------------------------------------------
- (void)loadPeople:(NSArray *)array
{
    [self showSpinner:nil];
    self.doingSearchNow= NO;
    self.fetchOperation= nil;
    
    self.peopleArray= array;
    [self.tablePeople reloadData];
    
    self.restaurantsArray= nil;
    [self.tableRestaurants reloadData];

    _tablePeople.hidden= NO;
    _tableRestaurants.hidden= YES;
}

//------------------------------------------------------------------------------
// Name:    cancelSearch
// Purpose:
//------------------------------------------------------------------------------
- (void)cancelSearch
{
    [ self showSpinner:nil];
   [self.fetchOperation  cancel];
    self.fetchOperation= nil;
    self.doingSearchNow= NO;
}

//------------------------------------------------------------------------------
// Name:    userPressedCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedCancel:(id)sender
{
    [self showSpinner:nil];
    _searchBar.text=@"";
    [_searchBar resignFirstResponder];
    [self.fetchOperation  cancel];
    self.fetchOperation= nil;
    self.restaurantsArray= nil;
    self.peopleArray= nil;
    self.doingSearchNow= NO;
    [self.tableRestaurants reloadData];
    [self.tablePeople reloadData];
}

//------------------------------------------------------------------------------
// Name:    doSelectList
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectList:(id)sender
{
    if (_currentFilter == FILTER_LISTS ) {
        return;
    }
    _currentFilter = FILTER_LISTS;
   
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    // RULE: If there is a search string then redo the current search for the new context.
    if (_searchBar.text.length) {
        [self clearResultsTables];
        [self doSearch];
    }
}

//------------------------------------------------------------------------------
// Name:    doSelectPeople
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectPeople:(id)sender
{
    if (_currentFilter == FILTER_PEOPLE) {
        return;
    }
    _currentFilter = FILTER_PEOPLE;

    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    // RULE: If there is a search string then redo the current search for the new context.
    if (_searchBar.text.length) {
        [self clearResultsTables];
        [self doSearch];
    }
}

//------------------------------------------------------------------------------
// Name:    doSelectPlaces
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectPlaces:(id)sender
{
    if (_currentFilter == FILTER_PLACES) {
        return;
    }
    _currentFilter = FILTER_PLACES;
    
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    // RULE: If there is a search string then redo the current search for the new context.
    if (_searchBar.text.length) {
        [self clearResultsTables];
        [self doSearch];
    }
}

//------------------------------------------------------------------------------
// Name:    doSelectYou
// Purpose:
//------------------------------------------------------------------------------
- (void)doSelectYou:(id)sender
{
    if  (_currentFilter == FILTER_YOU ) {
        return;
    }
    _currentFilter = FILTER_YOU;
    if  (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    // RULE: If there is a search string then redo the current search for the new context.
    if ( _searchBar.text.length) {
        [self clearResultsTables];
        [self doSearch];
    }
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h = self.view.bounds.size.height;
    float w = self.view.bounds.size.width;
    float spacing = kGeomSpaceInter;
    float y = 0;
    float x = 0;
    
    _searchBar.frame=  CGRectMake(0,y,w-kGeomButtonWidth,kGeomHeightSearchBar);
    
    _buttonCancel.frame=  CGRectMake( w-kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     y+kGeomCancelButtonInteriorPadding,
                                     kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     kGeomHeightSearchBar+-2*kGeomCancelButtonInteriorPadding);
    y += kGeomHeightSearchBar;
    
    _filterView.frame=  CGRectMake(0,  y,w,kGeomHeightFilters);
    y += kGeomHeightButton;

    _tableRestaurants.frame=  CGRectMake(0,y,w, h-y);
    _tablePeople.frame=  CGRectMake(0,y,w, h-y);
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView==_tableRestaurants) {
        RestaurantTVCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        if (!cell) {
            cell=  [[RestaurantTVCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER ];
        }
        NSInteger row = indexPath.row;
        if  (!self.doingSearchNow) {
            cell.restaurant= _restaurantsArray[row];
            
        }
        [cell updateConstraintsIfNeeded];
        return cell;
    }
    else {
        UserTVCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        if (!cell) {
            cell = [[UserTVCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER ];
        }
        NSInteger row = indexPath.row;
        if  (!self.doingSearchNow) {
            UserObject *user=_peopleArray[row];
            [cell setUser: user];
        }
        [cell updateConstraintsIfNeeded];
        return cell;
    }
}

//------------------------------------------------------------------------------
// Name:    scrollViewWillBeginDragging
// Purpose: On smallscreen devices like iPhones, remove the keyboard so that
//       the user can see what they're scrolling through.
//------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        [_searchBar resignFirstResponder];
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightHorizontalListRow;
}

//------------------------------------------------------------------------------
// Name:    didSelectRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    
    if  (self.doingSearchNow) {
        return;
    }
    
    NSInteger row= indexPath.row;
    
    if ( tableView==_tableRestaurants) {
        if  (row >= _restaurantsArray.count ) {
            return;
        }
        
        RestaurantObject *ro = [_restaurantsArray objectAtIndex:indexPath.row];
        
        RestaurantVC *vc = [[RestaurantVC alloc] init];
        vc.title = trimString(ro.name);
        vc.restaurant = ro;
        [self.navigationController pushViewController:vc animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        if  (row >= _peopleArray.count ) {
            return;
        }
        
        UserObject *u = [_peopleArray objectAtIndex:indexPath.row];
        
        ProfileVC *vc= [[ProfileVC  alloc]   init];
        vc.userID= u.userID;
        vc.userInfo= u;
        
        [self.navigationController pushViewController:vc animated:YES];
       
    }
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if  (self.doingSearchNow) {
        return 0;
    }
    
    if ( tableView==_tableRestaurants) {
        return self.restaurantsArray.count;
    }  else {
        return self.peopleArray.count;
    }
}

@end
