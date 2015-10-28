//
//  CreateUsernameVC.m
//  ooApp
//
//  Created by Zack Smith on 9/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "CreateUsernameVC.h"
#import "UserObject.h"
#import "Settings.h"
#import "Common.h"
#import "ListStripTVCell.h"
#import "OOAPI.h"
#import "AppDelegate.h"

@interface CreateUsernameVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic,strong) UILabel* labelUsernameTaken;
@property (nonatomic,strong) UITextField* fieldUsername;
@property (nonatomic,strong) UIButton* buttonSignUp;
@property (nonatomic,strong) NSMutableArray* arrayOfSuggestions;
@property (nonatomic,strong) UITableView* tableOfSuggestions;
@end

@implementation CreateUsernameVC
#define SUGGESTED_TABLE_REUSE_IDENTIFIER @"suggested"

- (void)dealloc
{
    self.arrayOfSuggestions= nil;
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
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _arrayOfSuggestions=[NSMutableArray new];

    self.view.backgroundColor= WHITE;
    
    self.scrollView= [UIScrollView  new];
    [self.view  addSubview: _scrollView ];
    
    self.buttonSignUp= makeButton( _scrollView, LOCAL(@"SIGN UP") , kGeomFontSizeHeader,
                                 BLACK, CLEAR, self,
                                 @selector(userPressedSignUpButton:),
                                 1);
    
    self.tableOfSuggestions=[UITableView new];
    _tableOfSuggestions.delegate=self;
    _tableOfSuggestions.dataSource=self;
    [_tableOfSuggestions registerClass:[UITableViewCell class] forCellReuseIdentifier:SUGGESTED_TABLE_REUSE_IDENTIFIER];
    [self.view addSubview:_tableOfSuggestions];
    
    self.fieldUsername= [ UITextField  new];
    _fieldUsername.delegate= self;
    _fieldUsername.backgroundColor= WHITE;
    _fieldUsername.placeholder=  LOCAL(@"Desired username");
    _fieldUsername.borderStyle= UITextBorderStyleLine;
    _fieldUsername.textAlignment= NSTextAlignmentCenter;
    [_scrollView addSubview: _fieldUsername];
    _fieldUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.labelUsernameTaken= makeLabel(_scrollView,LOCAL(@"status: username is taken"), kGeomFontSizeDetail);
    self.labelUsernameTaken.textColor= RED;
    UIFont* upperFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeHeader];
    _labelUsernameTaken.hidden= YES;
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    NSAttributedString *aString= [[NSAttributedString  alloc]
                                  initWithString:
                                    LOCAL(@"We should put some introductory text here.\r")
                                  attributes: @{
                                                NSFontAttributeName: upperFont,
                                                NSParagraphStyleAttributeName:paragraphStyle
                                                }];
    
    self.textView=  makeTextView(_scrollView, CLEAR, NO);
    _textView.textColor= BLACK;
    _textView.attributedText= aString;
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader: LOCAL(@"Create User Name")
                           subHeader:nil];
    [self setNavTitle:  nto];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wentIntoBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSString* emailAddressString= userInfo.email;
    __weak CreateUsernameVC *weakSelf= self;
    
    [OOAPI fetchSampleUsernamesFor:emailAddressString
                           success:^(NSArray *names) {
                               NSLog  (@"SERVER PROVIDED SAMPLE USERNAMES:  %@",names);
                               [weakSelf.arrayOfSuggestions removeAllObjects];
                               for (NSString* string  in  names) {
                                   [weakSelf.arrayOfSuggestions addObject: string];
                               }
                               [weakSelf performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:NO ];
                           } failure:^(AFHTTPRequestOperation* operation, NSError *e) {
                               NSLog  (@"FAILED TO GET SAMPLE USERNAMES FROM SERVER  %@",e);
                           }];
}

- (void)refreshTable
{
    [self.tableOfSuggestions reloadData];
}

//------------------------------------------------------------------------------
// Name:    shouldChangeCharactersInRange
// Purpose: Control what characters users can enter.
//------------------------------------------------------------------------------
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string || !string.length) {
        return YES;
    }
    const char *cstring= string.UTF8String;
    if  (!cstring) {
        return YES;
    }
    
    // RULE:  only accept letters and numbers.
    while (*cstring) {
        int  character= *cstring++;
        if  (!isdigit( character)  && !isalpha( character)) {
            return NO;
        }
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:SUGGESTED_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell=  [[UITableViewCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SUGGESTED_TABLE_REUSE_IDENTIFIER ];
    }
    NSString* name= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfSuggestions) {
        if  (row  < _arrayOfSuggestions.count) {
            name=  _arrayOfSuggestions[row];
        }
    }
    cell.textLabel.text= name;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return LOCAL(@"Sample usernames");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kGeomHeightSampleUsernameRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name= nil;
    NSInteger row= indexPath.row;
    @synchronized(_arrayOfSuggestions) {
        if  ( row  < _arrayOfSuggestions.count) {
            name=  _arrayOfSuggestions[row];
        }
    }
    if ( name) {
        _fieldUsername.text= name;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    @synchronized(_arrayOfSuggestions) {
        NSInteger  total=  _arrayOfSuggestions.count;
        return  total;
    }
}

//------------------------------------------------------------------------------
// Name:    textFieldShouldReturn
// Purpose: Control what characters users can enter.
//------------------------------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSString* enteredUsername= textField.text;
    if (!enteredUsername.length) {
        message( LOCAL(@"You did not enter a username."));
        return NO;
    }
    [textField resignFirstResponder];
    [self checkWhetherUserNameIsInUse : enteredUsername];
    return YES;
}

