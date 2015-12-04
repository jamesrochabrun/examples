//
//  DiagnosticVC.m
//  ooApp
//
//  Created by Zack Smith on 9/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "DiagnosticVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"
#import "CreateUsernameVC.h"

@interface DiagnosticVC ()
@property (nonatomic,strong)  UIButton* buttonClearUsername;
@property (nonatomic,strong)  UIButton* buttonClearCache;
@property (nonatomic,strong)  UIButton* buttonSendLog;
@property (nonatomic,strong)  UIButton* buttonSearchRadius;
@property (nonatomic,strong)  UIButton* buttonUploadPhoto;
@property (nonatomic,strong)  UIButton* buttonUploadHugePhoto;
@property (nonatomic,strong)  UIButton* buttonTakePhoto;
@property (nonatomic,strong)  UIButton* buttonCreateUsername;
@property (nonatomic,strong)  UISwitch* switchUsingStage;
@property (nonatomic,strong)  UILabel* labelUsingStage;

@property (nonatomic,strong)  UITextView* textviewDiagnosticLog;
@property (nonatomic,strong)   UIImageView* ivPhoto;
@property (nonatomic,strong)   UIImage* hugeImage;
@property (nonatomic,strong) MFMailComposeViewController *mailController;
@end

@implementation DiagnosticVC
{
    int radius;
}

//------------------------------------------------------------------------------
// Name:    viewWillAppear
// Purpose:
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ANALYTICS_SCREEN( @( object_getClassName(self)));
}

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Diagnostics" subHeader: @"& Testing"];
    self.navTitle = nto;
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    self.view.backgroundColor= [UIColor lightGrayColor];
    
    _textviewDiagnosticLog= makeTextView(self.view, WHITE, NO);
    _textviewDiagnosticLog.layer.borderColor= GRAY.CGColor;
    _textviewDiagnosticLog.layer.borderWidth= 0.5;
    _textviewDiagnosticLog.layer.cornerRadius= 5;
    _textviewDiagnosticLog.textAlignment= NSTextAlignmentLeft;
    _textviewDiagnosticLog.font= [ UIFont systemFontOfSize:kGeomFontSizeDetail ];

    _buttonClearUsername= makeButton(self.view,  @"CLEAR USERNAME", kGeomFontSizeHeader-2, WHITE, CLEAR, self, @selector(doClearUsername:), 1);
    _buttonClearUsername.titleLabel.numberOfLines= 0;
    _buttonClearUsername.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    _buttonClearCache= makeButton(self.view,  @"CLEAR CACHE", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doClearCache:), 1);
    _buttonClearCache.titleLabel.numberOfLines= 0;
    _buttonClearCache.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    self.buttonSendLog= makeButton(self.view,  @"SEND LOG", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSendLog:), 1);
    _buttonSendLog.titleLabel.numberOfLines= 0;
    _buttonSendLog.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    radius= [[Settings sharedInstance] searchRadius] / 1000;
    radius*= 2;
    
    self.switchUsingStage=  [UISwitch new];
    [ self.view addSubview: _switchUsingStage];
    _switchUsingStage.on= APP.usingStagingServer;
    self.labelUsingStage=  makeLabel( self.view,  @"USE\rSTAGE", kGeomFontSizeHeader);
    _labelUsingStage.textColor= WHITE;
    _labelUsingStage.textAlignment= NSTextAlignmentRight;
    [_switchUsingStage addTarget:self action:@selector(stageValueChanged:)  forControlEvents:UIControlEventValueChanged];
    
    _buttonSearchRadius= makeButton(self.view, [NSString stringWithFormat:@"%dkM RADIUS", radius] , kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSearchRadius:), 1);
    _buttonSearchRadius.titleLabel.numberOfLines= 0;
    _buttonSearchRadius.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    _buttonTakePhoto= makeButton(self.view,  @"TAKE PHOTO", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doTakePhoto:), 1);
    _buttonTakePhoto.titleLabel.numberOfLines= 0;
    _buttonTakePhoto.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    self.buttonCreateUsername= makeButton(self.view,  @"USER NAME", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doCreateUsername:), 1);
    _buttonTakePhoto.titleLabel.numberOfLines= 0;
    _buttonTakePhoto.titleLabel.textAlignment= NSTextAlignmentCenter;
    
