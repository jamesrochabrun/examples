//
//  DiagnosticVC.m
//  ooApp
//
//  Created by Zack S on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

//#import "Common.h"
//#import "CommonUIConstants.h"
#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "DiagnosticVC.h"
#import "Settings.h"
#import "UIImageView+AFNetworking.h"

@interface DiagnosticVC ()
@property (nonatomic,strong)  UIButton* buttonClearUsername;
@property (nonatomic,strong)  UIButton* buttonClearCache;
@property (nonatomic,strong)  UIButton* buttonSearchRadius;
@property (nonatomic,strong)  UIButton* buttonUploadPhoto;
@property (nonatomic,strong)  UITextView* textviewDiagnosticLog;
@property (nonatomic,strong)   UIImageView* ivPhoto;
@end

@implementation DiagnosticVC
{
    int radius;
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
    
    self.view.backgroundColor= [UIColor lightGrayColor];
    _textviewDiagnosticLog= makeTextView(self.view, WHITE, NO);
    _textviewDiagnosticLog.layer.borderColor= GRAY.CGColor;
    _textviewDiagnosticLog.layer.borderWidth= 0.5;
    _textviewDiagnosticLog.layer.cornerRadius= 5;
    _textviewDiagnosticLog.text= APP.diagnosticLogString;
    _textviewDiagnosticLog.textAlignment= NSTextAlignmentLeft;
    _textviewDiagnosticLog.font= [ UIFont systemFontOfSize:kGeomFontSizeDetail ];
    self.automaticallyAdjustsScrollViewInsets= NO;
    
    _buttonClearUsername= makeButton(self.view,  @"CLEAR USERNAME", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doClearUsername:), 1);
    _buttonClearUsername.titleLabel.numberOfLines= 0;
    _buttonClearUsername.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    _buttonClearCache= makeButton(self.view,  @"CLEAR CACHE", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doClearCache:), 1);
    _buttonClearCache.titleLabel.numberOfLines= 0;
    _buttonClearCache.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    radius= [[Settings sharedInstance] searchRadius] / 1000;
    radius*= 2;

    _buttonSearchRadius= makeButton(self.view, [NSString stringWithFormat:@"%dkM RADIUS", radius] , kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doSearchRadius:), 1);
    _buttonSearchRadius.titleLabel.numberOfLines= 0;
    _buttonSearchRadius.titleLabel.textAlignment= NSTextAlignmentCenter;
    
    _buttonUploadPhoto= makeButton(self.view,  @"UPLOAD PHOTO", kGeomFontSizeHeader, WHITE, CLEAR, self, @selector(doPhotoUpload:), 1);
    _buttonUploadPhoto.titleLabel.numberOfLines= 0;
    _buttonUploadPhoto.titleLabel.textAlignment= NSTextAlignmentCenter;
    
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
    
    [_textviewDiagnosticLog scrollRangeToVisible:NSMakeRange([_textviewDiagnosticLog.text length], 0)];
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
// Name:    doPhotoUpload
// Purpose:
//------------------------------------------------------------------------------
- (void)doPhotoUpload: (id) sender
{
    [self presentCameraModal];
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
    NSString* string= [NSString stringWithFormat:@"%dkM RADIUS", radius];
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
    } failure:^(NSError *e) {
        NSString *s= [NSString stringWithFormat: @"error %@",e.localizedDescription];
        message( s);
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
    float  spacing= 16;
    _textviewDiagnosticLog.frame=  CGRectMake(margin,h/2,w-2*margin,h/2-margin);
    
    float x=  margin, y=  margin;
    _buttonClearUsername.frame=  CGRectMake(x,y,kGeomButtonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonClearCache.frame=  CGRectMake(x,y,kGeomButtonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonSearchRadius.frame=  CGRectMake(x,y,kGeomButtonWidth,kGeomHeightButton);
    
    x += kGeomButtonWidth+ spacing;
    y= margin;
    _buttonUploadPhoto.frame=  CGRectMake(x,y,kGeomButtonWidth,kGeomHeightButton);
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
    
    if ( image && [image isKindOfClass:[UIImage class]]) {
        _ivPhoto.image= image;
        
        NSString* text= [NSString stringWithFormat: @"%@", info];
        _textviewDiagnosticLog.text=  text;
        
        [OOAPI uploadUserPhoto:image success:^{
            NSLog  (@"UPLOAD SUCCESS");
        } failure:^(NSError *e) {
            NSLog  (@"UPLOAD FAILURE");
        }];
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