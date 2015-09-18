//
//  LoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/17/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "LoginVC.h"
#import "Common.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Common.h"
#import "DebugUtilities.h"
#import "LocationManager.h"
#import "OONetworkManager.h"
#import "NSString+MD5.h"

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) FBSDKLoginButton *facebookLogin;
@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UIButton *forgotPassword;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, assign) BOOL showingKeyboard;
@property (nonatomic, assign) BOOL wentToDiscover;
@property (nonatomic, strong) NSArray *keyboardConstraint;
@end

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _wentToDiscover= NO;
    
    _backgroundImage = [[UIImageView alloc] init];
    _backgroundImage.image = [UIImage imageNamed:@"background-image.jpg"];
    _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    _logo = [[UIImageView alloc] init];
    _logo.contentMode = UIViewContentModeScaleAspectFit;
    _logo.backgroundColor = UIColorRGBA(kColorClear);
    _logo.image = [UIImage imageNamed:@"Logo.png"];
    
    _facebookLogin = [[FBSDKLoginButton alloc] init];
    _facebookLogin.delegate = self;
    _facebookLogin.layer.cornerRadius = kGeomCornerRadius;
    [_facebookLogin addTarget:self action:@selector(loginThroughFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    _username = [[UITextField alloc] init];
    _username.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    _username.placeholder = @"username";
    _username.layer.cornerRadius = kGeomCornerRadius;
    _username.delegate= self;
    
    _password = [[UITextField alloc] init];
    _password.backgroundColor = UIColorRGBA(kColorGrayMiddle);
    _password.placeholder = @"password";
    _password.textColor = UIColorRGB(kColorWhite);
    _password.layer.cornerRadius = kGeomCornerRadius;
    _password.delegate = self;
    
    _forgotPassword = [[UIButton alloc] init];
    [_forgotPassword withText:@"Forgot your password?" fontSize:9 width:40 height:10 backgroundColor:kColorClear target:self selector:@selector(showMainUI)];
    
    _forgotPassword.translatesAutoresizingMaskIntoConstraints = NO;
    _username.translatesAutoresizingMaskIntoConstraints = NO;
    _password.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    _facebookLogin.translatesAutoresizingMaskIntoConstraints = NO;
    _logo.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_backgroundImage];
    [self.view addSubview:_logo];
    [self.view addSubview:_facebookLogin];
    [self.view addSubview:_username];
    [self.view addSubview:_password];
    [self.view addSubview:_forgotPassword];
    [self layout];
    
    [[LocationManager sharedInstance] askUserWhetherToTrack ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginDidTranspire) name:@"facebookLoginDidTranspire" object:nil ];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)facebookLoginDidTranspire
{
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (facebookToken) {
        // Instantaneous transition if the user  really logged in.
        [self showMainUI];
    } else {
        NSLog (@"Was not able to get token, will try again in one second.");
        [self performSelector:@selector(facebookLoginDidTranspire2) withObject:nil afterDelay:3];
    }
}
- (void)facebookLoginDidTranspire2
{
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (facebookToken) {
        // Instantaneous transition if the user  really logged in.
        [self showMainUI];
    } else {
        NSLog (@"Really unable to get token.");
    }
}

- (void)layout
{
    // Create the views and metrics dictionaries
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(kGeomSpaceEdge), @"spaceInter": @(kGeomSpaceInter)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _forgotPassword, _logo, _username, _password, _facebookLogin, _backgroundImage);
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(75)-[_logo(100)]-(>=20)-[_facebookLogin(height)]-(>=60)-[_username(height)]-spaceInter-[_password(height)]-(>=20)-[_forgotPassword]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    // Horizontal layout - we only need one "column" of information because of the alignment options used when creating the horizontal layout
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_logo(<=275)]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_facebookLogin(width)]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_username(_facebookLogin)]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_password(_facebookLogin)]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(>=20)-[_forgotPassword]-(>=20)-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_logo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_logo.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_facebookLogin
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_facebookLogin.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_username
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_username.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_password
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_password.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_forgotPassword
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_forgotPassword.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self performSelector:@selector(adjustInputFields) withObject:nil afterDelay:4];
}

- (void)adjustInputFields
{
    //    [self.view layoutIfNeeded];
    //    [self adjustInputField];
}