//    self.buttonUploadHugePhoto= makeButton(self.view,  @"UPLOAD HUGE", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doPhotoHugeUpload:), 1);
//    _buttonUploadHugePhoto.titleLabel.numberOfLines= 0;
//    _buttonUploadHugePhoto.titleLabel.textAlignment= NSTextAlignmentCenter;
    
//    _buttonUploadPhoto= makeButton(self.view,  @"UPLOAD PHOTO", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doPhotoUpload:), 1);
//    _buttonUploadPhoto.titleLabel.numberOfLines= 0;
//    _buttonUploadPhoto.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    self.ivPhoto= makeImageView( self.view, nil);
    _ivPhoto.contentMode= UIViewContentModeScaleAspectFit;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadTextFieldAndScrollToBottom];
}

- (void)stageValueChanged: (id) sender
{
    APP.usingStagingServer= _switchUsingStage.on;
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    [ud setBool:APP.usingStagingServer forKey:kUserDefaultsUsingStagingServer];
    [ud synchronize];
    
    if  ( APP.usingStagingServer) {
        [APP.diagnosticLogString appendString:@"Using stage. You can kill the app now.\r"];
    } else {
        [APP.diagnosticLogString appendString:@"Using production. You can kill the app now.\r"];
    }
    [self loadTextFieldAndScrollToBottom];
}

- (void) loadTextFieldAndScrollToBottom
{
    NSString*string= APP.diagnosticLogString;
    NSUInteger length= string.length;
    _textviewDiagnosticLog.text= string;
    if  (!length) {
        return;
    }
    [_textviewDiagnosticLog setContentSize: _textviewDiagnosticLog.textContainer.size];
    [_textviewDiagnosticLog scrollRangeToVisible:NSMakeRange(length-1, 1)];
}

//------------------------------------------------------------------------------
// Name:    doSendLog
// Purpose:
//------------------------------------------------------------------------------
- (void)doSendLog:(id) sender
{
    self.mailController = [[MFMailComposeViewController alloc] init];
    [_mailController setMessageBody: APP.diagnosticLogString isHTML: NO];
    [_mailController setSubject:  @"OO log"];
    _mailController.mailComposeDelegate = self;
    [self presentViewController: _mailController animated: YES completion: NULL ];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [_mailController dismissViewControllerAnimated: YES completion: NULL];
    self.mailController = nil;
}

//------------------------------------------------------------------------------
// Name:    doClearCache
// Purpose:
//------------------------------------------------------------------------------
- (void)doClearCache: (id) sender
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if  ([UIImageView respondsToSelector:@selector(sharedImageCache)] ) {
        id foo = [UIImageView sharedImageCache];
        if  (foo ) {
            if  ([foo respondsToSelector:@selector( removeAllObjects)] ) {
                [ foo performSelector:@selector( removeAllObjects) withObject:nil];
            }
        }
    }
    
    message( @"cache cleared.");
}

//------------------------------------------------------------------------------
// Name:    doTakePhoto
// Purpose:
//------------------------------------------------------------------------------
- (void)doTakePhoto: (id) sender
{
    [self presentCameraModal];
}

//------------------------------------------------------------------------------
// Name:    doPhotoHugeUpload
// Purpose:
//------------------------------------------------------------------------------
- (void)doPhotoHugeUpload: (id) sender
{
    self.hugeImage= [ UIImage  imageNamed: @"background-image.jpg"];
//    [OOAPI uploadPhoto:self.hugeImage
//                    to:UPLOAD_DESTINATION_DIAGNOSTIC
//            identifier:0
//               success:^{
//                   NSLog  (@"Uploaded huge photo.");
//                   [self performSelectorOnMainThread:@selector(loadTextFieldAndScrollToBottom)  withObject:nil waitUntilDone:NO ];
//               } failure:^(NSError *error) {
//                   NSLog  (@"Failed to upload huge photo. %@",error);
//               }];
}

