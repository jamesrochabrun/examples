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
#import "OOErrorObject.h"
#import "UIImageEffects.h"
#import "DebugUtilities.h"

@interface CreateUsernameVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *welcomeMessageLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *usernameResultMessage;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UILabel *aboutLabel;
@property (nonatomic, strong) UITextView *about;
@property (nonatomic, strong) UILabel *aboutResultMessage;
@property (nonatomic, strong) UIButton *buttonSignUp;
@property (nonatomic, strong) NSMutableArray *arrayOfSuggestions;
@property (nonatomic, strong) UITableView *tableOfSuggestions;
@property (nonatomic, strong) UIView *overlay;
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
    [_username resignFirstResponder];

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
    
    self.scrollView = [UIScrollView new];
    [self.view addSubview:_scrollView];

    UIImage *backgroundImage = [UIImageEffects imageByApplyingBlurToImage:[UIImage imageNamed:@"background_image.png"] withRadius:30 tintColor: UIColorRGBOverlay(kColorBlack, 0) saturationDeltaFactor:1 maskImage:nil];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    
    _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.opaque = NO;
    [_scrollView addSubview:_backgroundImageView];
    
    _overlay = [[UIView alloc] init];
    _overlay.backgroundColor = UIColorRGBOverlay(kColorBlack, 0.25);
    [_scrollView addSubview:_overlay];
    
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    
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
        }
    } else {
        self.imageViewIcon = makeImageView(_scrollView,  @"No-Profile_Image(circled).png");
    }
    
    _welcomeMessageLabel = [UILabel new];
    [_welcomeMessageLabel withFont:[UIFont fontWithName:kFontLatoMedium size:kGeomFontSizeBig] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:1 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:_welcomeMessageLabel];
    
    if (uo.firstName && [uo.firstName length]) {
        _welcomeMessageLabel.text = [NSString stringWithFormat:@"Hi %@!", uo.firstName];
    } else {
        _welcomeMessageLabel.text = [NSString stringWithFormat:@"Hi!"];
    }
    
    _buttonSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [_scrollView addSubview:_buttonSignUp];
    [_buttonSignUp withText:@"Let's go, I'm hungry!" fontSize:kGeomFontSizeH2 width:kGeomWidthButton height:kGeomHeightButton backgroundColor:kColorTextActive textColor:kColorTextReverse borderColor:kColorClear target:self selector:@selector(userPressedSignUpButton:)];
    
    //[self setLeftNavWithIcon:kFontIconBack target:self action:@selector(done:)];

    _username = [UITextField new];
    _username.delegate = self;
    _username.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.textAlignment = NSTextAlignmentLeft;
    _username.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kGeomSpaceEdge, 5)];
    _username.leftViewMode = UITextFieldViewModeAlways;
    [_scrollView addSubview:_username];
    _username.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSAttributedString *usernameStr = [[NSAttributedString alloc] initWithString:LOCAL(@"Enter Username (required)") attributes:@{NSForegroundColorAttributeName : UIColorRGBA(kColorGrayMiddle)}];
    _username.attributedPlaceholder = usernameStr;
    _username.textColor = UIColorRGBA(kColorText);
    
    _usernameResultMessage = [UILabel new];
    [_usernameResultMessage withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH4] textColor:kColorTextReverse backgroundColor:kColorClear];
    [_scrollView addSubview:_usernameResultMessage];
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    _usernameLabel = [[UILabel alloc] init];
    [_usernameLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorTextReverse backgroundColor:kColorClear];
    _usernameLabel.text = @"What should we call you?";
    [_scrollView addSubview:_usernameLabel];

    _aboutLabel = [[UILabel alloc] init];
    [_aboutLabel withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2] textColor:kColorTextReverse backgroundColor:kColorClear];
    _aboutLabel.text = @"Tell us about yourself. Favorite dish? cuisine?";
    [_scrollView addSubview:_aboutLabel];
    
    _about = [UITextView new];
    _about.delegate = self;
    _about.backgroundColor = UIColorRGBA(kColorBackgroundTheme);
    _about.autocorrectionType = UITextAutocorrectionTypeNo;
    _about.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _about.textAlignment = NSTextAlignmentLeft;
    _about.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    [_scrollView addSubview:_about];
    _about.textColor = UIColorRGBA(kColorText);
    _about.text = uo.about;
    
