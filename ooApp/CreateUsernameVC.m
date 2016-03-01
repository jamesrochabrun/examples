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
@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *welcomeMessageLabel;
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
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    
    self.scrollView = [UIScrollView  new];
    [self.view addSubview:_scrollView];
    
    _imageViewIcon = [[UIImageView alloc] init];
    _imageViewIcon.contentMode = UIViewContentModeScaleAspectFill;
    _imageViewIcon.clipsToBounds = YES;
    [_scrollView addSubview:_imageViewIcon];
    
    UserObject *uo = [Settings sharedInstance].userObject;
    MediaItemObject *mio = uo.mediaItem;
    NSURL *url = (mio && mio.url) ? [NSURL URLWithString:mio.url] : nil;
    if (url) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [_imageViewIcon setImage:image];
//            if (image) {
//                [uo setUserProfilePhoto:image andUpload:YES];
//                NSLog (@"IMAGE OBTAINED FROM FACEBOOK HAS DIMENSIONS %@", NSStringFromCGSize(image.size));
//            }
        }
    } else {
        self.imageViewIcon = makeImageView(_scrollView,  @"No-Profile_Image(circled).png");
    }
    
    _welcomeMessageLabel = [UILabel new];
    [_welcomeMessageLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeBig] textColor:kColorWhite backgroundColor:kColorClear numberOfLines:2 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:_welcomeMessageLabel];
    
    if (uo.firstName && [uo.firstName length]) {
        _welcomeMessageLabel.text = [NSString stringWithFormat:@"Hi %@!\nWelcome to Oomami", uo.firstName];
    } else {
        _welcomeMessageLabel.text = [NSString stringWithFormat:@"Welcome to Oomami"];
    }
    
    self.buttonSignUp = makeButton(_scrollView, LOCAL(@"Create") ,kGeomFontSizeHeader ,
                                  UIColorRGB(kColorYellow), UIColorRGBA(kColorClear), self,
                                  @selector(userPressedSignUpButton:),
                                  .6);
    _buttonSignUp.layer.borderColor = UIColorRGB(kColorYellow).CGColor;
    
    [self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];

    self.fieldUsername = [UITextField new];
    _fieldUsername.delegate = self;
    _fieldUsername.backgroundColor = UIColorRGBA(kColorBlack);
//    _fieldUsername.placeholder = LOCAL(@"Enter username");
    _fieldUsername.borderStyle = UITextBorderStyleLine;
    _fieldUsername.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_fieldUsername];
    _fieldUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:LOCAL(@"Enter Username") attributes:@{ NSForegroundColorAttributeName : UIColorRGBA(kColorGrayMiddle)}];
    _fieldUsername.attributedPlaceholder = str;
    _fieldUsername.layer.cornerRadius = kGeomCornerRadius;
    _fieldUsername.textColor= UIColorRGBA(kColorWhite);
    
    
    self.labelUsernameTaken= makeLabel(_scrollView, LOCAL(@"Sorry that name is already taken"), kGeomFontSizeDetail);
    self.labelUsernameTaken.textColor = UIColorRGB(kColorYellow);
    _labelUsernameTaken.hidden = YES;
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    self.labelMessage = makeLabel(_scrollView,
                                   LOCAL(@"What should we call you?"),
                                   kGeomFontSizeHeader);
    _labelMessage.textColor = UIColorRGBA(kColorWhite);
    
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *enteredUsername = textField.text;
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
    UserObject *userInfo = [Settings sharedInstance].userObject;
    NSUInteger userid = userInfo.userID;
    
    NSString *requestString = [NSString stringWithFormat:@"%@://%@/users/%lu", kHTTPProtocol,
                   [OOAPI URL], (unsigned long)userid];
    
    requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];

    NSDictionary* parametersDictionary=  @{
                                            @"username": enteredUsername
                                           };
    
    __weak  CreateUsernameVC *weakSelf = self;
    [[OONetworkManager sharedRequestManager] PUT:requestString
                                      parameters:parametersDictionary
                                         success:^void(id result) {
                                             NSLog(@"PUT OF USERNAME SUCCEEDED.");
                                             
                                             if ([result isKindOfClass:[NSDictionary class]]) {
                                                 NSDictionary *subdictionary= ((NSDictionary *)result) [@"user"];
                                                 if (subdictionary) {
                                                     NSString* usernameForConfirmation= subdictionary[@"username"];
                                                     if (usernameForConfirmation && [usernameForConfirmation isEqualToString:enteredUsername] ) {
                                                         NSLog (@"SAVE OF USERNAME TO BACKEND CONFIRMED.");
                                                         
                                                         [weakSelf performSelectorOnMainThread:@selector(indicateNotTaken) withObject:nil waitUntilDone:YES];
                                                         
                                                         UserObject *userInfo = [Settings sharedInstance].userObject;
                                                         userInfo.username = enteredUsername;
                                                         [[Settings sharedInstance] save];
                                                         
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
                                             NSLog (@"PUT OF USERNAME FAILED %@ w/%ld", error, (long)statusCode);
                                             if (statusCode == 403)
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
- (void)goToLoginScreen
{
    [self performSegueWithIdentifier:@"returnToLogin" sender:self];
}

- (void)wentIntoBackground:(NSNotification *)not
{
    [self goToLoginScreen];
}

//------------------------------------------------------------------------------
// Name:    goToExplore
// Purpose: Perform segue to explore screen.
//------------------------------------------------------------------------------
- (void)goToExplore
{
    [_fieldUsername resignFirstResponder];
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    [APP.diagnosticLogString appendFormat:@"Username set to %@", userInfo.username];

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
- (void)keyboardHidden:(NSNotification*)not
{
    _scrollView.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
}

//------------------------------------------------------------------------------
// Name:    keyboardShown
// Purpose:
//------------------------------------------------------------------------------
- (void)keyboardShown:(NSNotification *)not
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
- (void)userPressedSignUpButton:(id)sender
{
    [_fieldUsername resignFirstResponder];
    
    NSString* enteredUsername = _fieldUsername.text;
    if (!enteredUsername.length) {
        message(@"No username was entered.");
        return;
    }
    [self checkWhetherUserNameIsInUse:enteredUsername];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    CGRect frame;
    
    _scrollView.frame = self.view.bounds;
    _scrollView.scrollEnabled = YES;

    [self.labelMessage sizeToFit];
    CGFloat heightForText = _labelMessage.bounds.size.height;
    
    CGFloat spacer = kGeomSpaceInter;
    if (IS_IPAD) {
        spacer = 40;
    }
    
    CGFloat imageSize = kGeomCreateUsernameCentralIconSize;

    CGFloat totalHeightNeeded= heightForText+imageSize +3*kGeomHeightButton;
    totalHeightNeeded += 3*spacer;
    if (!IS_IPHONE4)
        totalHeightNeeded +=kGeomHeightButton;
    
    CGFloat y = h/5;// (h-totalHeightNeeded)/2;

    _imageViewIcon.frame = CGRectMake((w-imageSize)/2,y,imageSize,imageSize);
    y += imageSize+ spacer;
    _imageViewIcon.layer.cornerRadius = _imageViewIcon.frame.size.width/2;
    
    frame = _welcomeMessageLabel.frame;
    frame.size = [_welcomeMessageLabel sizeThatFits:CGSizeMake(width(self.view), 200)];
    frame.origin.x = (width(self.view)-width(_welcomeMessageLabel))/2;
    frame.origin.y = (CGRectGetMinY(_imageViewIcon.frame) - height(_welcomeMessageLabel))/2;
    _welcomeMessageLabel.frame = frame;

    
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
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

@end
