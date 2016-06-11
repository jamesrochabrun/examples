//
//  EmptyListVC.m
//  ooApp
//
//  Created by Zack Smith on 9/23/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "EmptyListVC.h"
#import "UserObject.h"
#import "Settings.h"
#import "Common.h"
#import "ListStripTVCell.h"
#import "OOAPI.h"
#import "ListsVC.h"
#import "AppDelegate.h"
#import "SearchVC.h"

@interface EmptyListVC ()

@property (nonatomic, strong) UILabel *labelUpper;
@property (nonatomic, strong) UILabel *labelPacMan;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *buttonExplore;
@property (nonatomic, strong) UIButton *buttonLists;

@end

@implementation EmptyListVC  {
    float heightForText;
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
    ENTRY;
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    self.view.backgroundColor= UIColorRGBA(kColorBackgroundTheme);

    [self removeNavButtonForSide:kNavBarSideTypeLeft];
    [self addNavButtonWithIcon:kFontIconBack target:self action:@selector(done:) forSide:kNavBarSideTypeLeft isCTA:NO];

    float borderWidth= 0;
    if  ([UIScreen  mainScreen].bounds.size.height  < 481 ) {
        borderWidth= .5;
    }
    
    self.buttonLists= makeButton( self.view, LOCAL(@"LISTS") , kGeomFontSizeSubheader,
                                 UIColorRGBA(kColorTextActive), UIColorRGBA(kColorBlack), self,
                                 @selector(userPressedListsButton:),
                                 borderWidth);
    
    self.buttonExplore = makeButton( self.view, LOCAL(@"EXPLORE") , kGeomFontSizeSubheader,
                                    UIColorRGBA(kColorTextActive), UIColorRGBA(kColorBlack), self,
                                    @selector(userPressedExploreButton:),
                                    borderWidth);
    if ( borderWidth>0) {
        UIColor*gray= UIColorRGBA(0x777777);
        _buttonExplore.layer.borderColor= gray.CGColor;
        _buttonLists.layer.borderColor= gray.CGColor;
    }
    [Common addShadowTo:self.buttonLists withColor:kColorBlack];
    [Common addShadowTo:self.buttonExplore withColor:kColorBlack];
   
    self.labelUpper= makeLabel ( self.view,  @"This list is hungry\rfor some restaurants.", kGeomFontSizeHeader);
    self.labelPacMan= makeIconLabel ( self.view,  kFontIconPerson, kGeomForkImageSize);
    
    _labelUpper.textColor= UIColorRGBA(kColorWhite);
    _labelPacMan.textColor= UIColorRGBA(kColorWhite);

    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    paragraphStyle.lineSpacing= 5;
    
    NSAttributedString *part1=  attributedStringWithColorOf( @"Tap the ", kGeomFontSizeSubheader,UIColorRGBA(kColorWhite));
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b roundButtonWithIcon:kFontIconAdd fontSize:kGeomIconSizeSmall width:30 height:30 backgroundColor:kColorBackgroundTheme target:nil selector:nil];
    
    textAttachment.image = [UIImage imageFromView:b];
    textAttachment.bounds=  CGRectMake(0,-3,18,18);
    NSAttributedString *part2 = [NSAttributedString attributedStringWithAttachment:textAttachment];
    NSAttributedString *part3=  attributedStringWithColorOf( @" icon next to a restaurant you like, and select ", kGeomFontSizeSubheader,UIColorRGBA(kColorWhite));
    NSAttributedString *part4=  attributedBoldStringWithColorOf( @"ADD TO LIST.", kGeomFontSizeSubheader,UIColorRGBA(kColorWhite));
    
    NSMutableAttributedString* aString= [NSMutableAttributedString  new];
    [aString appendAttributedString:part1];
    [aString appendAttributedString:part2];
    [aString appendAttributedString:part3];
    [aString appendAttributedString:part4];
    
    [aString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, aString.length)];
    
    self.textView=  makeTextView(self.view, UIColorRGBA(kColorClear), NO);
    _textView.textColor= UIColorRGBA(kColorWhite);
    _textView.attributedText= aString;
    heightForText= aString.size.height;
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:_listItem.name
                           subHeader:nil];
    [self setNavTitle:nto];
    
    [ self.view setNeedsLayout ];
}

- (void)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
// Name:    userPressedListsButton
// Purpose:
//------------------------------------------------------------------------------
- (void)userPressedListsButton:(id)sender
{
    ListsVC *vc= [[ListsVC alloc] init];
    vc.listToAddTo = _listItem;
    vc.eventBeingEdited= self.eventBeingEdited;
    [vc getLists];
    [self.navigationController pushViewController:vc animated:YES];
}
//------------------------------------------------------------------------------
// Name:    userPressedExploreButton
// Purpose:
//------------------------------------------------------------------------------

- (void)userPressedExploreButton:(id)sender
{
    SearchVC *vc = [[SearchVC alloc] init];
    vc.listToAddTo = _listItem;
    vc.eventBeingEdited= self.eventBeingEdited;
    [self.navigationController pushViewController:vc animated:YES];
}

//------------------------------------------------------------------------------
// Name:    doLayout
// Purpose:
//------------------------------------------------------------------------------
-(void)doLayout
{
    CGFloat h = height(self.view);
    CGFloat w = width(self.view);
    float vspace= kGeomVerticalSpaceCreateList;
    if  ([UIScreen  mainScreen].bounds.size.height  < 481 ) {
        vspace/= 2;
    }
        
    [self.textView sizeToFit];
    [_labelUpper sizeToFit];
    [_labelPacMan sizeToFit];

    heightForText = _textView.frame.size.height;
    const float spacer = kGeomSpaceInter;
    
    float totalHeightNeeded= _labelUpper.frame.size.height +_labelPacMan.frame.size.height + kGeomHeightCreateListButton;
    totalHeightNeeded += heightForText;
    totalHeightNeeded += 3* vspace;
    
    float y= (h-totalHeightNeeded)/2;
    _labelUpper.frame= CGRectMake(0, y, w, _labelUpper.intrinsicContentSize.height);
    y += _labelUpper.intrinsicContentSize.height+ vspace;
    _labelPacMan.frame= CGRectMake(0, y, w, _labelPacMan.intrinsicContentSize.height);
    y +=  _labelPacMan.intrinsicContentSize.height+ vspace;
    
    _textView.frame=CGRectMake((w-kGeomEmptyTextViewWidth)/2, y, kGeomEmptyTextViewWidth, heightForText);
    y+= heightForText+ vspace;
    
    float x=  (w-2*kGeomWidthButton-spacer)/2;
    _buttonExplore.frame=CGRectMake (x,y,kGeomWidthButton,kGeomHeightCreateListButton);
    x +=kGeomWidthButton+spacer;
    _buttonLists.frame=CGRectMake (x,y,kGeomWidthButton,kGeomHeightCreateListButton);
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

@end
