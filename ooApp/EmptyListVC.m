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

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *label;
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
    
    self.buttonLists= makeButton( self.view, LOCAL(@"LISTS") , kGeomFontSizeHeader,
                                 BLACK, CLEAR, self,
                                 @selector(userPressedListsButton:),
                                 1);
    
    self.buttonDiscover= makeButton( self.view, LOCAL(@"DISCOVER") , kGeomFontSizeHeader,
                                    BLACK, CLEAR, self,
                                    @selector(userPressedDiscoverButton:),
                                    1);
    
    _label= makeIconLabel ( self.view,  @"q", kGeomForkImageSize);
    
    UIFont* upperFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
    UIFont* lowerFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail];
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    NSMutableAttributedString* aString= [NSMutableAttributedString  new];
    NSAttributedString *upperString= [[NSAttributedString  alloc]
                                      initWithString: LOCAL(@"This list needs some \rrestaurants.\r")
                                      attributes: @{
                                                    NSFontAttributeName: upperFont,
                                                    NSParagraphStyleAttributeName:paragraphStyle
                                                    }];
    
    NSAttributedString *lowerString= [[NSAttributedString  alloc]
                                      initWithString: LOCAL (@"\rTap the icon next to a \rrestaurant you like, and select\rADD TO LIST.")
                                      attributes: @{
                                                    NSFontAttributeName: lowerFont,
                                                    NSParagraphStyleAttributeName:paragraphStyle
                                                    }];
    [aString appendAttributedString:upperString];
    [aString appendAttributedString:lowerString];

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
    float heightForText = _textView.bounds.size.height;
    const float spacer = kGeomSpaceInter;
    
    float totalHeightNeeded= heightForText+kGeomForkImageSize + 2*kGeomHeightButton;
    totalHeightNeeded += 3*spacer;
    
    float y= (h-totalHeightNeeded)/2;
    _label.frame= CGRectMake(0, y, w, kGeomForkImageSize);
    y += kGeomForkImageSize+ spacer;
    
    _textView.frame=CGRectMake((w-kGeomEmptyTextViewWidth)/2, y, kGeomEmptyTextViewWidth, heightForText);
    y+= heightForText+ spacer;
    
    _buttonDiscover.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _buttonLists.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
//    y +=kGeomHeightButton+ spacer;
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
//    NSDictionary *views = NSDictionaryOfVariableBindings(_textView, _buttonDiscover, _buttonLists, _label);
//    
//    [self.view addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_label]-[_textView]-[_buttonDiscover]-[_buttonLists]-|"
//                                             options:NSLayoutFormatDirectionLeadingToTrailing
//                                             metrics:metrics
//                                               views:views]];
//    
//    [self.view addConstraints:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|"
//                                             options:NSLayoutFormatDirectionLeadingToTrailing
//                                             metrics:metrics
//                                               views:views]];
//    [self.view setNeedsLayout];
//}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    [self doLayout];
}

@end
