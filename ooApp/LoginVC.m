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
#import "CreateUsernameVC.h"

@interface LoginVC ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, assign) BOOL wentToDiscover;
@end

@implementation LoginVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _wentToDiscover= NO;
    
    _backgroundImageView = makeImageView(self.view, @"background-image.jpg");
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _logo = [[UIImageView alloc] init];
    _logo.contentMode = UIViewContentModeScaleAspectFit;
    _logo.backgroundColor = UIColorRGBA(kColorClear);
    _logo.image = [UIImage imageNamed:@"Logo.png"];
    
    _facebookLoginButton = [[FBSDKLoginButton alloc] init];
    _facebookLoginButton.delegate = self;
    _facebookLoginButton.layer.cornerRadius = kGeomCornerRadius;
    _facebookLoginButton.readPermissions = @[@"public_profile", @"email"];
    
    [self.view addSubview:_backgroundImageView];
    [self.view addSubview:_logo];
    [self.view addSubview:_facebookLoginButton];
    [self doLayout];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose: Programmatic equivalent of constraint equations.
//------------------------------------------------------------------------------
- (void)doLayout
{
    float spacing= kGeomSpaceInter;
    
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    _backgroundImageView.frame=  self.view.bounds;

    float requiredHeight= kGeomLogoHeight + kGeomHeightButton + kGeomLoginVerticalDisplacement+spacing;
    float y=  (h-requiredHeight)/2;
    float x=  (w-kGeomLogoWidth)/2;
    _logo.frame= CGRectMake(x, y, kGeomLogoWidth, kGeomLogoHeight);
    y += kGeomLogoHeight+ spacing;
    x=  (w-kGeomButtonWidth)/2;
    _facebookLoginButton.frame=  CGRectMake(x, y, kGeomButtonWidth, kGeomHeightButton);
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _wentToDiscover= NO;

    [self.navigationController setNavigationBarHidden:YES];
}

//------------------------------------------------------------------------------
// Name:    updateUsername
// Purpose:
//------------------------------------------------------------------------------
- (void)updateUsername: (id) value // NOTE:  the value should be an NSString.
{
    if (!value || ![ value isKindOfClass:[NSString class]] ) {
        return;
    }
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    userInfo.username= value;
    [[Settings sharedInstance]save ];
}

//------------------------------------------------------------------------------
// Name:    updateUserID
// Purpose:
//------------------------------------------------------------------------------
- (void)updateUserID: (id) value // NOTE:  the value should be an NSNumber.
{
    if (!value) {
        return;
    }
    
    UserObject* userInfo= [Settings sharedInstance].userObject;
    userInfo.userID= parseIntegerOrNullFromServer(value);
    [[Settings sharedInstance]save ];

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
    if  (!value) {
        return;
    }
    UserObject* userInfo= [Settings sharedInstance].userObject;
    if (!userInfo.backendAuthorizationToken || ![userInfo.backendAuthorizationToken isEqualToString: value]) {
        userInfo.backendAuthorizationToken= value;
        [APP.diagnosticLogString appendFormat: @"TOKEN: %@\r",value ];
    }
}


