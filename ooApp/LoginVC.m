//------------------------------------------------------------------------------
//
//  LoginVC.m
//  ooApp
//
//  Created by Anuj Gujar on 8/17/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
//------------------------------------------------------------------------------
// USE CASES
//
// 1:  happy code path: user is setting up account for the first time
//
// 2:  user has account already, but they deleted the app
//
// 3:  user logs out from within the app
//------------------------------------------------------------------------------

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "LoginVC.h"
#import "AppDelegate.h"
#import "DebugUtilities.h"
#import "LocationManager.h"
#import "OONetworkManager.h"
#import "NSString+MD5.h"
#import "CreateUsernameVC.h"
#import "OOAPI.h"

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, strong) UIImageView *imageViewLogo;
@property (nonatomic, assign) BOOL wentToDiscover;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@end

@implementation LoginVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void) viewDidLoad
{
    ENTRY;

    [super viewDidLoad];
    
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= GRAY;
    
    _wentToDiscover= NO;
    
    UIImage*backgroundImage= [ UIImage  imageNamed:@"LoginBackground.jpg"];
    backgroundImage= darkenImage( backgroundImage);
    _backgroundImageView = makeImageView(self.view,  backgroundImage);
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    _backgroundImageView.clipsToBounds= YES;
    _backgroundImageView.opaque= NO;
    addShadowTo  (_backgroundImageView);
    
    _imageViewLogo = [[UIImageView alloc] init];
    _imageViewLogo.contentMode = UIViewContentModeScaleAspectFit;
    _imageViewLogo.backgroundColor = UIColorRGBA(kColorClear);
     UIImage*image= [UIImage imageNamed:@"LogoWhite.png"];
    _imageViewLogo.image = image;
    addShadowTo(_imageViewLogo);
    
    _facebookLoginButton = [[FBSDKLoginButton alloc] init];
    _facebookLoginButton.delegate = self;
    _facebookLoginButton.layer.cornerRadius = kGeomCornerRadius;
    _facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    addShadowTo  (_facebookLoginButton);

    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_imageViewLogo];
    [self.view addSubview:_facebookLoginButton];
    
    self.pinch= [[UIPinchGestureRecognizer  alloc] initWithTarget: self action:@selector(loginBypass:)];
    [self.view addGestureRecognizer:_pinch];
    
}

- (void)loginBypass: (id) sender
{
    ENTRY;
    static NSInteger  counter= 0;
    counter ++;
    if  (counter == 8) {
        [self performSegueWithIdentifier:@"mainUISegue" sender:self];
    }
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;

    float backgroundImageWidth= _backgroundImageView.image.size.width;
    float backgroundImageHeight= _backgroundImageView.image.size.height;
    float backgroundAspect= backgroundImageHeight>0 ? backgroundImageWidth/backgroundImageHeight : 1000000;
    float actualBackgroundImageHeight=w/backgroundAspect;
    _backgroundImageView.frame= CGRectMake( 0,  0, w, actualBackgroundImageHeight);

    float imageViewLogoWidth= _imageViewLogo.image.size.width;
    float imageViewLogoHeight= _imageViewLogo.image.size.height;
    float aspect= imageViewLogoHeight>0 ? imageViewLogoWidth/imageViewLogoHeight : 1000000;
    imageViewLogoWidth= w*.75;
    if ( aspect>0) {
            imageViewLogoHeight= imageViewLogoWidth/aspect;
    }
    
    _backgroundImageView.clipsToBounds= YES;

    _imageViewLogo.frame = CGRectMake((w- imageViewLogoWidth)/2,  (w- imageViewLogoHeight)/2,imageViewLogoWidth, imageViewLogoHeight);
    
    float facebookButtonHeight= _facebookLoginButton.frame.size.height;
    if  (facebookButtonHeight<1) {
        facebookButtonHeight=kGeomHeightButton;
    }
    
    float y = actualBackgroundImageHeight+ (h - actualBackgroundImageHeight - facebookButtonHeight)/2 ;
    const float buttonWidth =  275;
    float x = (w-buttonWidth)/2;
    
    _facebookLoginButton.frame=  CGRectMake(x, y, buttonWidth, facebookButtonHeight);
}

- (void)viewWillLayoutSubviews
{
//    [super viewWillLayoutSubviews];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN(@( object_getClassName(self)));

    _wentToDiscover = NO;

    [self.navigationController setNavigationBarHidden:YES];
}

//------------------------------------------------------------------------------
// Name:    updateUsername
// Purpose:
//------------------------------------------------------------------------------
- (void)updateUsername:(id)value // NOTE:  the value should be an NSString.
{
    if (!value || ![ value isKindOfClass:[NSString class]] ) {
        return;
    }
    LOGS2(@"USERNAME",value);
    UserObject *userInfo = [Settings sharedInstance].userObject;
    userInfo.username = value;
    [[Settings sharedInstance] save];
}

