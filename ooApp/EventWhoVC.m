//
//  EventWhoVC.m E6, E6A, E6B
//  ooApp
//
//  Created by Zack Smith on 10/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "GroupObject.h"
#import "EventWhoVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "GroupObject.h"
#import "OOUserView.h"
#import "ProfileVC.h"

@interface  EventWhoTableCell ()
@property (nonatomic, strong) UIButton *radioButton;
@property (nonatomic, strong) UILabel *labelName;
@property (nonatomic, strong) UILabel *labelUserName;
@property (nonatomic, strong) OOUserView *userView;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UserObject* user;
@property (nonatomic, strong) GroupObject* group;
@property (nonatomic, strong) NSString *imageIdentifierString;
@property (nonatomic, strong) NSString *imageURLForFacebook;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, assign) BOOL isEmpty;
@end

@implementation EventWhoTableCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        self.backgroundColor= UIColorRGBA(kColorOffBlack);

        _radioButton= makeButton(self, kFontIconEmptyCircle, kGeomIconSize, UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear), self, @selector(userPressRadioButton:), 0);
        [_radioButton setTitle:kFontIconCheckmarkCircle forState:UIControlStateSelected];
        _radioButton.titleLabel.font= [UIFont fontWithName:kFontIcons size: kGeomFontSizeHeader];
        
        _userView=[[OOUserView alloc] init];
        [ self  addSubview: _userView];
        _userView.userInteractionEnabled= NO;
        
        self.selectionStyle= UITableViewCellSelectionStyleNone;
        
        _labelName= makeLabelLeft(self, nil, kGeomFontSizeHeader);
        _labelName.textColor= UIColorRGBA(kColorWhite);
        
        _labelUserName= makeLabelLeft(self, nil, kGeomFontSizeHeader);
        _labelUserName.textColor= UIColorRGBA(kColorWhite);
        [_labelUserName withFont:[UIFont fontWithName:kFontLatoBold size:kGeomFontSizeHeader] textColor:kColorWhite backgroundColor:kColorClear];

        self.textLabel.hidden= YES;
        self.imageView.hidden= YES;
    }
    return self;
}

- (void) setEmptyMode;
{
    self.isEmpty= YES;
    _labelName.text= @"There are no confirmed participants.";
    _labelName.textAlignment= NSTextAlignmentCenter;
    [ self  setNeedsLayout];
}

- (void)prepareForReuse
{
    [_operation cancel];
    self.operation= nil;
    self.isEmpty= NO;
    _labelName.text= nil;
    _labelName.textAlignment= NSTextAlignmentLeft;
    _labelUserName.text= nil;
    _userView.user=  nil;
    _radioButton.selected= NO;
    self.group= nil;
    self.user= nil;
    self.imageIdentifierString= nil;
    _userView.hidden= NO;
    _labelUserName.hidden= NO;
    _radioButton.hidden= NO;
}

- (void) specifyUser:  (UserObject*)user;
{
    self.group= nil;
    self.user=  user;
    
    if  (user.firstName && [user.firstName isKindOfClass:[NSString class]]  && user.firstName.length) {
        _labelName.text= [NSString stringWithFormat: @"%@ %@",user.firstName, user.lastName];
        
        if  (user.username ) {
            _labelUserName.text= [NSString stringWithFormat: @"@%@",user.username];
        } else {
            if ( user.email) {
                _labelUserName.text= user.email;
            } else {
                _labelUserName.text= [NSString stringWithFormat: @""];
            }
        }
    } else {
        _labelName.text= user.email; // NOTE: This is for the email–only case.
        _labelUserName.text=  @"";
    }
    
    _userView.user= user;
}

