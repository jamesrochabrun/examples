//
//  OOTextEntryVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/2/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOTextEntryVC.h"
#import "OOAPI.h"

@interface OOTextEntryVC ()
@property (nonatomic, strong) UIButton *postButton;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation OOTextEntryVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textView = [[UITextView alloc] init];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.delegate = self;
    _textView.text = self.defaultText;
    _textView.keyboardType = UIKeyboardTypeTwitter;
    _textView.textColor = UIColorRGBA(kColorWhite);
    _textView.backgroundColor = UIColorRGBA(kColorBlack);
    _textView.font = [UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH2];
    _textView.layer.cornerRadius = kGeomCornerRadius;
    [_textView setScrollEnabled:NO];
    [self.view addSubview:_textView];
    
    _postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_postButton withText:@"Post" fontSize:kGeomFontSizeH2 width:50 height:40 backgroundColor:kColorOffBlack target:self selector:@selector(post:)];
    [_postButton setTitleColor:UIColorRGBA(kColorWhite) forState:UIControlStateNormal];
    _postButton.translatesAutoresizingMaskIntoConstraints = NO;
    _postButton.layer.borderWidth = 0.5;
    _postButton.layer.borderColor = UIColorRGBA(kColorOffBlack).CGColor;
    _postButton.layer.cornerRadius = kGeomCornerRadius;
    _postButton.contentEdgeInsets = UIEdgeInsetsMake(kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter, kGeomSpaceInter);
    
    [self.view addSubview:_postButton];
    self.view.backgroundColor = UIColorRGBA(kColorBackgroundTheme);

    [self setRightNavWithIcon:kFontIconRemove target:self action:@selector(closeTextEntry)];
    [self setLeftNavWithIcon:@"" target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_textView becomeFirstResponder];
}

- (NSString*)text;
{
    return _textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString= [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (_textLengthLimit) {
        return newString.length < _textLengthLimit;
    } else {
        return YES;
    }
}

- (void)setDefaultText:(NSString *)defaultText
{
    if (defaultText == _defaultText) return;
    _defaultText = defaultText;
    _textView.text = _defaultText;
}

- (void)post:(UIButton *)sender
{
    [_textView resignFirstResponder];
    [_delegate textEntryFinished:[self text]];
}

- (void)closeTextEntry
{
    [_textView resignFirstResponder];
    [_delegate textEntryFinished:_defaultText]; //close cancels the changes made by the user
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *metrics = @{@"height":@(2*kGeomHeightStripListRow), @"buttonY":@(kGeomHeightStripListRow-30), @"spaceEdge":@(kGeomSpaceEdge), @"spaceEdgeX2":@(2*kGeomSpaceEdge), @"spaceCellPadding":@(kGeomSpaceCellPadding), @"spaceInter": @(kGeomSpaceInter), @"nameWidth":@(kGeomHeightStripListCell-2*(kGeomSpaceEdge)), @"listHeight":@(kGeomHeightStripListRow+2*kGeomSpaceInter), @"buttonWidth":@(kGeomDimensionsIconButton)};
    
    UIView *superview = self.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(superview, _textView, _postButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_textView(>=60)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spaceEdge-[_postButton(30)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spaceEdge-[_textView]-[_postButton(50)]-spaceEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
}


@end