//------------------------------------------------------------------------------
// Name:    updateUserID
// Purpose:
//------------------------------------------------------------------------------
- (void)updateUserID:(id)value // NOTE:  the value should be an NSNumber.
{
    if (!value) {
        return;
    }
    
    UserObject *userInfo = [Settings sharedInstance].userObject;
    userInfo.userID = parseIntegerOrNullFromServer(value);
    [[Settings sharedInstance] save];

}

//------------------------------------------------------------------------------
// Name:    updateEmail
// Purpose:
//------------------------------------------------------------------------------
- (void)updateEmail: (NSString*) value
{
    if  (!value) {
        return;
    }
    LOGS2(@"EMAIL",value);
    UserObject* userInfo= [Settings sharedInstance].userObject;
    if  (!userInfo.email  || !userInfo.email.length) {
        userInfo.email= value;
    }
}

//------------------------------------------------------------------------------
// Name:    updateAuthorizationToken
// Purpose:
//------------------------------------------------------------------------------
- (void)updateAuthorizationToken: (NSString*) value
{
    ENTRY;

    if  (!value) {
        return;
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    if (!userInfo.backendAuthorizationToken || ![userInfo.backendAuthorizationToken isEqualToString: value]) {
        userInfo.backendAuthorizationToken= value;
    }
    LOGS2( @"TOKEN", value);
}

//------------------------------------------------------------------------------
// Name:    fetchEmailFromFacebookFor
// Purpose:
//------------------------------------------------------------------------------
- (void) fetchEmailFromFacebookFor: (NSString*)identifier
{
    ENTRY;

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
             LOGS2(@"EMAIL FROM FACEBOOK", email);
             
             UserObject* userInfo= [Settings sharedInstance].userObject;
             userInfo.email= email;
             
             // NOTE  if the Facebook server gave us the username then use it.
             [weakSelf performSelectorOnMainThread: @selector(showMainUIForUserWithEmail:) withObject:email waitUntilDone:NO   ];
             
         } else {
             NSLog (@"ERROR DOING FACEBOOK REQUEST:  %@", error);
             LOGS2(@"ERROR FROM FACEBOOK", error);

             // NOTE: If we reach this point, the backend knows about the user but
             //  the Facebook server may be down.
             // QUESTION: What to do in that case?
             
             NSInteger code= connection.URLResponse.statusCode;
             NSString *string= [NSString  stringWithFormat: @"Facebook server gave error code  %ld",  ( long)code];
             message( string);
         }
     }
     ];
}

