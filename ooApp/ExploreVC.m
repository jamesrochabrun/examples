//
//  ExploreVC.m
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
#import "ExploreVC.h"
#import "LocationManager.h"
#import "Settings.h"
#import "RestaurantTVCell.h"
#import "RestaurantVC.h"
#import "UserTVCell.h"
#import "ProfileVC.h"
#import "OOFilterView.h"
#import "AutoCompleteObject.h"
#import "TagObject.h"

typedef enum: char {
    FILTER_NONE = -1,
    FILTER_PLACES = 1,
    FILTER_PEOPLE = 0,
    FILTER_YOU = 2,
} FilterType;

#define SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER  @"searchRestaurantsCell"
#define SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER_EMPTY  @"searchRestaurantsCellEmpty"
#define SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER  @"searchPeopleCell"
#define SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER_EMPTY  @"searchPeopleCellEmpty"

@interface ExploreVC ()

@property (nonatomic, strong) UILabel *labelMessageAboutGoogle;
@property (nonatomic, strong) OOFilterView *filterView;
@property (nonatomic, strong) UIButton *buttonCancel;
@property (nonatomic, strong) UITableView *tableRestaurants;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tablePeople;
@property (nonatomic, assign) FilterType currentFilter;
@property (nonatomic, strong) NSArray *restaurantsArray;
@property (nonatomic, strong) NSArray *peopleArray;
@property (nonatomic, strong) AFHTTPRequestOperation *fetchOperation;
@property (atomic, assign) BOOL doingSearchNow;
@property (nonatomic, strong) UILabel *labelPreSearchInstructiveMessage1;
@property (nonatomic, strong) UILabel *labelPreSearchInstructiveMessage2;
@property (nonatomic, strong) UILabel *labelPreSearchInstructiveMessage3;
@property (nonatomic, assign) BOOL haveSearchedPeople, haveSearchedPlaces, haveSearchedYou;
@property (nonatomic, strong) UIButton *changeLocationButton;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@end

@implementation ExploreVC

- (void)dealloc
{
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _currentFilter=FILTER_NONE;
    
    _currentLocation= CLLocationCoordinate2DMake(0, 0);
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc]
           initWithHeader:LOCAL(@"Search")
           subHeader:LOCAL(@"around here")];
    
    self.navTitle = nto;
    
    _searchBar = [UISearchBar new];
    [self.view addSubview:_searchBar];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _searchBar.placeholder = LOCAL(@"Type your search here");
    _searchBar.barTintColor = UIColorRGBA(kColorText);
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.delegate = self;
    _searchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    _searchBar.layer.borderColor = UIColorRGBA(kColorNavBar).CGColor;
    _searchBar.layer.borderWidth = 1;


    UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];
    searchTextField.textAlignment = NSTextAlignmentCenter;
    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
//    _buttonCancel= makeButton(self.view, LOCAL(@"Cancel"), kGeomFontSizeH2, UIColorRGBA(kColorBordersAndLines), UIColorRGBA(kColorClear), self, @selector(userPressedCancel:), .5);
    _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonCancel withText:@"Cancel" fontSize:kGeomFontSizeH2 width:kGeomWidthButton height:kGeomHeightButton backgroundColor:kColorButtonBackground textColor:kColorText borderColor:kColorBordersAndLines target:self selector:@selector(userPressedCancel:)];
    [self.view addSubview:_buttonCancel];
    
    self.filterView = [[OOFilterView alloc] init];
    [ self.view addSubview:_filterView];
    [_filterView addFilter:LOCAL(@"People") target:self selector:@selector(userTappedOnPeopleFilter:)];//  index 0
    [_filterView addFilter:LOCAL(@"Places") target:self selector:@selector(userTappedOnPlacesFilter:)];//  index 1
    [_filterView addFilter:LOCAL(@"You") target:self selector:@selector(userTappedOnYouFilter:)];//  index 2
    
    self.tableRestaurants = makeTable(self.view,self);
    _tableRestaurants.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tableRestaurants registerClass:[RestaurantTVCell class]
              forCellReuseIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER];
    [_tableRestaurants registerClass:[UITableViewCell class]
              forCellReuseIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER_EMPTY];
    
    self.tablePeople = makeTable(self.view,self);
    _tablePeople.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    [_tablePeople registerClass:[UserTVCell class]
         forCellReuseIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER];
    [_tablePeople registerClass:[UITableViewCell class]
         forCellReuseIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER_EMPTY];
    