//------------------------------------------------------------------------------
// Name:    fetchEmailFromFacebookFor
// Purpose:
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
// Name:    showMainUI
// Purpose:
//------------------------------------------------------------------------------
- (void)showMainUI
{
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
    if  (!email) {
        return;
    }
    
    [self fetchProfilePhoto];
    
    [[LocationManager sharedInstance] askUserWhetherToTrack ];

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
    
    if ([APP connected]) {
        message(@"The Internet is not reachable.");
        return ;
    }
    
//    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
//        message(@"The Internet is not reachable.");
//        return ;
//        
//        // XX: Need to retry after Internet becomes accessible.
//    }
    
    AFHTTPRequestOperation* operation= [[OONetworkManager sharedRequestManager] GET:requestString
                                      parameters:nil
                                         success:^void(id   result) {
                                             NSLog  (@"PRE-EXISTING OO USER %@, %@",  facebookID , result);
                                             [APP.diagnosticLogString appendFormat: @"PRE-EXISTING OO USER %@, %@",  facebookID , result];

                                             if ([result isKindOfClass: [NSDictionary  class] ] ) {
                                                 NSDictionary* d=  (NSDictionary*)result;
                                                 
                                                 NSString* token= d[ @"token"];
                                                 [weakSelf updateAuthorizationToken: token];
                                                 
                                                 NSDictionary* subdictionary=d[ @"user"];
                                                 if (subdictionary) {
                                                     NSString* userid= subdictionary[ @"user_id"];
                                                     [weakSelf updateUserID: userid];
                                                     NSString* username= subdictionary[ @"username"];
                                                     [weakSelf updateUsername: username];
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
                                                 [self performSegueWithIdentifier:@"gotoCreateUsername" sender:self];
                                             }
                                         }
                                         failure:^void(NSError *   error) {
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
                                                 message ( @"A network error has occurred.");
                                                 NSLog  (@"OTHER NETWORK ERROR: %ld", (long)statusCode);
                                             }
                                         }];
    
}

//------------------------------------------------------------------------------
// Name:    fetchDetailsAboutUserFromFacebook
// Purpose:
//------------------------------------------------------------------------------
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
                                  initWithGraphPath:[NSString stringWithFormat:@"/v2.4/%@?fields=first_name,last_name,middle_name,about,birthday,location,email,gender",
                                                     identifier] //picture?type=large&redirect=false
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
        
        requestString=[NSString stringWithFormat: @"https://%@/users/%lu",
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

//------------------------------------------------------------------------------
// Name:    viewDidAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    FBSDKAccessToken *facebookToken = [FBSDKAccessToken currentAccessToken];
    if (facebookToken) {
        // Transition if the user recently logged in.
        [self showMainUI];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog (@"loginButtonDidLogOut: USER LOGGED OUT");
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//------------------------------------------------------------------------------
// Name:    didCompleteWithResultnil
// Purpose:
//------------------------------------------------------------------------------
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email"
                                       parameters:nil]
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

//------------------------------------------------------------------------------
// Name:    fetchProfilePhoto
// Purpose: Get the user's photo URL from Facebook.
//------------------------------------------------------------------------------
-(void)fetchProfilePhoto
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=email,picture"
                                       parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSDictionary* dictionary=  result;
             if (![dictionary isKindOfClass:[NSDictionary class ]]) {
                 return;
             }
             
             NSLog(@"FACEBOOK USER DICTIONARY:%@",  dictionary);
             
             NSDictionary* pictureDictionary= dictionary[ @"picture"];
             if ( pictureDictionary) {
                 NSDictionary* pictureData= pictureDictionary[ @"data"];
                 if  (pictureData ) {
                     NSString* urlString= pictureData[ @"url"];
                     if  ( urlString ) {
                         UserObject* userInfo= [Settings sharedInstance].userObject;
                         NSString* existingURL= userInfo.imageURLString;
                         if (1|| !existingURL  ||  ![existingURL isEqualToString: urlString]) {
                             userInfo.imageURLString=  urlString;
                             [[Settings sharedInstance] save ];
                             
                             NSLog (@"NEW PROFILE PICTURE URL: %@", urlString);
                             
                             // NOTE: We are no longer in the main thread.
                             
                             NSURL *url= [ NSURL  URLWithString: urlString];
                             if  (url ) {
                                 NSData *data= [NSData dataWithContentsOfURL:url];
                                 if  ( data) {
                                     UIImage *image= [ UIImage imageWithData:data];
                                     if  (image ) {
                                         [userInfo setUserProfilePhoto:image];
                                     }
                                 }
                             }
                         }
                     }
                 }
             }
         }
     }];
}

@end