//    NavTitleObject *nto = [[NavTitleObject alloc]
//                           initWithHeader:LOCAL(@"Create Username")
//                           subHeader:nil];
//    [self setNavTitle:nto];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wentIntoBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    //[DebugUtilities addBorderToViews:@[_welcomeMessageLabel, _about, _username, _imageViewIcon, _usernameLabel]];
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
    if (textField == _username) {
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
    } else {
        return YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:SUGGESTED_TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell=  [[UITableViewCell  alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:SUGGESTED_TABLE_REUSE_IDENTIFIER];
    }
    NSString *name = nil;
    NSInteger row = indexPath.row;
    @synchronized(_arrayOfSuggestions) {
        if (row < _arrayOfSuggestions.count) {
            name = _arrayOfSuggestions[row];
        }
    }
    cell.textLabel.text = name;
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
        _username.text= name;
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
        _usernameResultMessage.text = LOCAL(@"You did not enter a username.");
        [self.view setNeedsLayout];
        //message( LOCAL(@"You did not enter a username."));
        return NO;
    }
    [_about becomeFirstResponder];
    //[self updateUsername:enteredUsername];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString: @"\n" ] ) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)updateUsername:(NSString*)username
{
    UserObject *userUpdates = [[UserObject alloc] init];
    userUpdates.username = username;
    userUpdates.about = trimString(_about.text);
    
    __weak CreateUsernameVC *weakSelf = self;
    
    [OOAPI updateUser:userUpdates success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [Settings sharedInstance].userObject.username = username;
            [Settings sharedInstance].userObject.about = trimString(_about.text);
            [[Settings sharedInstance] save];
            _usernameResultMessage.text = @"";
            [self.view setNeedsLayout];
            [weakSelf goToExplore];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            OOErrorObject *ooError = [OOErrorObject errorFromDict:[operation.responseObject objectForKey:kKeyError]];
            if (ooError.type == kOOErrorCodeTypeInvalidUsername) {
                _usernameResultMessage.text = @"Enter 4 to 30 characters.";
            } else if (ooError.type == kOOErrorCodeTypeUniqueConstraint) {
                _usernameResultMessage.text = @"That username is already taken.";
            } else {
                _usernameResultMessage.text = @"Could not update the username. Try another one.";
            }

            [weakSelf.view setNeedsLayout];
        });
    }];
}

- (void)goToWelcomeScreen
{
    [self performSegueWithIdentifier:@"returnToWelcome" sender:self];
}

- (void)wentIntoBackground:(NSNotification *)not
{
    [self goToWelcomeScreen];
}

//------------------------------------------------------------------------------
// Name:    goToExplore
// Purpose: Perform segue to explore screen.
//------------------------------------------------------------------------------
- (void)goToExplore
{
    [_username resignFirstResponder];
    
    UserObject *userInfo= [Settings sharedInstance].userObject;
    [APP.diagnosticLogString appendFormat:@"Username set to %@", userInfo.username];

    @try {
        [self performSegueWithIdentifier:@"mainUISegue" sender:self];
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
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    [_scrollView scrollRectToVisible:_buttonSignUp.frame animated:YES];
}

//------------------------------------------------------------------------------
// Name:    userPressedSignUpButton
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedSignUpButton:(id)sender
{
    [_username resignFirstResponder];
    
    NSString* enteredUsername = _username.text;
    if (!enteredUsername.length) {
        message(@"No username was entered.");
        return;
    }
    [self updateUsername:enteredUsername];
}

//------------------------------------------------------------------------------
// Name:    viewWillLayoutSubviews
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    CGFloat buttonWidth = (IS_IPAD) ? kGeomWidthButtoniPadMax : w - 4*kGeomSpaceEdge;
    
    CGRect frame;
    
    _scrollView.frame = self.view.bounds;
    _scrollView.scrollEnabled = YES;
    
    _backgroundImageView.frame = _overlay.frame = self.view.bounds;
    
    CGFloat imageSize = (IS_IPHONE4) ? 0.8*kGeomCreateUsernameCentralIconSize:kGeomCreateUsernameCentralIconSize;
    
    frame = _welcomeMessageLabel.frame;
    frame.size = [_welcomeMessageLabel sizeThatFits:CGSizeMake(w, 200)];
    frame.origin.x = (width(self.view)-width(_welcomeMessageLabel))/2;
    frame.origin.y = kGeomHeightNavBar;// (CGRectGetMinY(_imageViewIcon.frame) - height(_welcomeMessageLabel))/2;
    _welcomeMessageLabel.frame = frame;

    _imageViewIcon.frame = CGRectMake((w-imageSize)/2, CGRectGetMaxY(_welcomeMessageLabel.frame) + kGeomSpaceInter, imageSize, imageSize);
    _imageViewIcon.layer.cornerRadius = _imageViewIcon.frame.size.width/2;

    [_usernameLabel sizeToFit];
    _usernameLabel.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_imageViewIcon.frame) + kGeomSpaceInter, w, CGRectGetHeight(_usernameLabel.frame));
    
    [_username sizeToFit];
    _username.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_usernameLabel.frame) + kGeomSpaceInter, buttonWidth, kGeomHeightTextField);
    
    [_usernameResultMessage sizeToFit];
    _usernameResultMessage.frame = CGRectMake(CGRectGetMaxX(_username.frame)-CGRectGetWidth(_usernameResultMessage.frame), CGRectGetMaxY(_username.frame) + kGeomSpaceInter, CGRectGetWidth(_usernameResultMessage.frame),CGRectGetHeight(_usernameResultMessage.frame));

    [_aboutLabel sizeToFit];
    _aboutLabel.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_usernameResultMessage.frame) + kGeomSpaceInter, w, CGRectGetHeight(_aboutLabel.frame));
    
    _about.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_aboutLabel.frame) + kGeomSpaceInter, buttonWidth, 2*kGeomHeightTextField);
    
    [_aboutResultMessage sizeToFit];
    _aboutResultMessage.frame = CGRectMake((w-buttonWidth)/2, CGRectGetMaxY(_about.frame) + kGeomSpaceInter, buttonWidth, CGRectGetHeight(_aboutResultMessage.frame));
    
    _buttonSignUp.frame = CGRectMake ((w-buttonWidth)/2, h - 2*kGeomSpaceEdge - kGeomHeightButton, buttonWidth, kGeomHeightButton);
    
    _scrollView.contentSize= CGSizeMake(w, h);
}

@end
