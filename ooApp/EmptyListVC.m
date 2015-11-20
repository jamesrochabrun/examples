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
#import "DiscoverVC.h"

@interface EmptyListVC ()

@property (nonatomic, strong) UILabel *labelUpper;
@property (nonatomic,strong)  UILabel *labelPacMan;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *buttonDiscover;
@property (nonatomic, strong) UIButton *buttonLists;

@end

@implementation EmptyListVC

//------------------------------------------------------------------------------
// Name:    viewDidLoad
// Purpose:
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    ENTRY;
    [super viewDidLoad];
    
    self.view.backgroundColor= WHITE;    
    self.automaticallyAdjustsScrollViewInsets= NO;
    self.view.autoresizesSubviews= NO;
    
    self.buttonLists= makeButton( self.view, LOCAL(@"LISTS") , kGeomFontSizeHeader,
                                 BLACK, CLEAR, self,
                                 @selector(userPressedListsButton:),
                                 1);
    
    self.buttonDiscover= makeButton( self.view, LOCAL(@"DISCOVER") , kGeomFontSizeHeader,
                                    BLACK, CLEAR, self,
                                    @selector(userPressedDiscoverButton:),
                                    1);
    
    self.labelUpper= makeLabel ( self.view,  @"This list is hungry\rfor some restaurants.", kGeomFontSizeSubheader);
    self.labelPacMan= makeIconLabel ( self.view,  kFontIconProfile, kGeomForkImageSize);

    UIFont* upperFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
    UIFont* lowerFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail];
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    NSAttributedString *part1=  attributedStringOf( @"Tap the ", kGeomFontSizeHeader);
    NSAttributedString *part2=  attributedIconStringOf( kFontIconAdd, kGeomFontSizeHeader);
    NSAttributedString *part3=  attributedStringOf( @" icon next to a restaurant you like, and select ", kGeomFontSizeHeader);
    NSAttributedString *part4=  attributedStringOf( @"ADD TO LIST.", kGeomFontSizeHeader);

    NSMutableAttributedString* aString= [NSMutableAttributedString  new];
    [aString appendAttributedString:part1];
    [aString appendAttributedString:part2];
    [aString appendAttributedString:part3];
    [aString appendAttributedString:part4];

    self.textView=  makeTextView(self.view, CLEAR, NO);
    _textView.textColor= BLACK;
    _textView.attributedText= aString;
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader:_listItem.name
                           subHeader:nil];
    [self setNavTitle:nto];
    
    [ self.view setNeedsLayout ];
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
// Name:    userPressedDiscoverButton
// Purpose:
//------------------------------------------------------------------------------

- (void)userPressedDiscoverButton:(id)sender
{
    DiscoverVC *vc = [[DiscoverVC  alloc] init];
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
    
    [self.textView sizeToFit];
    float heightForText = _textView.intrinsicContentSize.height;
    const float spacer = kGeomSpaceInter;
    
    float totalHeightNeeded= _labelUpper.intrinsicContentSize.height +_labelPacMan.intrinsicContentSize.height + 2*kGeomHeightButton;
    totalHeightNeeded += heightForText;
    totalHeightNeeded += 3*spacer;
    
    float y= (h-totalHeightNeeded)/2;
    _labelUpper.frame= CGRectMake(0, y, w, _labelUpper.intrinsicContentSize.height);
    y += _labelUpper.intrinsicContentSize.height+ spacer;
    _labelPacMan.frame= CGRectMake(0, y, w, _labelPacMan.intrinsicContentSize.height);
    y +=  _labelPacMan.intrinsicContentSize.height+ spacer;
    
    _textView.frame=CGRectMake((w-kGeomEmptyTextViewWidth)/2, y, kGeomEmptyTextViewWidth, heightForText);
    y+= heightForText+ spacer;
    
    _buttonDiscover.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _buttonLists.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
//    y +=kGeomHeightButton+ spacer;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

@end