- (void)adjustInputField
{
    [self.view removeConstraints: self.view.constraints];
    
    int keyboardHeight= 140;
    NSDictionary *metrics = @{@"height":@(kGeomHeightButton), @"width":@200.0, @"spaceEdge":@(keyboardHeight+kGeomSpaceEdge), @"spaceInter": @(3)};
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _forgotPassword, _logo, _username, _password, _facebookLogin, _backgroundImage);
    
    NSString* s= [NSString stringWithFormat:  @"V:|-(50)-[_logo(50)]-[_facebookLogin(0)]-spaceInter-[_username(height)]-spaceInter-[_password(height)]-(>=250)-[_forgotPassword]-spaceEdge-|"
                  ];
    self.keyboardConstraint= [NSLayoutConstraint constraintsWithVisualFormat: s
                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:metrics
                                                                       views:views];
    
    // Vertical layout - note the options for aligning the top and bottom of all views
    [self.view addConstraints: self.keyboardConstraint
     ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _wentToDiscover= NO;

    [self.navigationController setNavigationBarHidden:YES];
}

- (void)updateUserID: (id) value// NOTE:  the value should be an NSNumber.
{
    if (!value) {
        return;
    }
    
    if  ([ value isKindOfClass:[NSString class]] ) {
        NSString* s= value;
        int i = atoi( s.UTF8String);
        if  (!i) {
            return;
        }
        value= [NSNumber numberWithInt: i ];
    }
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    id currentUserID= userInfo.userID;
    BOOL isANumber = [currentUserID isKindOfClass:[NSNumber class]];
    if  (currentUserID && isANumber ) {
        NSNumber *n= currentUserID;
        int i= [n intValue];
        int j= [((NSNumber*) value) intValue];
        if  (i != j ) {
            NSLog  (@"USER ID HAS CHANGED");
        }
    }
    
    userInfo.userID= value;
    [[Settings sharedInstance]save ];
    
}

- (void)updateEmail: (NSString*) value
{
    if  (!value) {
        return;
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    if  (!userInfo.email  || !userInfo.email.length) {
        userInfo.email= value;
    }
}

- (void)updateAuthorizationToken: (NSString*) value
{
    if  (!value) {
        return;
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    userInfo.backendAuthorizationToken= value;
}

- (void) fetchEmailFromFacebookFor: (NSString*)identifier
{
    __weak LoginVC *weakSelf= self;
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/v2.4/%@?fields=email,gender",
                                                     identifier]
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                           id result,
                                           NSError *error)
     {
    if (!error) {
        NSString* gender=nil;
        NSString* email=nil;
        
        if ([result isKindOfClass: [NSDictionary  class] ] ) {
            NSDictionary*d= (NSDictionary*)result;
            gender= d [ @"gender"];
            email= d [ @"email"];
        }
        NSLog(@"OBTAINED EMAIL FROM FACEBOOK IN ORDER TO GET AUTHORIZATION TOKEN: %@",email);
        
        UserObject* userInfo= [Settings sharedInstance].userObject;
        userInfo.email= email;
        
        // NOTE  if the Facebook server gave us the username then use it.
        [weakSelf performSelectorOnMainThread: @selector(showMainUIForUserWithEmail:) withObject:email waitUntilDone:NO   ];
        
    } else {
        NSLog (@"ERROR DOING FACEBOOK REQUEST:  %@", error);
        
        // NOTE: If we reach this point, the backend knows about the user but
        //  the Facebook server may be down.
        // QUESTION: What to do in that case?
    }
}
];

}

- (void)showMainUI
{
    if ( _wentToDiscover) {
        return;
    }
    _wentToDiscover= YES;
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (!facebookToken) {
        NSLog  (@"THERE IS NO FACEBOOK TOKEN");
    }
    else {
        NSSet * permissions= [ facebookToken permissions ];
        NSLog  (@"USER PERMISSIONS=  %@", permissions );
    }
    
    //---------------------------------------------------
    // RULE: If we have valid user information already
    // that means the user logged in via OO but not FB,
    // so we must update the backend to add the FB
    // user ID.
    //
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSString *email= userInfo.email;
    if  (email.length > 1 && userInfo.userID.intValue <= 0) {
        message( @"user has OO account already but this is their first Facebook login.");
    }

    //---------------------------------------------------
    // RULE:  if the application was deleted, we may have
    //  the Facebook ID but not the email address and
    //  certainly not the authorization token.  in this case
    //  we need to ask FB for the email address.
    //
    NSString *token= userInfo.backendAuthorizationToken;
    NSString*  identifier = facebookToken.userID;
    if (facebookToken && identifier && (!token  || !token.length) && (! email ||  !email.length)) {
        NSLog  (@"HAVE FACEBOOK TOKEN BUT NO EMAIL AND NO AUTHORIZATION TOKEN");
        [self fetchEmailFromFacebookFor:identifier];
    } else {
        [self showMainUIForUserWithEmail:  email];
    }
}