- (void) specifyGroup:  (GroupObject*)group;
{
    self.user= nil;
    self.group=  group;
    
    if  (group.name ) {
        _labelName.text= group.name;
    } else {
        _labelName.text= [NSString stringWithFormat: @"Unnamed group #%ld",(long) group.groupID];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float w= self.frame.size.width;
    float h= self.frame.size.height;
    const float  margin= kGeomSpaceEdge;
    float y;
    float availableHeight=h-2*margin;
    
    if  (_isEmpty ) {
        _userView.hidden= YES;
        _labelUserName.hidden= YES;
        _radioButton.hidden= YES;
        _labelName.frame = self.bounds;
        return;
    }
    
//    NSLog (@"EMAIL  %@ first name  %@", self.user.email, self.user.firstName);
    
    _viewShadow.frame = CGRectMake( margin, margin, w- margin*2,availableHeight);
    float x=  margin;
    _userView.hidden= NO;
    float imageDimension= h-2*kGeomSpaceEdge;
    _userView.frame = CGRectMake(x, margin,imageDimension,imageDimension);
    
    x +=imageDimension+ margin;
    y= h/5;
    [_labelName sizeToFit];
    [_labelUserName sizeToFit];
    _labelUserName.frame = CGRectMake( x,y,w-kGeomSpaceEdge-kGeomWidthButton,_labelUserName.frame.size.height);
    y += _labelUserName.frame.size.height +kGeomSpaceInter;
    _labelName.frame = CGRectMake( x,y,w-kGeomSpaceEdge-kGeomWidthButton,_labelName.frame.size.height);
    
    _radioButton.frame = CGRectMake(w-kGeomWidthButton, margin,kGeomWidthButton,availableHeight);
}

- (void) setRadioButtonState: (BOOL)isSet
{
    _radioButton.selected= isSet;
}

- (void)userPressRadioButton: (id) sender
{
    if  (!_editable ) {
        return;
    }
    
    _radioButton.selected= !_radioButton.selected;
    
    if ( _viewController  ) {
        [_viewController radioButtonChanged:  _radioButton.selected
                                        for: _group ?: _user];
    }
}

@end

//==============================================================================

@interface EventWhoVC ()
@property (nonatomic,strong)UILabel* labelEventDateHeader;
@property (nonatomic,strong)UIButton* buttonAddEmailManually;
@property (nonatomic,strong)UIButton* buttonAddEmailFromContacts;
@property (nonatomic,strong)UITableView* table;
@property (nonatomic,strong) NSMutableOrderedSet *setOfPotentialParticipants;
@property (nonatomic,strong) NSMutableArray *searchResultsArray;
@property (nonatomic,strong)  NSMutableOrderedSet *participants;
@property (atomic, assign) BOOL  busy;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) ABPeoplePickerNavigationController *pickerController;
@end

@implementation EventWhoVC

UserObject* makeEmailOnlyUserObject(NSString* email)
{
    UserObject*user= [[UserObject alloc] init];
    user.email= trimString(email);
    return  user;
}

- (void) testing
{
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
    }
}

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
    
    self.setOfPotentialParticipants= [NSMutableOrderedSet new];
    self.participants= [NSMutableOrderedSet new];
    
    if ( self.editable) {
        NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"INVITE TO EVENT" subHeader: nil];
        self.navTitle = nto;
    } else {
        if ( self.eventAlreadyStarted) {
            NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"WHO WENT" subHeader: nil];
            self.navTitle = nto;
        } else {
            NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"WHO'S GOING" subHeader: nil];
            self.navTitle = nto;
        }
    }
    
    self.view.backgroundColor= UIColorRGBA(kColorOffBlack);
    
    _searchBar= [UISearchBar new];
    [ self.view addSubview:_searchBar];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _searchBar.placeholder = LOCAL( @"Type your search here");
    _searchBar.barTintColor = UIColorRGBA(kColorBlack);
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.delegate = self;
    _searchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    _searchBar.keyboardType = UIKeyboardTypeAlphabet;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    
    self.labelEventDateHeader= makeLabel( self.view,  @"WHEN IS THIS?", kGeomFontSizeHeader);
    
    if ( self.editable) {
        self.buttonAddEmailManually=makeButton(self.view, @"INVITE\rBY EMAIL",
                                               kGeomFontSizeSubheader,  UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear),
                                               self, @selector(userPressedInviteByEmail:), 1);
        _buttonAddEmailManually.titleLabel.numberOfLines=2;
        _buttonAddEmailManually.titleLabel.textAlignment=NSTextAlignmentCenter;
        
        self.buttonAddEmailFromContacts=makeButton(self.view, @"INVITE\rCONTACTS",
                                               kGeomFontSizeSubheader,  UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear),
                                               self, @selector(userPressedInviteFromContacts:), 1);
        _buttonAddEmailFromContacts.titleLabel.numberOfLines=2;
        _buttonAddEmailFromContacts.titleLabel.textAlignment=NSTextAlignmentCenter;

    }
    
    self.table= makeTable( self.view,  self);
#define PARTICIPANTS_TABLE_REUSE_IDENTIFIER  @"whomToInviteCell"
    [_table registerClass:[EventWhoTableCell class] forCellReuseIdentifier:PARTICIPANTS_TABLE_REUSE_IDENTIFIER];
    _table.backgroundColor= UIColorRGBA(kColorOffBlack);
    _table.showsVerticalScrollIndicator= NO;

    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];
}