//------------------------------------------------------------------------------
// Name:    checkWhetherUserNameIsInUse
// Purpose: Submit the username to the backend for approval or not.
//------------------------------------------------------------------------------
- (void)checkWhetherUserNameIsInUse:(NSString*)enteredUsername
{
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSUInteger userid= userInfo.userID;
    
    NSString *requestString=[NSString stringWithFormat: @"https://%@/users/%lu",
                   kOOURL, userid];
    
    requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];

    NSDictionary* parametersDictionary=  @{
                                            @"username": enteredUsername
                                           };
    
    __weak  CreateUsernameVC *weakSelf = self;
    [[OONetworkManager sharedRequestManager] PUT: requestString
                                      parameters: parametersDictionary
                                         success:^void(id   result) {
                                             NSLog  (@"PUT OF USERNAME SUCCEEDED.");
                                             
                                             if ([result isKindOfClass: [NSDictionary  class] ] ) {
                                                 NSDictionary *subdictionary= ((NSDictionary*)result) [ @"user"];
                                                 if  (subdictionary ) {
                                                     NSString* usernameForConfirmation= subdictionary[ @"username"];
                                                     if  (usernameForConfirmation && [usernameForConfirmation isEqualToString:enteredUsername] ) {
                                                         NSLog (@"SAVE OF USERNAME TO BACKEND CONFIRMED.");
                                                         
                                                         [weakSelf performSelectorOnMainThread:@selector(indicateNotTaken) withObject:nil waitUntilDone:YES];
                                                         
                                                         UserObject* userInfo= [Settings sharedInstance].userObject;
                                                         userInfo.username= enteredUsername;
                                                         [[Settings sharedInstance ]save ];
                                                         
                                                         [weakSelf performSelectorOnMainThread:@selector(goToDiscover) withObject:nil waitUntilDone:NO];
                                                         return;
                                                     }
                                                 }
                                             }
                                             
                                             // XX:  might want to check reachability here.
                                             
                                             // NOTE:  If we reach this point something went wrong.
                                             [weakSelf performSelectorOnMainThread:@selector(indicateAlreadyTaken) withObject:nil waitUntilDone:NO];

                                         }
                                         failure:^(AFHTTPRequestOperation* operation, NSError *error) {
                                             NSLog (@"PUT OF USERNAME FAILED %@",error);
                                             [weakSelf performSelectorOnMainThread:@selector(indicateAlreadyTaken) withObject:nil waitUntilDone:NO];

                                         }     ];
}

- (void)indicateAlreadyTaken
{
    _labelUsernameTaken.hidden= NO;
}

- (void)indicateNotTaken
{
    _labelUsernameTaken.hidden= YES;
}

//------------------------------------------------------------------------------
// Name:    goToLoginScreen
// Purpose: Perform segue to login screen.
//------------------------------------------------------------------------------
- (void) goToLoginScreen
{
    [self performSegueWithIdentifier:@"returnToLogin" sender:self];
}

- (void)wentIntoBackground:(NSNotification*) not
{
    [self goToLoginScreen];
}

//------------------------------------------------------------------------------
// Name:    goToDiscover
// Purpose: Perform segue to discover screen.
//------------------------------------------------------------------------------
- (void) goToDiscover
{
    [_fieldUsername  resignFirstResponder];
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    [APP.diagnosticLogString appendFormat: @"Username set to %@" ,userInfo.username];

    [self performSegueWithIdentifier:@"gotoDiscoverFromCreateUsername" sender:self];
}

//------------------------------------------------------------------------------
// Name:    keyboardHidden
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardHidden:(NSNotification*) not
{
    _scrollView.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
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
    _scrollView.contentInset= UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    [_scrollView scrollRectToVisible:_fieldUsername.frame animated:YES];
}

//------------------------------------------------------------------------------
// Name:    userPressedSignUpButton
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedSignUpButton: (id) sender
{
    [_fieldUsername resignFirstResponder];
    
    NSString* enteredUsername= _fieldUsername.text;
    if (!enteredUsername.length) {
        message( @"No username was entered.");
        return;
    }
    [self checkWhetherUserNameIsInUse : enteredUsername];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
-(void) doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    
    _scrollView.frame=  self.view.bounds;
    _scrollView.scrollEnabled=  YES;
    
    [self.textView sizeToFit ];
    float heightForText= _textView.bounds.size.height;
    
    const float spacer=kGeomSpaceInter;
    
    float totalHeightNeeded= heightForText+kGeomForkImageSize +3*kGeomHeightButton;
    totalHeightNeeded += 3*spacer;
    
    float y= (h-totalHeightNeeded)/2;

    _textView.frame=CGRectMake((w-kGeomEmptyTextViewWidth)/2, y, kGeomEmptyTextViewWidth, heightForText);
    y+= heightForText+ spacer;
   
    _fieldUsername.frame= CGRectMake((w-kGeomEmptyTextFieldWidth)/2, y, kGeomEmptyTextFieldWidth, kGeomHeightButton);
    y += kGeomHeightButton + spacer;
    
    _tableOfSuggestions.frame= CGRectMake( (w-kGeomSampleUsernameTableWidth )/2,y,kGeomSampleUsernameTableWidth,kGeomSampleUsernameTableHeight);
    y += spacer + kGeomSampleUsernameTableHeight;
    
    _labelUsernameTaken.frame=CGRectMake (0,y,w,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _buttonSignUp.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _scrollView.contentSize= CGSizeMake(w-1, y);
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void) viewWillLayoutSubviews
{
    [ super viewWillLayoutSubviews ];
  
    [self doLayout];
}

@end