// Find out if back end knows this user already.
- (void)showMainUIForUserWithEmail:  (NSString*) email
{
    if  (!email) {
        return;
    }
    
//    email=@"another@test.user";
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSString* requestString= [NSString stringWithFormat:  @"https://%@/users/emails/%@", kOOURL,  email];
   
    //---------------------------------------------------
    // RULE: If the day has changed, we will need to request
    // a new authorization key.
    //
    int newDay= 0;
    NSString* dateString= getDateString();
    NSString* lastKnownDateString= [[Settings sharedInstance] lastKnownDateString];
    if (lastKnownDateString && ![lastKnownDateString isEqualToString:dateString]) {
        newDay= 1;
    }
    newDay= 1;

    //---------------------------------------------------
    // RULE:  If we have the email address but not the
    // authorization token, we will need to request the token.
    //
    NSString *backendToken= userInfo.backendAuthorizationToken;
    BOOL  seekingToken= NO;
    if ((newDay  || (!backendToken || !backendToken.length)) && email && email.length) {
        NSString *saltedString= [NSString  stringWithFormat:  @"%@.%@", email, SECRET_BACKEND_SALT];
        NSString* md5= [ saltedString MD5String ];
        md5 = [md5 lowercaseString];
        NSLog (@"MD5=  %@",md5);
        seekingToken= YES;
        
        requestString= [NSString stringWithFormat:  @"https://%@/users?needtoken=%@", kOOURL, md5];
        
        // NOTE:  this has helped identify the reason
        //  why the new authorization token is being
        //  requested in the first place.
        //
        requestString= [NSString stringWithFormat: @"%@&reason=%d", requestString, newDay ? 1 : 0];
    }
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    NSString*  facebookID = facebookToken.userID;
    __weak LoginVC *weakSelf= self;

    [[OONetworkManager sharedRequestManager] GET:requestString
                                      parameters:nil
                                         success:^void(id   result) {
                                             NSLog  (@"PRE-EXISTING OO USER %@, %@",  facebookID , result);
                                             
                                             if ([result isKindOfClass: [NSDictionary  class] ] ) {
                                                 NSDictionary* d=  (NSDictionary*)result;
                                                 
                                                 NSString* token= d[ @"token"];
                                                 [weakSelf updateAuthorizationToken: token];
                                                 
                                                 NSDictionary* subdictionary=d[ @"user"];
                                                 if (subdictionary) {
                                                     NSString* userid= subdictionary[ @"user_id"];
                                                     [weakSelf updateUserID: userid];
                                                 }                                             }
                                             else  {
                                                 NSLog  (@"result was not parsed into a dictionary.");
                                             }
                                             
                                             if  (facebookID ) {
                                                 [weakSelf fetchDetailsAboutUserFromFacebook: @[facebookID , @YES] ];
                                             } else {
                                                 // XX:  this is the OO log in flow
                                             }
                                         }
                                         failure:^void(NSError *   error) {
                                             NSLog  (@"AS YET UNKNOWN OO USER  %@, %@,  %@",  facebookID, error.localizedDescription,requestString);
                                             
                                             if (facebookID ) {
                                                 [weakSelf fetchDetailsAboutUserFromFacebook: @[facebookID , @NO] ];
                                             } else {
                                                 // XX:  this is the OO log in flow
                                             }
                                         }];
    
    // RULE:  While the above is happening take the user to the Discover page regardless of whether the backend was reached.
    [self performSegueWithIdentifier:@"mainUISegue" sender:self];
}