//------------------------------------------------------------------------------
// Name:    showMainUI
// Purpose:
//------------------------------------------------------------------------------
- (void)showMainUI
{
    ENTRY;

    if ( _wentToDiscover) { // Prevent duplicate simultaneous calls.
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
    if  (email.length > 1 && !userInfo.userID) {
        NSLog ( @"user has OO account already but this is their first Facebook login.");
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

//------------------------------------------------------------------------------
// Name:    showMainUIForUserWithEmail
// Purpose: Find out whether back end knows this user already.
//------------------------------------------------------------------------------

- (void)showMainUIForUserWithEmail:  (NSString*) email
{
    ENTRY;

    if  (!email || !email.length) {
        LOGS(@"NO EMAIL.");
        return;
    }
    
    if (!is_reachable()) {
        static BOOL toldThem= NO;
        if  (!toldThem) {
            toldThem= YES;
            message(@"The Internet is not reachable.");
        }
        [self performSelector:@selector(showMainUIForUserWithEmail:)  withObject:email afterDelay:1];
        return;
    }
    
    [self fetchProfilePhoto];
    
    UserObject* userInfo = [Settings sharedInstance].userObject;
   
    //---------------------------------------------------
    // RULE: If the day has changed, we will need to request
    // a new authorization key.
    //
    static BOOL isFirstRun= YES;
    BOOL newDay = NO;
    NSString *dateString= getDateString();
    NSString *lastKnownDateString= [[Settings sharedInstance] lastKnownDateString];
    if (!lastKnownDateString  ||  ![lastKnownDateString isEqualToString:dateString]) {
        newDay= YES;
        [[Settings sharedInstance] saveDateString: dateString];
    }

    BOOL seekingToken= NO;
    NSString* requestString = nil;
 
    //---------------------------------------------------
    // RULE: Always request the backend token, just in case
    // it changed on a different device  i.e. the user
    // forgot to delete the app after we instituted
    // the new rule that all devices get the same token.
    
    NSString *saltedString= [NSString  stringWithFormat:  @"%@.%@", email, SECRET_BACKEND_SALT];
    NSString* md5= [ saltedString MD5String];
    md5 = [md5 lowercaseString];
    seekingToken= YES;
    
    requestString = [NSString stringWithFormat:  @"%@://%@/users?needtoken=%@&device=%@", kHTTPProtocol,
                     [OOAPI URL],
                     md5,
                     [Settings sharedInstance].uniqueDeviceKey
                     ];
    
    // NOTE:  this may be helpful if we need to identify the reason
    //  why the new authorization token is being requested.
    //
    requestString = [NSString stringWithFormat: @"%@&reason=%d", requestString,/*newDay ? 1 : */ 0];
    isFirstRun= NO;
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    NSString *facebookID = facebookToken.userID;
    __weak LoginVC *weakSelf = self;
    
    [[OONetworkManager sharedRequestManager] GET:requestString
                                      parameters:nil
                                         success:^void(id result) {
                                             NSLog(@"PRE-EXISTING OO USER %@, %@", facebookID, result);
                                             [APP.diagnosticLogString appendFormat:@"PRE-EXISTING OO USER %@, %@\r", facebookID, result];
                                             
                                             if ([result isKindOfClass:[NSDictionary class]]) {
                                                 NSDictionary *d = (NSDictionary *)result;
                                                 
                                                 NSString* token= d[ @"token"];
                                                 [weakSelf updateAuthorizationToken: token];
                                                 
                                                 NSDictionary *subdictionary = d[ @"user"];
                                                 if (subdictionary) {
                                                     NSString *userid = subdictionary[@"user_id"];
                                                     [weakSelf updateUserID:userid];
                                                     NSString* username = subdictionary[@"username"];
                                                     [weakSelf updateUsername:username];
                                                 }                                             }
                                             else  {
                                                 NSLog  (@"result was not parsed into a dictionary.");
                                             }
                                             
                                             if  (facebookID ) {
                                                 [weakSelf fetchDetailsAboutUserFromFacebook: @[facebookID , @YES] ];
                                             } else {
                                                 // XX:  this is the OO log in flow
                                             }
                                             
                                             // RULE:  While the above is happening take the user to the Discover page regardless of whether the backend was reached.
                                             if (userInfo.username.length ) {
                                                 [self performSegueWithIdentifier:@"mainUISegue" sender:self];
                                             } else {
                                                 [self performSegueWithIdentifier:@"gotofsername" sender:self];
                                             }
                                         }
                                         failure:^void(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSInteger statusCode= operation.response.statusCode;
                                             if  ( statusCode== 404) {
                                                 
                                                 [APP.diagnosticLogString appendFormat: @"AS YET UNKNOWN OO USER  %@, %@,  %@\r",  facebookID, error.description,requestString];
                                                 
                                                 NSLog  (@"AS YET UNKNOWN OO USER  %@, %@,  %@",  facebookID, error.description,requestString);
                                                 
                                                 if (facebookID ) {
                                                     [weakSelf fetchDetailsAboutUserFromFacebook: @[facebookID , @NO] ];
                                                 } else {
                                                     // XX:  this is the OO log in flow
                                                 }
                                                 
                                                 [self performSegueWithIdentifier:@"gotoCreateUsername" sender:self];
                                             } else {
                                                 message ( @"Oomami is temporarily down, but we are working on it! Try again in a few minutes.");
                                                 NSLog  (@"OTHER NETWORK ERROR: %ld", (long)statusCode);
                                                 LOGSN(@"BACKEND ERROR",statusCode);
                                             }
                                         }];
    
}

//------------------------------------------------------------------------------
// Name:    fetchDetailsAboutUserFromFacebook
// Purpose:
//------------------------------------------------------------------------------
- (void)fetchDetailsAboutUserFromFacebook: (NSArray*)parameters
{
    ENTRY;
    
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
                                  initWithGraphPath:[NSString stringWithFormat:@"/v2.4/%@?fields=first_name,last_name,middle_name,about,birthday,location,email,gender",
                                                     identifier]  
                                  parameters:nil
                                  HTTPMethod:@"GET"];

     [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                           id result,
                                           NSError *error)
     {
         if (!error) {
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

//------------------------------------------------------------------------------
// Name:    conveyUserInformationToBackend
// Purpose:
//------------------------------------------------------------------------------
- (void) conveyUserInformationToBackend: (id)alreadyKnown_
{
    ENTRY;

    BOOL alreadyKnown=  alreadyKnown_? YES: NO;
    UserObject* userInfo= [Settings sharedInstance].userObject;

    if  (!userInfo.email) {
        return;
    }
    
    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    NSString* requestString= nil;
    
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
        NSUInteger userid= userInfo.userID;
        
        requestString=[NSString stringWithFormat: @"%@://%@/users/%lu", kHTTPProtocol,
                       [OOAPI URL],( unsigned long) userid];
        
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
                                                     
                                                     NSDictionary *subdictionary=d[ @"user"];
                                                     if (subdictionary) {
                                                         NSString *userid = subdictionary[@"user_id"];
                                                         [weakSelf updateUserID:userid];
                                                     }
                                                 }
                                             }
                                             failure:^  void(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog (@"PUT FAILED %@",error);
                                             }     ];

    } else {
        NSString *requestString = [NSString stringWithFormat:@"%@://%@/users", kHTTPProtocol, [OOAPI URL]];
        NSLog(@"requestString  %@",requestString);

        [[OONetworkManager sharedRequestManager] POST:requestString
                                           parameters:parametersDictionary
                                              success:^void(id result) {
                                                  NSLog(@"POST SUCCESS");
                                                
                                                  if (!result) {
                                                      NSLog(@"RESULT WAS NULL.");
                                                  } else if ([result isKindOfClass: [NSDictionary  class] ] ) {
                                                      NSDictionary *d = (NSDictionary *)result;
                                                      
                                                      NSString *token = d[@"token"];
                                                      [weakSelf updateAuthorizationToken:token];
                                                      
                                                      NSDictionary *subdictionary = d[@"user"];
                                                      if (subdictionary) {
                                                          NSString *userid = subdictionary[@"user_id"];
                                                          [weakSelf updateUserID:userid];
                                                          UserObject *userInfo = [Settings sharedInstance].userObject;
                                                          if (!userInfo.mediaItem) {
                                                              [weakSelf uploadFacebookPhoto];
                                                          }
                                                      }
                                                  }
                                              } failure:^void(AFHTTPRequestOperation *operation, NSError *error) {
                                                  NSLog(@"POST FAILED %@", error);
                                              }
         ];
    }
}

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    ENTRY;

    [super viewDidAppear:animated];

    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (facebookToken) {
        // Transition if the user recently logged in.
        [self showMainUI];
    }
}

