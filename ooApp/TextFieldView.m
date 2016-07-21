 //
//  TextFieldView.m
//  ooApp
//
//  Created by James Rochabrun on 21-07-16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "TextFieldView.h"
#import "UIButton+Additions.h"
#import "CommonUIConstants.h"

@interface TextFieldView ()
@property UITextField *textField;
@property UIButton *postTextButton;

@end

@implementation TextFieldView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _textField = [UITextField new];
        _postTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_postTextButton withText:@"" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorTextActive target:self selector:@selector(test)];
        _postTextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_textField];
        [self addSubview:_postTextButton];

    }
    return self;
}

- (void)test {
    NSLog(@"this works");
}

- (void)layoutSubviews {
    
    CGRect frame = _textField.frame;
    CGFloat viewCenterY = CGRectGetMidY(self.frame);
    
    frame.size.width = width(self) - width(_postTextButton);
    frame.size.height = kGeomHeightTextField;
    frame.origin.x = kGeomSpaceEdge;
    [_textField setCenter:CGPointMake(frame.origin.x, viewCenterY)];
    _textField.frame = frame;
    
    frame = _postTextButton.frame;
    frame.size.width = kGeomWidthButton;
    frame.size.height = kGeomHeightTextField;
    frame.origin.x = CGRectGetMaxX(_textField.frame);
    [_postTextButton setCenter:CGPointMake(frame.origin.x, viewCenterY)];
    
    
}

@end








