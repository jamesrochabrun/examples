//
//  CreateUsernameVC.m O3
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
@property (nonatomic, strong) UIImageView *imageViewBackground, *imageViewIcon;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *labelMessage;
@property (nonatomic, strong) UILabel *labelUsernameTaken;
@property (nonatomic, strong) UITextField *fieldUsername;
@property (nonatomic, strong) UIButton *buttonSignUp;
@property (nonatomic, strong) NSMutableArray *arrayOfSuggestions;
@property (nonatomic, strong) UITableView *tableOfSuggestions;
@end

@implementation CreateUsernameVC
#define SUGGESTED_TABLE_REUSE_IDENTIFIER @"suggested"

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

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
    [_fieldUsername resignFirstResponder];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    _arrayOfSuggestions = [NSMutableArray new];
    
    self.view.backgroundColor = WHITE;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    
    self.scrollView = [UIScrollView  new];
    [self.view addSubview:_scrollView];
    
    self.imageViewBackground= makeImageView( self.scrollView,  @"Gradient Background.png");
    self.imageViewIcon = makeImageView(_scrollView,  @"No-Profile_Image(circled).png");
    
    self.buttonSignUp = makeButton(_scrollView, LOCAL(@"Create") ,kGeomFontSizeHeader ,
                                  YELLOW, CLEAR, self,
                                  @selector(userPressedSignUpButton:),
                                  .6);
    _buttonSignUp.layer.borderColor = YELLOW.CGColor;
    
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];

    self.fieldUsername = [UITextField new];
    _fieldUsername.delegate = self;
    _fieldUsername.backgroundColor = WHITE;
    _fieldUsername.placeholder = LOCAL(@"Desired username");
    _fieldUsername.borderStyle = UITextBorderStyleLine;
    _fieldUsername.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_fieldUsername];
    _fieldUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.labelUsernameTaken= makeLabel(_scrollView, LOCAL(@"Sorry that name is already taken"), kGeomFontSizeDetail);
    self.labelUsernameTaken.textColor = YELLOW;
    _labelUsernameTaken.hidden = YES;
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    self.labelMessage = makeLabel(_scrollView,
                                   LOCAL(@"What should we call you?\r(Create your username)"),
                                   kGeomFontSizeHeader);
    _labelMessage.textColor = WHITE;
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:LOCAL(@"Create Username")
                           subHeader:nil];
    [self setNavTitle:nto];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wentIntoBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshTable
{
    [self.tableOfSuggestions reloadData];
}

//------------------------------------------------------------------------------
// Name:    shouldChangeCharactersInRange
// Purpose: Control what characters users can enter.
//------------------------------------------------------------------------------
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string || !string.length) {
        return YES;
    }
    const char *cstring= string.UTF8String;
    if (!cstring) {
        return YES;
    }
    
    // RULE:  only accept letters and numbers.
    while (*cstring) {
        int character= *cstring++;
        if (!isdigit( character)  && !isalpha( character)) {
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
    NSString *name = nil;
    NSInteger row = indexPath.row;
    @synchronized(_arrayOfSuggestions) {
        if (row < _arrayOfSuggestions.count) {
            name = _arrayOfSuggestions[row];
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
    
    NSString *requestString=[NSString stringWithFormat: @"%@://%@/users/%lu", kHTTPProtocol,
                   [OOAPI URL], (unsigned long)userid];
    
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
                                                         
                                                         [weakSelf performSelectorOnMainThread:@selector(goToExplore) withObject:nil waitUntilDone:NO];
                                                         return;
                                                     }
                                                 }
                                             }
                                             
                                             // XX:  might want to check reachability here.
                                             
                                             // NOTE:  If we reach this point something went wrong.
                                             [weakSelf performSelectorOnMainThread:@selector(indicateAlreadyTaken) withObject:nil waitUntilDone:NO];

                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSInteger statusCode= operation.response.statusCode;
                                             NSLog (@"PUT OF USERNAME FAILED %@ w/%ld",error,(long)statusCode);
                                             if (statusCode==403)
                                                 [weakSelf performSelectorOnMainThread:@selector(indicateAlreadyTaken) withObject:nil waitUntilDone:NO];
                                             else {
                                                 complainAboutInternetConnection();
                                             }

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
// Name:    goToExplore
// Purpose: Perform segue to explore screen.
//------------------------------------------------------------------------------
- (void) goToExplore
{
    [_fieldUsername  resignFirstResponder];
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    [APP.diagnosticLogString appendFormat: @"Username set to %@" ,userInfo.username];

    @try {
        [self performSegueWithIdentifier:@"gotoExploreFromCreateUsername" sender:self];
    }
    @catch (NSException *exception) {
        [self.navigationController  popViewControllerAnimated:YES ];
    }
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
    
    self.imageViewBackground.frame=  self.view.bounds;

    [self.labelMessage sizeToFit ];
    float heightForText= _labelMessage.bounds.size.height;
    
    float spacer=kGeomSpaceInter;
    if (IS_IPAD) {
        spacer=40;
    }
    
    float imageSize= kGeomCreateUsernameCentralIconSize;

    float totalHeightNeeded= heightForText+imageSize +3*kGeomHeightButton;
    totalHeightNeeded += 3*spacer;
    if (!IS_IPHONE4)
        totalHeightNeeded +=kGeomHeightButton;
    
    float y= (h-totalHeightNeeded)/2;

    _imageViewIcon.frame = CGRectMake((w-imageSize)/2,y,imageSize,imageSize);
    y += imageSize+ spacer;
    
    _labelMessage.frame=CGRectMake(0, y, w, heightForText);
    y+= heightForText+ spacer;
   
    _fieldUsername.frame= CGRectMake((w-kGeomEmptyTextFieldWidth)/2, y, kGeomEmptyTextFieldWidth, kGeomHeightButton);
    y += kGeomHeightButton + spacer;
    
    _labelUsernameTaken.frame=CGRectMake (0,y,w,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    if (!IS_IPHONE4) {
        y +=kGeomHeightButton; // NOTE: There is no room for the extra gap on the iPhone 4.
    }
    
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