- (void)done:(id)sender
{
    // RULE: If the server interaction is still happening then we have to wait until our data gets through.
    if  (!self.busy) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self performSelector:@selector(done:)  withObject:nil afterDelay:.33];
    }
}

- (BOOL)emailAlreadyInArray: (NSString*)emailString
{
    if  (!emailString) {
        return NO;
    }
    emailString= [ emailString lowercaseString];
    
    for (UserObject* user  in  _setOfPotentialParticipants) {
        if ( [[user.email lowercaseString] isEqualToString: emailString ]) {
            return YES;
        }
    }
    return NO;
}

- (void)reloadTable
{
    if  ( self.editable) {
        if  (_searchBar.text.length ) {
            [self updateTableForSearchText: _searchBar.text ];
        }
        
        @synchronized(_setOfPotentialParticipants) {
            [_table reloadData];
        }
    } else {
        @synchronized(_participants)  {
            [_table reloadData];
        }
    }
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
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));

    __weak EventWhoVC *weakSelf = self;
    
#if 0
    [OOAPI getGroupsWithSuccess:^(NSArray *groups) {
        //        NSLog  (@" groups for this user=  %@", groups);
        NSLog  (@"USER HAS %lu GROUPS.",groups.count);
        @synchronized(weakSelf.setOfPotentialParticipants) {
            for (id object in groups) {
                [self.setOfPotentialParticipants  addObject: object];
            }
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    }
                        failure:^(NSError *e) {
                            NSLog (@"FAILED TO FETCH LIST OF GROUPS FOR USER.");
                        }];
#endif
    
    // RULE: Find out what users are already attached to this events.
    [self.eventBeingEdited refreshUsersFromServerWithSuccess:^{
        [weakSelf.participants removeAllObjects];
        weakSelf.participants= [[ NSMutableOrderedSet alloc] initWithSet: self.eventBeingEdited.users.set];
        
        for (UserObject* user  in weakSelf.participants ) {
            [weakSelf.setOfPotentialParticipants addObject: user];
        }
        [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
        NSLog (@"EVENT HAS %lu PARTICIPANTS", (unsigned long) weakSelf.participants.count);
    } failure:^{
        NSLog (@"FAILED TO DETERMINE USERS ALREADY ATTACHED TO EVENT");
    }];
    
    if  (self.editable) {
        UserObject* user= [Settings sharedInstance].userObject;
        
        // RULE: Identify follower users we could potentially attach this event.
        [OOAPI getFollowersForUser:user.userID
                      success:^(NSArray *users) {
                          NSLog  (@"USER IS FOLLOWED BY %lu USERS.", ( unsigned long)users.count);
                          @synchronized(weakSelf.setOfPotentialParticipants) {
                              for (UserObject* user in users) {
                                  if (![weakSelf.setOfPotentialParticipants containsObject:user ]) {
                                      [weakSelf.setOfPotentialParticipants  addObject: user];
                                  }
                              }
                          }
                          [weakSelf performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                          NSLog (@"FAILED TO FETCH LIST OF USERS THAT USER IS FOLLOWING.");
                      }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)userPressedInviteFromContacts: (id) sender
{
    self.pickerController=[[ABPeoplePickerNavigationController alloc] init];
    _pickerController.peoplePickerDelegate=  self;
    [self presentViewController:_pickerController animated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABMultiValueRef emailsMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (!emailsMultiValueRef) {
        message( @"That contact does not include an email address (required).");
        return;
    }
    
    NSString *firstName= nil;
    NSString *lastName= nil;
    firstName = (__bridge_transfer  NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString *firstEmailAddress=nil;
    NSString *homeEmailAddress=nil;
    
    for (NSUInteger i = 0; i <= ABMultiValueGetCount(emailsMultiValueRef); i++) {
        NSString *emailLabel = (__bridge_transfer NSString *) ABMultiValueCopyLabelAtIndex (emailsMultiValueRef, i);
        NSString * email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailsMultiValueRef, i);
        
        if (!firstEmailAddress) {
            firstEmailAddress=  email;
        }
        
        if ([emailLabel isEqualToString:@"Home"]) {
            homeEmailAddress = email;
        }
    }
    
    if  (!homeEmailAddress) {
        homeEmailAddress=firstEmailAddress;
    }
    
    if (!homeEmailAddress) {
        message( @"That contact does not have an email address.");
    } else {
        [self processIncomingEmailAddress: homeEmailAddress firstName:firstName lastName:lastName];
    }
    
    CFRelease(emailsMultiValueRef);
}

- (void)processIncomingEmailAddress: (NSString*)string
                          firstName:(NSString*)firstName
                           lastName:(NSString*)lastName
{
    if (!isValidEmailAddress(string)) {
        message( @"Not a valid email address.");
        return;
    }
    
    if  ([self emailAlreadyInArray: string] ) {
        RUN_AFTER(250,^{
            message(LOCAL( @"That user is already in the list."));
        })
        return;
    }
    
    __weak EventWhoVC *weakSelf = self;
    [OOAPI lookupUserByEmail:string
                     success:^(UserObject *user) {
                         if  (user) {
                             [weakSelf addUserToPotentialParticipants: user];
                         } else {
                             [weakSelf createAndAddPlaceholderUser: string  firstName:firstName lastName:lastName];
                         }
                         
                     } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                         [weakSelf createAndAddPlaceholderUser: string  firstName:firstName lastName:lastName];
                     }];
    
}

- (void)addContactDoneButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userPressedInviteByEmail: (id) sender
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle:LOCAL(@"EMAIL ADDRESS")
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    a.popoverPresentationController.sourceView = sender;
    a.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;

    
    [a addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        [textField becomeFirstResponder];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    
    __weak  EventWhoVC *weakSelf = self;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCAL(@"ADD")
                                                 style: UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   UITextField *textField = a.textFields.firstObject;
                                                   
                                                   NSString *string = trimString(textField.text);
                                                   
                                                   [weakSelf processIncomingEmailAddress:string
                                                                               firstName: @""
                                                                                lastName: @""];
                                               }];
    
    [a addAction:cancel];
    [a addAction:ok];
    
    [self presentViewController:a animated:YES completion:nil];
    

}

- (void)addUserToPotentialParticipants: (UserObject*)user
{
    @synchronized(self.setOfPotentialParticipants) {
        [self.setOfPotentialParticipants  addObject: user];
    }
    [self  reloadTable];
    [self.table scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:_setOfPotentialParticipants.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

- (void) createAndAddPlaceholderUser: (NSString*)emailAddress
                           firstName:(NSString*)firstName
                            lastName:(NSString*)lastName
{
    if ( !self.editable) {
        return;
    }
    
    if (!emailAddress || !emailAddress.length) {
        NSLog (@"MISSING EMAIL ADDRESS");
        return;
    }
    
    OONetworkManager *rm = [[OONetworkManager alloc] init];
    AFHTTPRequestOperation *op;
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/users", kHTTPProtocol, [OOAPI URL]];

    NSMutableDictionary* parametersDictionary=  [NSMutableDictionary new];
    parametersDictionary [ kKeyUserEmail]= emailAddress;
    if  (firstName ) {
        parametersDictionary [ kKeyUserFirstName]= firstName;
    }
    if  (lastName ) {
        parametersDictionary [ kKeyUserLastName]= lastName;
    }
    parametersDictionary [ @"user_type"]= @(USER_TYPE_INACTIVE);

    UserObject* userInfo= [Settings sharedInstance].userObject;
    userInfo.backendAuthorizationToken= nil;
    
    __weak  EventWhoVC *weakSelf = self;
    NSLog (@"POST %@", urlString);
    op = [rm POST:urlString
       parameters: parametersDictionary
          success:^(id responseObject) {
              NSDictionary *dict=responseObject;
              if ([dict isKindOfClass:[NSDictionary class] ]) {
                  NSDictionary *userDictionary= [dict objectForKey: @"user"];
                  UserObject*user=[UserObject userFromDict:userDictionary];
                  [weakSelf addUserToPotentialParticipants: user];
                  
                  NSLog  (@"CREATED NEW USER %@ %@ = %@",user.firstName,user.lastName, user.email);

              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error ) {
              NSLog  (@"UNABLE TO CREATE NEW USER %@",error);
              message( @"Unable to add that user.");
          }];

    return;
    
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float  spacing=  kGeomSpaceInter;
    
    float  y=  0;
    
    if ( self.editable) {
        _searchBar.hidden= NO;
        _searchBar.frame = CGRectMake(margin,y,w- margin*2, kGeomHeightSearchBar);
        y+= kGeomHeightSearchBar;
        
        float tableHeight= h-y-kGeomHeightButton-margin-spacing;
        _table.frame = CGRectMake(0,y,w,tableHeight);
        y+= tableHeight+ spacing;
        
        const float maximumButtonAreaWidth = 320;
        
        float buttonWidth= (maximumButtonAreaWidth-2*margin-spacing)/2;
        float x=  (w-maximumButtonAreaWidth)/2 + margin;
        _buttonAddEmailManually.frame = CGRectMake(x,y, buttonWidth, kGeomHeightButton);
        x +=buttonWidth+ spacing;
        _buttonAddEmailFromContacts.frame = CGRectMake(x,y, buttonWidth, kGeomHeightButton);
        x +=buttonWidth+ spacing;
    } else {
         _searchBar.hidden= YES;
        _table.frame = CGRectMake(0,0,w,h);
        _buttonAddEmailManually.frame= CGRectZero;
        _buttonAddEmailFromContacts.frame= CGRectZero;
    }
}

//------------------------------------------------------------------------------
// Name:    textDidChange
// Purpose:
//------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString* text = _searchBar.text;
    [self updateTableForSearchText: text];
}

//------------------------------------------------------------------------------
// Name:    searchBarSearchButtonClicked
// Purpose:
//------------------------------------------------------------------------------
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
}

- (void)updateTableForSearchText:  (NSString*)text
{
    if  (!self.editable ) {
        return;
    }
    if  (!text.length) {
        self.searchResultsArray= nil;
    }
    else {
        self.searchResultsArray= [NSMutableArray new];
        @synchronized(_setOfPotentialParticipants) {
            for (UserObject* user  in  _setOfPotentialParticipants) {
                NSString*name=  [NSString  stringWithFormat: @"%@ %@", user.firstName, user.lastName ];
                if  ([ name containsString: text] ) {
                    [_searchResultsArray addObject: user];
                }
            }
        }
    }
    [self.table reloadData ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventWhoTableCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:PARTICIPANTS_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    UserObject* object= nil;
    NSInteger row= indexPath.row;
    
    if  (self.editable ) {
        @synchronized(_setOfPotentialParticipants) {
            if  (_searchResultsArray ) {
                if  (row  < _searchResultsArray.count) {
                    object=  _searchResultsArray[row];
                }
            } else {
                if  (row  < _setOfPotentialParticipants.count) {
                    object=  _setOfPotentialParticipants[row];
                }
            }
        }
    } else {
        @synchronized(_participants) {
            if  (row  < _participants.count) {
                object=  _participants[row];
            }
        }
    }
    
    cell.viewController=  self;
    cell.editable=self.editable;
    
    if  (object ) {
        BOOL inList= NO;
        for (UserObject* user  in  _participants) {
            if (object.userID>0 &&  user.userID == object.userID) {
                inList= YES;
                break;
            }
            if ( [user.email isEqualToString:object.email ]) {
                inList= YES;
                break;
            }
        }
        [ cell setRadioButtonState: inList];
        
        if  ([object isKindOfClass:[GroupObject class]] ) {
            
        } else {
            [cell specifyUser: object];
        }
        
    } else {
        [cell setEmptyMode];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightEventWhoTableCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserObject* user= nil;
    NSInteger row= indexPath.row;
    
    if ( self.editable) {
        @synchronized(_setOfPotentialParticipants) {
            if  ( row  < _setOfPotentialParticipants.count) {
                user=  _setOfPotentialParticipants[row];
            }
        }
    } else {
        
        @synchronized(_participants) {
            if  ( row  < _participants.count) {
                user=  _participants[row];
            }
        }
    }
    
    if ( user) {
        ProfileVC* vc= [[ProfileVC alloc] init];
        vc.userID= user.userID;
        vc.userInfo=user;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  total;
    
    if ( self.editable) {
        @synchronized(_setOfPotentialParticipants) {
            if  (_searchResultsArray ) {
                total= _searchResultsArray.count;
            } else {
                total= _setOfPotentialParticipants.count;
            }
        }
    } else {
        
        @synchronized(_participants) {
            total= _participants.count;
        }
    }
    return  MAX(1,total);
}

- (void) radioButtonChanged: (BOOL)value for: (id)object;
{
    if (!object) {
        return;
    }
    if  (!self.editable) {
        return;
    }
    
    if ( value) {
        [_participants  addObject: object];
    }else {
        [_participants  removeObject: object];
    }
    
    [self.delegate userDidAlterEventParticipants];
    
    self.busy=YES;
    __weak EventWhoVC *weakSelf = self;
    [OOAPI setParticipationOf:object
                      inEvent:self.eventBeingEdited
                           to:value
                      success:^(NSInteger eventID) {
                          NSLog  (@"SUCCESS");
                          weakSelf.busy= NO;
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *e) {
                          weakSelf.busy= NO;
                          NSLog  (@"FAILURE  %@",e);
                          if ( value) {
                              [_participants  removeObject: object];
                              // XX:  need to update radio button is well
                          }
                      }];
    
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

@end
