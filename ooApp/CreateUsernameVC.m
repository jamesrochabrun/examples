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
#import "ListTVCell.h"
#import "OOAPI.h"

@interface CreateUsernameVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic,strong) UILabel* labelUsernameTaken;
@property (nonatomic,strong) UITextField* fieldUsername;
@property (nonatomic,strong) UIButton* buttonSignUp;
@end

@implementation CreateUsernameVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor= WHITE;
    
    self.scrollView= [UIScrollView  new];
    [self.view  addSubview: _scrollView ];
    
    self.buttonSignUp= makeButton( _scrollView,  @"SIGN UP", kGeomFontSizeHeader,
                                 BLACK, CLEAR, self,
                                 @selector(userPressedSignUpButton:),
                                 1);
    
    self.fieldUsername= [ UITextField  new];
    _fieldUsername.delegate= self;
    _fieldUsername.backgroundColor= WHITE;
    _fieldUsername.borderStyle= UITextBorderStyleLine;
    [_scrollView addSubview: _fieldUsername];
    
    self.labelUsernameTaken= makeLabel(_scrollView,  @"status: username is taken", kGeomFontSizeDetail);
    self.labelUsernameTaken.textColor= RED;
    UIFont* upperFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeHeader];
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    NSAttributedString *aString= [[NSAttributedString  alloc]
                                      initWithString:@"We should put some introductory text here.\r"
                                      attributes: @{
                                                    NSFontAttributeName: upperFont,
                                                    NSParagraphStyleAttributeName:paragraphStyle
                                                    }];
    
    self.textView=  makeTextView(_scrollView, CLEAR, NO);
    _textView.textColor= BLACK;
    _textView.attributedText= aString;
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader: self.listName ?: @"Missing list name"
                           subHeader:nil];
    [self setNavTitle:  nto];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
//    [ self.view setNeedsLayout ];
}

- (void)keyboardHidden: (id) foobar
{
    _scrollView.contentInset= UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)keyboardShown: (NSNotification*) not
{
    
    _scrollView.contentInset= UIEdgeInsetsMake(0, 0, 100, 0);
    [ self.view setNeedsLayout ];
}

- (void)userPressedSignUpButton: (id) sender
{
    BaseVC *vc= [[BaseVC  alloc] init];
    vc.view.backgroundColor= [ UIColor redColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userPressedDiscoverButton: (id) sender
{
    
    BaseVC *vc= [[BaseVC  alloc] init];
    vc.view.backgroundColor= [ UIColor yellowColor];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) doLayout
{
    float h=  self.view.bounds.size.height;
    float w=  self.view.bounds.size.width;
    
#define kGeomForkImageSize 80
#define kGeomEmptyTextViewWidth 200
#define kGeomEmptyTextFieldWidth 150

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
    
    _labelUsernameTaken.frame=CGRectMake (0,y,w,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _buttonSignUp.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _scrollView.contentSize= CGSizeMake(w-1, y);
}

//-(void) layout
//{
//    [super layout];
//    
//    NSDictionary *metrics = @{@"buttonHeight":@(kGeomHeightButton),
//                              @"width":@200.0,
//                              @"margin":@(kGeomSpaceEdge),
//                              @"spacing": @(kGeomSpaceInter)
//                              };
//    
//    NSDictionary *views = NSDictionaryOfVariableBindings(_textView, _buttonDiscover, _buttonLists, _iv);
//    
//    [self.view addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_iv]-[_textView]-[_buttonDiscover]-[_buttonLists]-|"
//                                             options:NSLayoutFormatDirectionLeadingToTrailing
//                                             metrics:metrics
//                                               views:views]];
//    
//    [self.view addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|"
//                                             options:NSLayoutFormatDirectionLeadingToTrailing
//                                             metrics:metrics
//                                               views:views]];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillLayoutSubviews
{
    [ super viewWillLayoutSubviews ];
  
//    [self layout];
    [self doLayout];
}

@end
