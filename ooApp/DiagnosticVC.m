//
//  DiagnosticVC.m
//  ooApp
//
//  Created by Zack S on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
#import "DefaultVC.h"
#import "OOAPI.h"
#import "UserObject.h"
#import "RestaurantObject.h"
#import "ListObject.h"
#import "DiagnosticVC.h"
#import "Settings.h"

@interface DiagnosticVC ()
@property (nonatomic,strong)  UIButton* buttonClearUsername;
@property (nonatomic,strong)  UIButton* buttonClearCache;
@property (nonatomic,strong)  UITextView* textviewDiagnosticLog;
@end

@implementation DiagnosticVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
 
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
// Purpose:
//------------------------------------------------------------------------------
- (void)doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    float  margin= kGeomSpaceEdge;
    float  spacing= kGeomSpaceInter;
    _textviewDiagnosticLog.frame=  CGRectMake(margin,h/2,w-2*margin,h/2-margin);
    float x=  margin, y=  75;
    _buttonClearUsername.frame=  CGRectMake(x,y,kGeomButtonWidth,kGeomHeightButton);
    y+=  spacing +kGeomHeightButton;
    _buttonClearCache.frame=  CGRectMake(x,y,kGeomButtonWidth,kGeomHeightButton);
    
    
}
@end