//    self.activityView=[UIActivityIndicatorView new];
//    [self.view addSubview:_activityView];
//    _activityView.hidden =  YES;
//    [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    _tablePeople.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableRestaurants.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.labelPreSearchInstructiveMessage1 = makeLabel( self.view, @"Find Your Foodies (Search for Users by Name)", kGeomFontSizeHeader);
    self.labelPreSearchInstructiveMessage1.textColor = UIColorRGBA(kColorGrayMiddle);
    
    self.labelPreSearchInstructiveMessage2 = makeLabel( self.view, @"Search for places on your lists", kGeomFontSizeHeader);
    self.labelPreSearchInstructiveMessage2.textColor = UIColorRGBA(kColorGrayMiddle);
    
    self.labelPreSearchInstructiveMessage3 = makeLabel( self.view, @"Search for places to eat\rPowered by Google™", kGeomFontSizeHeader);
    self.labelPreSearchInstructiveMessage3.textColor = UIColorRGBA(kColorGrayMiddle);
    
    [self changeFilter:FILTER_PLACES];

    [self removeNavButtonForSide:kNavBarSideTypeLeft];
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
    ANALYTICS_SCREEN(@(object_getClassName(self)));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuOpened:)
                                                 name:kNotificationMenuWillOpen
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
// Name:    keyboardHidden
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardHidden:(NSNotification *)not
{
    _tableRestaurants.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tablePeople.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
// Name:    doSearchFor
// Purpose:
//------------------------------------------------------------------------------
- (void)doSearchFor: (NSString*)expression
{
    if (self.doingSearchNow) {
        NSLog (@"CANNOT SEARCH NOW");
        return;
    }
    
    self.doingSearchNow= YES;
    __weak ExploreVC *weakSelf= self;
    
    switch (_currentFilter) {
        case  FILTER_NONE:
            break;
            
        case FILTER_PEOPLE:  {
            NSString *searchText=_searchBar.text;
            NSLog (@"SEARCHING FOR USER:  %@",searchText);
            self.haveSearchedPeople=YES;
            [self showAppropriateTableAnimated:NO];
            
            self.fetchOperation= [OOAPI getUsersWithKeyword:searchText
                                                    success:^(NSArray *users) {
                                                        [weakSelf performSelectorOnMainThread:@selector(loadPeople:)
                                                                                   withObject:users
                                                                                waitUntilDone:NO];
                                                        
                                                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                        NSLog  (@"ERROR FETCHING USERS BY KEYWORD: %@",e );
                                                    }
                                  ];
        } break;
            
        case FILTER_YOU: {
            _doingSearchNow=YES;
            
            self.haveSearchedYou=YES;
            [self showAppropriateTableAnimated:NO];
            
            CLLocationCoordinate2D location=[LocationManager sharedInstance].currentUserLocation;
            if (!location.latitude && !location.longitude) {
                // XX
                NSLog (@"NOTE: WE DO NOT HAVE USERS LOCATION... USING SAN FRAN.");
                location.latitude = 37.775;
                location.longitude = -122.4183333;
            }
            
            UserObject*user= [Settings sharedInstance].userObject;
            self.fetchOperation= [OOAPI getRestaurantsViaYouSearchForUser: user.userID
                                                                 withTerm: expression
                                                                  success:^(NSArray *restaurants) {
                                                                      [weakSelf performSelectorOnMainThread:@selector(loadRestaurants:)
                                                                                                 withObject:restaurants
                                                                                              waitUntilDone:NO];
                                                                      
                                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                                      NSLog  (@"ERROR FETCHING YOU'S RESTAURANTS: %@",e );

                                                                  }
                                  ];
        } break;
            
        case  FILTER_PLACES: {
            _doingSearchNow=YES;
            
            self.haveSearchedPlaces=YES;
            [self showAppropriateTableAnimated:NO];
            
            CLLocationCoordinate2D location=_currentLocation;
            if (!location.latitude && !location.longitude) {
                location=  [LocationManager sharedInstance].currentUserLocation;
                if (!location.latitude && !location.longitude) {
                    
                    NSLog (@"NOTE: WE DO NOT HAVE USERS LOCATION... USING SAN FRAN.");
                    location.latitude = 37.775;
                    location.longitude = -122.4183333;
                }
            }
            
            OOAPI *api= [[OOAPI alloc] init];
            
            self.fetchOperation = [api getRestaurantsWithKeywords: @[expression]
                                                      andLocation:location
                                                        andFilter: @"" // Not used.
                                                       andRadius:kMaxSearchRadius
                                                     andOpenOnly:NO
                                                         andSort:kSearchSortTypeDistance
                                                        minPrice:0
                                                        maxPrice:3
                                                          isPlay:NO
                                                         success:^(NSArray *restaurants) {
                                                             [weakSelf performSelectorOnMainThread:@selector(loadRestaurants:)
                                                                                        withObject:restaurants
                                                                                     waitUntilDone:NO];
                                                             
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                             NSLog  (@"ERROR FETCHING RESTAURANTS: %@",e );
                                                         }
                                  ];
        } break;
    }
    
}

//------------------------------------------------------------------------------
// Name:    changeFilter
// Purpose:
//------------------------------------------------------------------------------
- (void)changeFilter:(FilterType)which
{
    if  (which == _currentFilter ) {
        return;
    }
    
    if (which == FILTER_PEOPLE) {
        _searchBar.placeholder = kSearchPlaceholderPeople;
    } else if (which == FILTER_PLACES) {
        _searchBar.placeholder = kSearchPlaceholderPlaces;
    } else if (which == FILTER_YOU) {
        _searchBar.placeholder = kSearchPlaceholderYou;
    } else {
        _searchBar.placeholder = @"Type your search here";
    }
    [_filterView setCurrent:which];
    
    self.currentFilter = which;
    
    [self showAppropriateTableAnimated:NO];

    // RULE: If the user was searching for "Fred" in the people category and
    //  then switched to the places category, then we should redo the search
    //  in the new category.
    //
    if (_searchBar.text.length) {
        [self doSearchFor:_searchBar.text];
    }
}

//------------------------------------------------------------------------------
// Name:    searchBarSearchButtonClicked
// Purpose:
//------------------------------------------------------------------------------
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    [self doSearchFor:_searchBar.text];
}

