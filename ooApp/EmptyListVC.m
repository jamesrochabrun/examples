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
#import "ListTVCell.h"
#import "OOAPI.h"

@interface EmptyListVC ()

@property (nonatomic, strong)   UITextView *textView;
@property (nonatomic,strong)  UIImageView* iv;
@property (nonatomic,strong) UIButton* buttonDiscover;
@property (nonatomic,strong) UIButton* buttonLists;
@end

@implementation EmptyListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    CGSize labelSize = [@"Abc" sizeWithAttributes:@{NSFontAttributeName:_name.font}];

    self.view.backgroundColor= WHITE;
    
    self.buttonLists= makeButton( self.view,  @"LISTS", kGeomFontSizeHeader,
                                 BLACK, CLEAR, self,
                                 @selector(userPressedListsButton:),
                                 1);
    
    self.buttonDiscover= makeButton( self.view,  @"DISCOVER", kGeomFontSizeHeader,
                                    BLACK, CLEAR, self,
                                    @selector(userPressedDiscoverButton:),
                                    1);
    
    self.iv= makeImageView( self.view,  @"forkKnife");
    _iv.contentMode= UIViewContentModeScaleAspectFit;
    
    UIFont* upperFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeSubheader];
    UIFont* lowerFont= [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeDetail];
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle  alloc] init];
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    NSMutableAttributedString* aString= [NSMutableAttributedString  new];
    NSAttributedString *upperString= [[NSAttributedString  alloc]
                                      initWithString:@"This list needs some \rrestaurants.\r"
                                      attributes: @{
                                                    NSFontAttributeName: upperFont,
                                                    NSParagraphStyleAttributeName:paragraphStyle
                                                    }];
    
    NSAttributedString *lowerString= [[NSAttributedString  alloc]
                                      initWithString: @"\rTap the icon next to a \rrestaurant you like, and select\rADD TO LIST."
                                      attributes: @{
                                                    NSFontAttributeName: lowerFont,
                                                    NSParagraphStyleAttributeName:paragraphStyle
                                                    }];
    [aString appendAttributedString:upperString];
    [aString appendAttributedString:lowerString];

    self.textView=  makeTextView(self.view, CLEAR, NO);
    _textView.textColor= BLACK;
    _textView.textAlignment= NSTextAlignmentCenter;
    _textView.attributedText= aString;
    
    NavTitleObject *nto = [[NavTitleObject alloc]
                           initWithHeader: self.listName ?: @"Unnamed list"
                           subHeader:nil];
    [self setNavTitle:  nto];
    
    [ self.view setNeedsLayout ];
}

- (void)userPressedListsButton: (id) sender
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
    
    [self.textView sizeToFit ];
    float heightForText= _textView.bounds.size.height;
    const float spacer=kGeomSpaceInter;
    
    float totalHeightNeeded= heightForText+kGeomForkImageSize +2*kGeomHeightButton;
    totalHeightNeeded += 3*spacer;
    
    float y= (h-totalHeightNeeded)/2;
    _iv.frame= CGRectMake(0, y, w, kGeomForkImageSize);
    y += kGeomForkImageSize+ spacer;
    
    _textView.frame=CGRectMake((w-kGeomEmptyTextViewWidth)/2, y, kGeomEmptyTextViewWidth, heightForText);
    y+= heightForText+ spacer;
    
    _buttonDiscover.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
    _buttonLists.frame=CGRectMake ((w-kGeomButtonWidth)/2,y,kGeomButtonWidth,kGeomHeightButton);
    y +=kGeomHeightButton+ spacer;
    
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
