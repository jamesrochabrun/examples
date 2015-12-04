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
#import "AutoCompleteObject.h"
#import "TagObject.h"

typedef enum: char {
    FILTER_NONE = -1,
    FILTER_PLACES = 1,
    FILTER_PEOPLE = 0,
//    FILTER_LISTS= 0,
    FILTER_YOU = 2,
} FilterType;

#define SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER  @"searchRestaurantsCell"
#define SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER_EMPTY  @"searchRestaurantsCellEmpty"
#define SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER  @"searchPeopleCell"
#define SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER_EMPTY  @"searchPeopleCellEmpty"

@interface SearchVC ()
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong)  UILabel *labelMessageAboutGoogle;
@property (nonatomic,strong) OOFilterView *filterView;
@property (nonatomic,strong) UIButton *buttonCancel;
@property (nonatomic,strong) UITableView *tableRestaurants;
@property (nonatomic,strong) UITableView *tablePeople;
@property (nonatomic,assign) FilterType currentFilter;
@property (nonatomic,strong) NSArray *restaurantsArray;
@property (nonatomic,strong) NSArray *peopleArray;
@property (nonatomic,strong) NSMutableArray *keywordButtonsArray;
@property (nonatomic,strong) AFHTTPRequestOperation *fetchOperation;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property (atomic,assign) BOOL doingSearchNow;
@property (nonatomic,strong) NSArray *keywordsArray;
@property (nonatomic,strong) UIView *viewForKeywordButtons;
@property (nonatomic,assign) NSUInteger numberOfMatchingKeywords;
@end

@implementation SearchVC

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
    
    NavTitleObject *nto;
    nto = [[NavTitleObject alloc]
           initWithHeader:LOCAL(@"Search")
           subHeader: LOCAL(@"for restaurants and people")];
    
    self.navTitle = nto;
    
    self.viewForKeywordButtons= makeView( self.view,  UIColorRGB(0xff808080));
    for (int i=0; i <5 ; i++) {
        UIButton *button= makeButton(self.viewForKeywordButtons,   @"", kGeomFontSizeHeader, WHITE, CLEAR,
                                     self, @selector(userPressedKeyword:) , 0);
        button.tag=  i;
        [_keywordButtonsArray addObject: button];

    }
    
    self.labelMessageAboutGoogle=  makeLabel( self.view,  @"Search is powered by Google.", kGeomFontSizeDetail);
    _labelMessageAboutGoogle.textColor=  UIColorRGB(0xff808000);
    
    _searchBar= [UISearchBar new];
    [ self.view addSubview:_searchBar];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _searchBar.placeholder = LOCAL( @"Type your search here");
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:UIColorRGBA(kColorWhite)}];
    _searchBar.barTintColor = UIColorRGBA(kColorBlack);
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.delegate = self;
    _searchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    
    _buttonCancel= makeButton(self.view, LOCAL(@"Cancel") , kGeomFontSizeHeader, UIColorRGBA(kColorOffBlack), CLEAR, self, @selector(userPressedCancel:), .5);
    [_buttonCancel setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
    
    self.filterView = [[OOFilterView alloc] init];
    [ self.view addSubview:_filterView];
    [_filterView addFilter:LOCAL(@"People") target:self selector:@selector(doSelectPeople:)];//  index 0
    [_filterView addFilter:LOCAL(@"Places") target:self selector:@selector(doSelectPlaces:)];//  index 1
    [_filterView addFilter:LOCAL(@"You") target:self selector:@selector(doSelectYou:)];//  index 2
    
    [self changeFilter:FILTER_PLACES];

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
    
    self.activityView=[UIActivityIndicatorView new];
    [self.view addSubview:_activityView];
    _activityView.hidden =  YES;
    [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    _tablePeople.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableRestaurants.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setUpKeywordsArray];
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
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuOpened:) name:kNotificationMenuWillOpen object:nil];
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
// Name:    showSpinner
// Purpose: Mechanism to give me diagnostic feedback.
//------------------------------------------------------------------------------
- (void)showSpinner: (id)show
{
    float h =  self.view.bounds.size.height;
    float w =  self.view.bounds.size.width;
    CGRect r = CGRectMake(w/2-50,h/3,100,100);
    _activityView.frame = r;
    _activityView.hidden =  show ? NO:YES;
    if (show) {
        [_activityView startAnimating];
    } else {
        [_activityView stopAnimating];
    }
    [self.view bringSubviewToFront:_activityView];
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
    __weak SearchVC *weakSelf= self;
    
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
                                                        
                                                    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                                                        NSLog  (@"ERROR FETCHING USERS BY KEYWORD: %@",e );
                                                        
                                                        [weakSelf performSelectorOnMainThread:@selector(showSpinner:)
                                                                                   withObject:nil
                                                                                waitUntilDone:NO];
                                                    }
                                  ];
        } break;
            