//------------------------------------------------------------------------------
// Name:    doPhotoUpload
// Purpose:
//------------------------------------------------------------------------------
- (void)doPhotoUpload: (id) sender
{
    if (! _hugeImage) {
        message( @"Please take a photo first.");
        return;
    }
//    [OOAPI uploadPhoto: _hugeImage
//                    to:UPLOAD_DESTINATION_DIAGNOSTIC
//            identifier:0
//               success:^{
//                   NSLog  (@"Uploaded photo.");
//                   
//                   [self performSelectorOnMainThread:@selector(loadTextFieldAndScrollToBottom)  withObject:nil waitUntilDone:NO ];
//               } failure:^(NSError *error) {
//                   NSLog  (@"Failed to upload photo.");
//               }];
    
}

//------------------------------------------------------------------------------
// Name:    doCreateUsername
// Purpose: Push the screen for testing purposes.
//------------------------------------------------------------------------------
- (void)doCreateUsername: (id) sender
{
    CreateUsernameVC *vc=[[CreateUsernameVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    doSearchRadius
// Purpose:
//------------------------------------------------------------------------------
- (void)doSearchRadius: (id) sender
{
    [[Settings sharedInstance] setSearchRadius:  radius *1000];
    radius*= 2;
    if  (radius> 100 ) {
        radius= 1;
    }
    NSString *string= [NSString stringWithFormat:@"%dkM RADIUS", radius];
    [_buttonSearchRadius setTitle:string forState:UIControlStateNormal];
}

//------------------------------------------------------------------------------
// Name:    doClearUsername
// Purpose:
//------------------------------------------------------------------------------
- (void)doClearUsername: (id) sender
{
    UserObject* userInfo= [Settings sharedInstance].userObject;
    NSString* username= userInfo.username;
    if  (!username || ! username.length) {
        message( @"Username is not yet set.");
        return;
    }
    
    [OOAPI clearUsernameWithSuccess:^(NSArray *names) {
        message( @"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *e) {
        NSString *s = [NSString stringWithFormat: @"error %@",e.localizedDescription];
        message(s);
    } ];
    
    userInfo.username= nil;
    [[Settings sharedInstance ]save ];
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
    float  spacing= kGeomSpaceEdge;
    _textviewDiagnosticLog.frame=  CGRectMake(margin,h/2,w-2*margin,h/2-margin);
    
    float buttonWidth=(w-4*spacing)/3;
    
    float x=  spacing, y=  margin;
    _buttonClearUsername.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonClearCache.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonSearchRadius.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    
    x += buttonWidth+ spacing;
    y= margin;
    _buttonTakePhoto.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonUploadPhoto.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonCreateUsername.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    
    x += buttonWidth+ spacing;
    y= margin;
    _buttonSendLog.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _switchUsingStage.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    _labelUsingStage.frame=  CGRectMake(x,y,buttonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    
    _ivPhoto.frame = CGRectMake(0,0,w,_textviewDiagnosticLog.frame.origin.y);
    [self.view sendSubviewToBack:_ivPhoto ];
    
}

//------------------------------------------------------------------------------
// Name:    presentCameraModal
// Purpose:
//------------------------------------------------------------------------------
- (void)presentCameraModal
{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        return;
    }
    
    UIImagePickerController *ic = [[UIImagePickerController alloc] init];
    [ic setAllowsEditing: YES];
    [ic setSourceType: UIImagePickerControllerSourceTypeCamera];
    [ic setCameraCaptureMode: UIImagePickerControllerCameraCaptureModePhoto];
    [ic setShowsCameraControls: YES];
    [ic setDelegate: self];
    [ self presentViewController: ic animated: YES completion: NULL];
}

//------------------------------------------------------------------------------
// Name:    didFinishPickingMediaWithInfo
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image=  info[ @"UIImagePickerControllerEditedImage"];
    if (!image) {
        image= info[ @"UIImagePickerControllerEditedImage"];
    }
    self.hugeImage= image;
    
    if ( image && [image isKindOfClass:[UIImage class]]) {
        _ivPhoto.image= image;
        
        NSString* text= [NSString stringWithFormat: @"%@", info];
        _textviewDiagnosticLog.text=  text;
        
    }

    [self  dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------------------------------------------------
// Name:    imagePickerControllerDidCancel
// Purpose:
//------------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    message( @"you canceled taking a photo");
    [self  dismissViewControllerAnimated:YES completion:nil];
}
@end