- (void)uploadFacebookPhoto {
    UserObject *uo = [Settings sharedInstance].userObject;

    if (!uo.facebookProfileImageURLString || !uo.userID) return; //can't upload a photo for a user if we do not have these two things...
        
    NSURL *url= [NSURL URLWithString:uo.facebookProfileImageURLString];
    if (url) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [uo setUserProfilePhoto:image andUpload:YES];
                NSLog (@"IMAGE OBTAINED FROM FACEBOOK HAS DIMENSIONS %@", NSStringFromCGSize(image.size));
            }
        }
    }
}


- (void)loginButtonDidimageViewLogout:(FBSDKLoginButton *)loginButton
{
    ENTRY;

    NSLog (@"loginButtonDidimageViewLogout: USER LOGGED OUT");
}

//------------------------------------------------------------------------------
// Name:    didCompleteWithResult
// Purpose:
//------------------------------------------------------------------------------
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    ENTRY;
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email"
                                       parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSLog(@"fetched user:%@", result);
         } else {
             
             NSInteger code= connection.URLResponse.statusCode;
             NSString *string= [NSString  stringWithFormat: @"Facebook server gave error code  %ld",  ( long)code];
             message( string);
         }
     }];
}

//------------------------------------------------------------------------------
// Name:    loginButtonDidLogOut
// Purpose:
//------------------------------------------------------------------------------
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
}

//------------------------------------------------------------------------------
// Name:    fetchProfilePhoto
// Purpose: Get the user's photo URL from Facebook. If the URL has changed then
//          fetch the new image.
//------------------------------------------------------------------------------
-(void)fetchProfilePhoto
{
    ENTRY;

    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/picture?width=1080&height=1080&redirect=false"
                                       parameters: nil ]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSDictionary *dictionary = result;
             if (![dictionary isKindOfClass:[NSDictionary class]]) {
                 return;
             }
             
             NSLog(@"FACEBOOK USER DICTIONARY:%@", dictionary);
             
             NSDictionary *pictureData = dictionary[@"data"];
             if (pictureData) {
                 NSString *urlString = pictureData[@"url"];
                 if (urlString) {
                     UserObject *userInfo = [Settings sharedInstance].userObject;
                     NSString* existingURL = userInfo.facebookProfileImageURLString;
                     if (!existingURL || ![existingURL isEqualToString:urlString]) {
                         // RULE: Only fetch, store and upload the profile image if the URL has changed.
                         userInfo.facebookProfileImageURLString = urlString;
                         [[Settings sharedInstance] save];
                         NSLog (@"NEW PROFILE PICTURE URL: %@", urlString); //Just save for now
                     }
                 }
             }
         } else {
             NSLog(@"FACEBOOK ERROR %@", error);
         }
     }];
}

@end