//        case FILTER_LISTS: {
//            
//        } break;
            
        case FILTER_YOU: {
            
        } break;
            
        case  FILTER_PLACES: {
            
            [self showSpinner: @""];
            _doingSearchNow=YES;

            CLLocationCoordinate2D location=[LocationManager sharedInstance].currentUserLocation;
            if (!location.latitude && !location.longitude) {
                // XX
                NSLog (@"NOTE: WE DO NOT HAVE USERS LOCATION... USING SAN FRAN.");
                location.latitude = 37.775;
                location.longitude = -122.4183333;
            }
            
            OOAPI *api= [[OOAPI  alloc] init];
            
            self.fetchOperation= [api getRestaurantsWithKeywords: @[ expression ]
                                                     andLocation:location
                                                       andFilter: @"" // Not used.
                                                       andRadius:10000
                                                     andOpenOnly:NO
                                                         andSort:kSearchSortTypeBestMatch
                                                         success:^(NSArray *restaurants) {
                                                             [weakSelf performSelectorOnMainThread:@selector(loadRestaurants:)
                                                                                        withObject:restaurants
                                                                                     waitUntilDone:NO];
                                                             
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
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
- (void)changeFilter:(FilterType)which
{
    if  (which == _currentFilter ) {
        return;
    }
    
    [_filterView setCurrent:which];
    
    self.currentFilter = which;
    
    [self showAppropriateTable];
    
    // RULE: If the user was searching for "Fred" in the people category and
    //  then switched to the places category, then we should redo the search
    //  in the new category.
    //
    if (_searchBar.text.length) {
        [self doSearchFor: _searchBar.text];
    }
}

//------------------------------------------------------------------------------
// Name:    textDidChange
// Purpose:
//------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString* text = _searchBar.text;
    if (!text.length) {
        // Shrink the keyword area.
        _numberOfMatchingKeywords=0;
        [UIView  beginAnimations:nil context:nil];
        [self  doLayout];
        [UIView  commitAnimations];
        
        // Clear the appropriate table; no need to start a search.
        if (_currentFilter == FILTER_PEOPLE ) {
            [self loadPeople:@[]];
        } else {
            [self loadRestaurants:@[]];
        }
        return;
    }
    
    int noKeywords= _numberOfMatchingKeywords ?1:0;
    [self doKeywordLookup: text];
    int stillNoKeywords= _numberOfMatchingKeywords ?1:0;
    if  (noKeywords ^ stillNoKeywords ) {
        [UIView  beginAnimations:nil context:nil];
        [self  doLayout];
        [UIView  commitAnimations];
    } else {
        [self  doLayout];
    }
    
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    [self doSearchFor: text];
}

- (void) setUpKeywordsArray
{
    if (_keywordsArray)
        return;
    
    __weak SearchVC *weakSelf = self;
    [OOAPI getAllTagsWithSuccess:^(NSArray *tags) {
        NSMutableArray *results= [NSMutableArray new];
        for (TagObject* tag   in  tags) {
            NSString *tagString=tag.term;
            if  (tagString ) {
                [results  addObject: tagString];
            }
            weakSelf.keywordsArray= results;
        }
        if  (!weakSelf.keywordsArray.count) {
                    [weakSelf setUpFallbackKeywords];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog  (@"FAILED TO OBTAIN TAGS.");
        [weakSelf setUpFallbackKeywords];
    }];
}

- (void)setUpFallbackKeywords
{
    // RULE: In the event of a backend problem, use the default set.
    self.keywordsArray=  @[
                      @"American", @"Asian", @"Bagels", @"Bakery", @"Bar", @"BBQ", @"Breakfast", @"Brewery", @"Burgers", @"Burritos", @"Café", @"Cantonese", @"Chinese", @"Churrascaria", @"Cocktail", @"Coffee Shop", @"Comfort Food", @"Cuban", @"Dim Sum", @"Diner", @"Dive Bar", @"Ethiopian", @"Event Space", @"Falafel", @"Fast Food", @"Food", @"French", @"Fried Chicken", @"Gastropub", @"Gay Bar", @"German", @"Greek", @"Himalayan", @"Hot Dogs", @"Hotel", @"Hotpot", @"Ice Cream", @"Indian", @"Irish", @"Italian", @"Japanese", @"Jazz Club", @"Jiangsu", @"Juice Bar", @"Korean", @"Latin American", @"Lounge", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Molecular Gastronomy", @"Moroccan", @"New American", @"Nightclub", @"Nightlife", @"Noodles", @"Pakistani", @"Peruvian", @"Pizza", @"Pub", @"Ramen", @"Restaurant", @"Salad", @"Sandwiches", @"Seafood", @"South American", @"South Indian", @"Sports Bar", @"Steakhouse", @"Sushi", @"Tacos", @"Tapas", @"Tea Room", @"Thai", @"Turkish", @"Vegetarian / Vegan", @"Vietnamese", @"Wine Bar", @"Winery", @"Wings"
                      ];
    
}

- (void)clearResultsTables
{
    self.restaurantsArray = nil;
    [self.tableRestaurants reloadData];
    
    self.peopleArray = nil;
    [self.tablePeople reloadData];
}

- (void)doKeywordLookup: (NSString*)expression
{
    NSMutableArray*array= [NSMutableArray new];
    int  counter= 0;
    const unsigned maximumKeywords= 5;
    expression= [ expression lowercaseString];
    [_keywordButtonsArray removeAllObjects];
    
    for (NSString* string  in _keywordsArray) {
        NSString *lowerString= [ string lowercaseString];
        NSLog  (@"COMPARING STRINGS %@, %@", expression,lowerString);
        if ( [lowerString  containsString:expression]) {
            [ array addObject: [NSString  stringWithFormat: @"#%@", string]];
            
            counter ++;
            if  (counter ==maximumKeywords ) {
                break;
            }
        }
    }
    _numberOfMatchingKeywords=counter;
    NSLog  (@"KEYWORDS: %@",array);
}

- (void)userPressedKeyword: (UIButton*) button
{
    NSLog  (@"USER PRESSED KEYWORD BUTTON %d",button.tag);
    message( @"user pressed keyword");
}

- (void)showAppropriateTable
{
    switch (_currentFilter) {
//        case FILTER_LISTS:
//            _tablePeople.hidden = YES;
//            _tableRestaurants.hidden= NO;
//            break;
        case FILTER_PEOPLE:
            _tablePeople.hidden = NO;
            _tableRestaurants.hidden= YES;
            break;
        case FILTER_YOU:
            _tablePeople.hidden = YES;
            _tableRestaurants.hidden= NO;
            break;
        case FILTER_PLACES:
                _tablePeople.hidden = YES;
                _tableRestaurants.hidden= NO;
            break;
        case FILTER_NONE:
            _tablePeople.hidden = YES;
            _tableRestaurants.hidden= YES;
            break;

    }
    
    
}

//------------------------------------------------------------------------------
// Name:    loadRestaurants
// Purpose:
//------------------------------------------------------------------------------
- (void)loadRestaurants: (NSArray*)array
{
    [self showSpinner:nil];
    self.doingSearchNow = NO;
    self.fetchOperation = nil;
    
    self.restaurantsArray = array;
    [self.tableRestaurants reloadData];
    
    self.peopleArray = nil;
    [self.tablePeople reloadData];
    
    [self showAppropriateTable];
    
}

//------------------------------------------------------------------------------
// Name:    loadPeople
// Purpose:
//------------------------------------------------------------------------------
- (void)loadPeople:(NSArray *)array
{
    [self showSpinner:nil];
    self.doingSearchNow = NO;
    self.fetchOperation = nil;
    
    self.peopleArray = array;
    [self.tablePeople reloadData];
    
    self.restaurantsArray = nil;
    [self.tableRestaurants reloadData];
    
    [self showAppropriateTable];
}

//------------------------------------------------------------------------------
// Name:    cancelSearch
// Purpose:
//------------------------------------------------------------------------------
- (void)cancelSearch
{
    [self showSpinner:nil];
    [self.fetchOperation cancel];
    self.fetchOperation = nil;
    self.doingSearchNow = NO;
    [self showAppropriateTable];
}

//------------------------------------------------------------------------------
// Name:    userPressedCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedCancel:(id)sender
{
    [self cancelSearch];
    
    _searchBar.text=@"";
    [_searchBar resignFirstResponder];
    
    self.restaurantsArray= nil;
    self.peopleArray= nil;
    
    [self.tableRestaurants reloadData];
    [self.tablePeople reloadData];
}

//------------------------------------------------------------------------------
// Name:    doSelectList
// Purpose:
//------------------------------------------------------------------------------
//- (void)doSelectList:(id)sender
//{
//    if (_currentFilter == FILTER_LISTS ) {
//        return;
//    }
//    _currentFilter = FILTER_LISTS;
//    
//    if (self.doingSearchNow) {
//        [self cancelSearch];
//    }
//    
//    // RULE: If there is a search string then redo the current search for the new context.
//    if (_searchBar.text.length) {
//        [self clearResultsTables];
//        [self doSearchFor: _searchBar.text];
//    }
//}

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
        [self doSearchFor: _searchBar.text];
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
        [self doSearchFor: _searchBar.text];
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
    if (self.doingSearchNow) {
        [self cancelSearch];
    }
    
    // RULE: If there is a search string then redo the current search for the new context.
    if (_searchBar.text.length) {
        [self clearResultsTables];
        [self doSearchFor: _searchBar.text];
    }
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
    float h = self.view.bounds.size.height;
    float w = self.view.bounds.size.width;
    
    float y = 0;
    
    _searchBar.frame = CGRectMake(0, y, w-kGeomButtonWidth, kGeomHeightSearchBar);
    _buttonCancel.frame = CGRectMake(w-kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     y+kGeomCancelButtonInteriorPadding,
                                     kGeomButtonWidth-kGeomCancelButtonInteriorPadding,
                                     kGeomHeightSearchBar+-2*kGeomCancelButtonInteriorPadding);
    y += kGeomHeightSearchBar;
    
    _filterView.frame = CGRectMake(0, y, w, kGeomHeightFilters);
    y += kGeomHeightFilters;
    
    NSUInteger totalButtons=_keywordButtonsArray.count;
    if ( _numberOfMatchingKeywords) {
        _viewForKeywordButtons.frame= CGRectMake(0, y, w, kGeomHeightButton);
        if (totalButtons>5 ) {
            totalButtons= 5;
        }
        float buttonWidth= w/totalButtons;
        for (NSInteger i=0; i <totalButtons ; i++) {
            UIButton *b= _keywordButtonsArray[i];
            float x=  floorf(i*buttonWidth);
            b.frame = CGRectMake(x,0,buttonWidth,kGeomHeightButton);
        }
        y += kGeomHeightButton;
    } else {
        _viewForKeywordButtons.frame= CGRectMake(0, y, w, 1);
    }
    
    const  float kGeomHeightGoogleMessage=  14;
    float yMessage= h- kGeomHeightGoogleMessage;
    _labelMessageAboutGoogle.frame = CGRectMake(0,yMessage,w, kGeomHeightGoogleMessage);
    
    _tableRestaurants.frame = CGRectMake(0, y, w, yMessage-y);
    _tablePeople.frame = CGRectMake(0, y, w, yMessage-y);
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
            if ( _doingSearchNow) {
                cell.textLabel.text=  @"Searching...";
            } else {
                if (_searchBar.text.length ) {
                    cell.textLabel.text=  @"No restaurants found for that search term.";
                } else {
                    cell.textLabel.text= nil;
                }
            }
            cell.textLabel.textColor=  WHITE;
            cell.textLabel.font= [ UIFont  fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader];
            return cell;
        }
        
        RestaurantTVCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_RESTAURANTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        
        NSInteger row = indexPath.row;
        if  (!self.doingSearchNow) {
            cell.restaurant= _restaurantsArray[row];
        }
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
            cell.textLabel.textColor=  WHITE;
            cell.textLabel.font= [ UIFont  fontWithName:kFontLatoMedium size:kGeomFontSizeSubheader];
            return cell;
        }
        UserTVCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_PEOPLE_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
        
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