- (void)fetchDetailsAboutUserFromFacebook: (NSArray*)parameters
{
    if  (! parameters) {
        return;
    }
    
    NSString* identifier =  parameters[0];
    BOOL alreadyKnown=   ((NSNumber *)parameters[1]).boolValue;

    //---------------------------------------------
    //  Make a formal request for user information.
    //
    __weak LoginVC *weakSelf= self;

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/v2.4/%@?fields=first_name,last_name,middle_name,about,birthday,location,email,name,gender",
                                                     identifier] //picture?type=large&redirect=false
                                  parameters:nil
                                  HTTPMethod:@"GET"];

     [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                           id result,
                                           NSError *error)
     {
         if (!error) {
             NSString* name=nil;
             NSString* firstName=nil;
             NSString* lastName=nil;
             NSString* middleName=nil;
             NSString* gender=nil;
             NSString* email=nil;
             NSString* birthday=nil;
             NSString* location=nil;
             NSString* about=nil;
             
             if ([result isKindOfClass: [NSDictionary  class] ] ) {
                 NSDictionary*d= (NSDictionary*)result;
                 
                 name= d [ @"name"];
                 firstName= d[ @"first_name"];
                 lastName= d [ @"last_name"];
                 middleName= d [ @"middle_name"];
                 gender= d [ @"gender"];
                 email= d [ @"email"];
                 birthday= d [ @"birthday"];
                 location= d [ @"location"];
                 about= d [ @"about"];
             }
             
             // Validation.
             //
             if  ([birthday hasPrefix: @"0000"]) {
                 birthday= nil;
             }
             
             NSLog(@"FACEBOOK RESPONSE: %@",result);
             
             UserObject* userInfo= [Settings sharedInstance].userObject;
             if  (lastName ) {
                 userInfo.lastName=lastName;
             }
             if  (middleName ) {
                 userInfo.middleName =middleName;
             }
             if  (firstName ) {
                 userInfo.firstName=firstName;
             }
             if  ( name ) {
                 userInfo.name=name;
             }
             if  ( gender) {
                 userInfo.gender=  gender;
             }
             if  (email ) {
                 userInfo.email=  email;
             }
             if (birthday ) {
                 userInfo.birthday=  birthday;
             }
             if (location ) {
                 userInfo.location=  location;
             }
             if (about ) {
                 userInfo.about=  about;
             }
             if (identifier ) {
                 userInfo.facebookIdentifier=  identifier;
             }
             
             // NOTE  if the Facebook server gave us the username then use it.
             [weakSelf performSelectorOnMainThread:@selector(conveyUserInformationToBackend:) withObject:alreadyKnown?@"":nil waitUntilDone:NO ];
             
         } else {
             NSLog (@"ERROR DOING FACEBOOK REQUEST:  %@", error);
             
             // NOTE: If we reach this point,  the backend does not yet know about this user.
         }
     }
     ];     // startWithCompletionHandler
    
}