#pragma mark - LOCATION CHANGE

- (void)userPressedChangeLocation: (UIButton*)sender
{
    UINavigationController *nc = [[UINavigationController alloc] init];
    
    ChangeLocationVC *vc = [[ChangeLocationVC alloc] init];
    vc.delegate = self;
    [nc addChildViewController:vc];
    
    [nc.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorRGBA(kColorNavBar)] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setTranslucent:YES];
    nc.view.backgroundColor = UIColorRGBA(kColorClear);
    
    [self.navigationController presentViewController:nc animated:YES completion:^{
        nc.topViewController.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    }];
}

- (void)changeLocationVC:(ChangeLocationVC *)changeLocationVC locationSelected:(CLPlacemark *)placemark {
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    _currentLocation = placemark.location.coordinate;
    self.navTitle.subheader = [Common locationString:placemark];
    [self.navTitleView setNavTitle:self.navTitle];
    if ([_searchBar.text length] && _currentFilter == FILTER_PLACES) {
        [self doSearchFor:_searchBar.text];
    }
}

- (void)changeLocationVCCanceled:(ChangeLocationVC *)changeLocationVC {
    _currentLocation = [LocationManager sharedInstance].currentUserLocation;
    self.navTitle.subheader = @"around here";
    [self.navTitleView setNavTitle:self.navTitle];
    if ([_searchBar.text length] && _currentFilter == FILTER_PLACES) {
        [self doSearchFor:_searchBar.text];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

#pragma mark - SEARCH BAR

//------------------------------------------------------------------------------
// Name:    textDidChange
// Purpose:
//------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString* text = _searchBar.text;
    if (!text.length) {
        // Clear the appropriate table; no need to start a search.
        if (_currentFilter == FILTER_PEOPLE ) {
            [self loadPeople:@[]];
        } else {
            [self loadRestaurants:@[]];
        }
        return;
    }
    
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    if ( _currentFilter == FILTER_PEOPLE  || _currentFilter == FILTER_YOU ) {
        [self doSearchFor: text];
    } else {
        [self  doLayout];
        
        // RULE: In order to minimize the number of Google search lookups, we only search when the user taps on Search.
        if ( text.length >= 3) {
            [self doSearchFor: text];
        } else {
            [self clearResultsTables];
        }
    }
}

- (void)enableMessageLabel:(int)n
{
    _labelPreSearchInstructiveMessage1.alpha= n==0?1:0;
    _labelPreSearchInstructiveMessage2.alpha= n==1?1:0;
    _labelPreSearchInstructiveMessage3.alpha= n==2?1:0;
}

- (void)showAppropriateTableAnimated:(BOOL)animated
{
    [self.view bringSubviewToFront:_labelPreSearchInstructiveMessage1];
    [self.view bringSubviewToFront:_labelPreSearchInstructiveMessage2];
    [self.view bringSubviewToFront:_labelPreSearchInstructiveMessage3];
    __weak ExploreVC *weakSelf = self;
    switch (_currentFilter) {
        case FILTER_PEOPLE:
            _searchBar.placeholder = kSearchPlaceholderPeople;
            [self removeNavButtonForSide:kNavBarSideTypeRight];
            [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];

            _tablePeople.hidden = NO;
            _tableRestaurants.hidden= YES;

            if (![_peopleArray count]) {
                if  (animated ) {
                    [UIView animateWithDuration:.2
                                     animations:^{
                                         [weakSelf enableMessageLabel:0];
                                     }];
                } else {
                    [self enableMessageLabel:0];
                }
            } else {
                [self enableMessageLabel:-1];
            }

            break;
            
        case FILTER_YOU:
            _searchBar.placeholder = kSearchPlaceholderYou;
            [self removeNavButtonForSide:kNavBarSideTypeRight];
            [self addNavButtonWithIcon:@"" target:nil action:nil forSide:kNavBarSideTypeRight isCTA:NO];
            
            _tablePeople.hidden = YES;
            _tableRestaurants.hidden= NO;
            
            if (![_restaurantsArray count]) {
                if (animated) {
                    [UIView animateWithDuration:.2
                                     animations:^{
                                         [weakSelf enableMessageLabel:1];
                                     }];
                } else {
                    [self enableMessageLabel:1];
                }
            } else {
                [self enableMessageLabel:-1];
            }
            break;
            
        case FILTER_PLACES:
            _searchBar.placeholder = kSearchPlaceholderPlaces;
            [self removeNavButtonForSide:kNavBarSideTypeRight];
            [self addNavButtonWithIcon:kFontIconLocation target:self action:@selector(userPressedChangeLocation:) forSide:kNavBarSideTypeRight isCTA:NO];

            _tablePeople.hidden = YES;
            _tableRestaurants.hidden = NO;
            
            if (![_restaurantsArray count]) {
                if  (animated ) {
                    [UIView animateWithDuration:.2
                                     animations:^{
                                         [weakSelf enableMessageLabel:2];
                                     }];
                } else {
                    [self enableMessageLabel:2];
                }
            } else {
                [self enableMessageLabel:-1];
            }
            break;
            
        case FILTER_NONE:
            [self enableMessageLabel:-1];

            _tablePeople.hidden = YES;
            _tableRestaurants.hidden= YES;
            break;

    }
    [self.view setNeedsDisplay];
}

#pragma mark - TABLES

- (void)clearResultsTables
{
    self.restaurantsArray = nil;
    [self.tableRestaurants reloadData];
    
    self.peopleArray = nil;
    [self.tablePeople reloadData];
}

//------------------------------------------------------------------------------
// Name:    loadRestaurants
// Purpose:
//------------------------------------------------------------------------------
- (void)loadRestaurants: (NSArray*)array
{
    self.doingSearchNow = NO;
    self.fetchOperation = nil;
    
    self.restaurantsArray = array;
    [self.tableRestaurants reloadData];
    
    self.peopleArray = nil;
    [self.tablePeople reloadData];
    
    [self showAppropriateTableAnimated:NO];
    
}

//------------------------------------------------------------------------------
// Name:    loadPeople
// Purpose:
//------------------------------------------------------------------------------
- (void)loadPeople:(NSArray *)array
{
    self.doingSearchNow = NO;
    self.fetchOperation = nil;
    
    self.peopleArray = array;
    [self.tablePeople reloadData];
    
    self.restaurantsArray = nil;
    [self.tableRestaurants reloadData];
    
    [self showAppropriateTableAnimated:NO];
}

//------------------------------------------------------------------------------
// Name:    cancelSearch
// Purpose:
//------------------------------------------------------------------------------
- (void)cancelSearch
{
    [self.fetchOperation cancel];
    self.fetchOperation = nil;
    self.doingSearchNow = NO;
    [self showAppropriateTableAnimated:NO];
}

//------------------------------------------------------------------------------
// Name:    userPressedCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedCancel:(id)sender
{
    _searchBar.text=@"";
    [_searchBar resignFirstResponder];
    
    self.restaurantsArray= nil;
    self.peopleArray= nil;
    
    [self cancelSearch];
    
    [self.tableRestaurants reloadData];
    [self.tablePeople reloadData];
}

//------------------------------------------------------------------------------
// Name:    userTappedOnPeopleFilter
// Purpose:
//------------------------------------------------------------------------------
- (void)userTappedOnPeopleFilter:(id)sender
{
    _searchBar.text=@"";
    [self clearResultsTables];
   [_searchBar resignFirstResponder];
    
    if (_currentFilter == FILTER_PEOPLE) {
        return;
    }
    _currentFilter = FILTER_PEOPLE;
    
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    [self showAppropriateTableAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    userTappedOnPlacesFilter
// Purpose:
//------------------------------------------------------------------------------
- (void)userTappedOnPlacesFilter:(id)sender
{
    _searchBar.text=@"";
    [self clearResultsTables];
    [_searchBar resignFirstResponder];

    if (_currentFilter == FILTER_PLACES) {
        return;
    }
    _currentFilter = FILTER_PLACES;

    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    [self showAppropriateTableAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    userTappedOnYouFilter
// Purpose:
//------------------------------------------------------------------------------
- (void)userTappedOnYouFilter:(id)sender
{
    _searchBar.text=@"";
    [self clearResultsTables];
    [_searchBar resignFirstResponder];

    if  (_currentFilter == FILTER_YOU ) {
        return;
    }
    _currentFilter = FILTER_YOU;
    
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    [self showAppropriateTableAnimated:YES];
    
}

- (void)menuOpened:(NSNotification*)not
{
    NSLog (@"MENU WAS OPENED.");
    [_searchBar resignFirstResponder];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    
    CGFloat y = 0;
    
    _searchBar.frame = CGRectMake(0, y, w-kGeomWidthButton, kGeomHeightSearchBar);
    _buttonCancel.frame = CGRectMake(w-kGeomWidthButton-kGeomCancelButtonInteriorPadding,
                                     (kGeomHeightSearchBar-kGeomHeightButton)/2,
                                     kGeomWidthButton-kGeomCancelButtonInteriorPadding,
                                     kGeomHeightButton);
    y += kGeomHeightSearchBar;
    
    _filterView.frame = CGRectMake(0, y, w, kGeomHeightFilters);
    y += kGeomHeightFilters;
    
    CGFloat psih = 100;
    _labelPreSearchInstructiveMessage1.frame = CGRectMake((w-200)/2, y+(h-y-psih)/3, 200, psih);
    _labelPreSearchInstructiveMessage2.frame = CGRectMake((w-200)/2, y+(h-y-psih)/3, 200, psih);
    _labelPreSearchInstructiveMessage3.frame = CGRectMake((w-200)/2, y+(h-y-psih)/3, 200, psih);
    _tableRestaurants.frame = CGRectMake(0, y, w, h-y);
    _tablePeople.frame = CGRectMake(0, y, w, h-y);
}

//------------------------------------------------------------------------------
// Name:    cellForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView ==_tableRestaurants) {
        if ( !_restaurantsArray.count) {
            UITableViewCell *cell;
            cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
            cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (_doingSearchNow) {
                cell.textLabel.text = @"Searching...";
            } else {
                if (_searchBar.text.length > 2) {
                    cell.textLabel.text = @"No restaurants found for that search term.";
                } else if (_searchBar.text.length > 0) {
                    cell.textLabel.text = @"Type in at least three characters";
                } else {
                    cell.textLabel.text = @"";
                }
            }
            cell.textLabel.textColor = UIColorRGBA(kColorText);
            cell.textLabel.font = [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader];
            return cell;
        }
        
        RestaurantTVCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        
        NSInteger row = indexPath.row;
        if  (!self.doingSearchNow) {
            cell.restaurant= _restaurantsArray[row];
        }
        cell.nc = self.navigationController;
        [cell updateConstraintsIfNeeded];
        return cell;
    }
    else if ( tableView == _tablePeople) {
        if ( !_peopleArray.count) {
            
            UITableViewCell *cell;
            cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER_EMPTY forIndexPath:indexPath];
            cell.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
            if ( _doingSearchNow) {
                cell.textLabel.text=  @"Searching...";
            } else {
                if (_searchBar.text.length ) {
                    cell.textLabel.text=  @"No people found for that search term.";
                } else {
                    cell.textLabel.text= nil;
                }
            }
            cell.textLabel.textColor=  UIColorRGBA(kColorText);
            cell.textLabel.font= [UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        UserTVCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.delegate= self;
        
        NSInteger row = indexPath.row;
        if  (!self.doingSearchNow) {
            UserObject *user = _peopleArray[row];
            [cell setUser: user];
        }
        [cell updateConstraintsIfNeeded];
        return cell;
    }
    return nil;
}

- (void)userImageTapped:(UserObject*)user
{
    if (!user) {
        return;
    }
    
    ProfileVC *vc = [[ProfileVC  alloc]   init];
    vc.userID = user.userID;
    vc.userInfo = user;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

//------------------------------------------------------------------------------
// Name:    scrollViewWillBeginDragging
// Purpose: On smallscreen devices like iPhones, remove the keyboard so that
//       the user can see what they're scrolling through.
//------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        [_searchBar resignFirstResponder];
}

//------------------------------------------------------------------------------
// Name:    heightForRowAtIndexPath
// Purpose:
//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView==_tableRestaurants && !_restaurantsArray.count) {
        return 44;
    }
    if ( tableView==_tablePeople && !_peopleArray.count) {
        return 44;
    }
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
    
    NSInteger row = indexPath.row;
    
    if ( tableView == _tableRestaurants) {
        if  (row >= _restaurantsArray.count ) {
            return;
        }
        
        RestaurantObject *ro = [_restaurantsArray objectAtIndex:indexPath.row];
        
        RestaurantVC *vc = [[RestaurantVC alloc] init];
        ANALYTICS_EVENT_UI(@"RestaurantVC-from-Search");
        vc.title = trimString(ro.name);
        vc.restaurant = ro;
        vc.eventBeingEdited = self.eventBeingEdited;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ( tableView == _tablePeople) {
        if  (row >= _peopleArray.count ) {
            return;
        }
        
        UserObject *u = [_peopleArray objectAtIndex:indexPath.row];
        
        ProfileVC *vc = [[ProfileVC  alloc]   init];
        vc.userID = u.userID;
        vc.userInfo = u;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//------------------------------------------------------------------------------
// Name:    numberOfRowsInSection
// Purpose:
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.doingSearchNow) {
        return 0;
    }
    
    if ( tableView ==_tableRestaurants) {
        if ( !_restaurantsArray.count) {
            // This is the cell that tells them there are no data.
            return 1;
        }
        return self.restaurantsArray.count;
    }
    else {
        if ( !_peopleArray.count) {
            // This is the cell that tells them there are no data.
            return 1;
        }
        return self.peopleArray.count;
    }
}

@end