- (void) conveyUserInformationToBackend: (id)alreadyKnown_
{
    BOOL alreadyKnown=  alreadyKnown_? YES: NO;
    UserObject* userInfo= [Settings sharedInstance].userObject;

    if  (!userInfo.email) {
        return;
    }
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    NSString* requestString= nil;
    
    if  (!userInfo.firstName  && !userInfo.lastName) {
        userInfo.firstName= nil;
        userInfo.lastName= nil;
        NSArray*array=  [ userInfo.name  componentsSeparatedByString: @" " ];
        if ( array &&  array.count >= 2) {
            userInfo.firstName=   array[0];
            userInfo.lastName=  array[ array.count - 1];
        }
        else {
            userInfo.firstName=  userInfo.name;
        }
    }
    
    if ( userInfo.middleName && userInfo.middleName.length) {
        userInfo.middleName= [userInfo.middleName substringToIndex: 1];
    }
    
    NSMutableDictionary* parametersDictionary=  [NSMutableDictionary new];
    if  (userInfo.email.length ) {
        parametersDictionary [ @"email"]= userInfo.email;
    }
    if  (facebookToken.tokenString  && facebookToken.tokenString.length ) {
        parametersDictionary [ @"token"]= facebookToken.tokenString;
    }
    if  (userInfo.facebookIdentifier.length ) {
        parametersDictionary [ @"facebook_id"]= userInfo.facebookIdentifier;
    }
    if  (userInfo.firstName.length ) {
        parametersDictionary [ @"first_name"]= userInfo.firstName;
    }
    if  (userInfo.lastName.length ) {
        parametersDictionary [ @"last_name"]= userInfo.lastName;
    }
    if  (userInfo.middleName.length ) {
        parametersDictionary [ @"middle_initial"]= userInfo.middleName;
    }
    if  (userInfo.gender.length ) {
        parametersDictionary [ @"gender"]= userInfo.gender;
    }
    if  (userInfo.about.length ) {
        parametersDictionary [ @"about"]= userInfo.about;
    }
    if  (userInfo.location.length ) {
        parametersDictionary [ @"zip_code_local"]= userInfo.location;
    }
    if  (userInfo.birthday.length ) {
        parametersDictionary [ @"date_of_birth"]= userInfo.birthday;
    }
    
    __weak LoginVC *weakSelf= self;
 
    if  (alreadyKnown ) {
        UserObject* userInfo= [Settings sharedInstance].userObject;
        NSNumber* userid= userInfo.userID;
        
        requestString=[NSString stringWithFormat: @"https://%@/users/%@",
                       kOOURL, userid];
        
        requestString= [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];

        [[OONetworkManager sharedRequestManager] PUT: requestString
                                          parameters: parametersDictionary
                                             success:^void(id   result) {
                                                 NSLog  (@"PUT SUCCESS");
                                                 
                                                 if (!result) {
                                                     NSLog  (@"RESULT WAS NULL.");
                                                 }
                                                 else if ([result isKindOfClass: [NSDictionary  class] ] ) {
                                                     NSDictionary* d=  (NSDictionary*)result;
                                                     
                                                     NSString* token= d[ @"token"];
                                                     [weakSelf updateAuthorizationToken: token];
                                                     
                                                     NSDictionary* subdictionary=d[ @"user"];
                                                     if (subdictionary) {
                                                         NSString* userid= subdictionary[ @"user_id"];
                                                         [weakSelf updateUserID: userid];
                                                     }
                                                 }
                                             }
                                             failure:^  void(NSError *error) {
                                                 NSLog (@"PUT FAILED %@",error);
                                             }     ];

    }else {
        
        NSString* requestString=[NSString stringWithFormat: @"https://%@/users",
                                 kOOURL
                                 ];
        NSLog (@"requestString  %@",requestString);

        [[OONetworkManager sharedRequestManager] POST: requestString
                                           parameters: parametersDictionary
                                              success:^void(id   result) {
                                                  NSLog  (@"POST SUCCESS");
                                                  
                                                  if (!result) {
                                                      NSLog  (@"RESULT WAS NULL.");
                                                  }
                                                  else if ([result isKindOfClass: [NSDictionary  class] ] ) {
                                                      NSDictionary* d=  (NSDictionary*)result;
                                                      
                                                      NSString* token= d[ @"token"];
                                                      [weakSelf updateAuthorizationToken: token];
                                                      
                                                      NSDictionary* subdictionary=d[ @"user"];
                                                      if (subdictionary) {
                                                          NSString* userid= subdictionary[ @"user_id"];
                                                          [weakSelf updateUserID: userid];
                                                      }
                                                  }
                                              }
                                              failure:^  void(NSError *error) {
                                                  NSLog (@"POST FAILED %@",error);
                                              }     ];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewDidDisappear:animated ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [DebugUtilities addBorderToViews:@[self.view, _backgroundImage, _logo, _facebookLogin, _username, _password]];
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (facebookToken) {
        // Instantaneous transition if the user recently logged in.
        [self showMainUI];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)keyboardHidden: (id) foobar
{
    self.showingKeyboard= NO;
    [self.view removeConstraints: self.keyboardConstraint];
    self.keyboardConstraint= nil;
    
    [self  layout];
}

- (void)keyboardShown: (id) foobar
{
    self.showingKeyboard= YES;
    [self.view removeConstraints: self.keyboardConstraint];
    [self  layout];
    [self adjustInputField];
}

- (void)loginThroughFacebook:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [ login logInWithReadPermissions:@[@"email"]
                  fromViewController: self
                             handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Automatic login was not possible,  so transferring to Facebook website or app...
            
            NSLog (@"Unable to log you in immediately: %@",error.localizedDescription);
        }
        else if (result.isCancelled) {
            // Handle cancellations
            NSLog  (@"LOGIN PROCESS WAS CANCELED");
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
                [self showMainUI];
            } else {
                NSLog  (@"Granted permission do not include email");
            }
        }
    }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog (@"loginButtonDidLogOut");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == _password) {
        [theTextField resignFirstResponder];
    } else if (theTextField == _username) {
        theTextField.returnKeyType = UIReturnKeyGo;
    }
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             //profile photo link
             //10152388406186153/picture?type=large
             //fields
             //me?fields=first_name,age_range,last_name,id,gender,email
             
             NSLog(@"fetched user:%@", result);
         }
     }];
    
}

@end
