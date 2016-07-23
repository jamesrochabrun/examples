//
//  TextFieldView.m
//  test1
//
//  Created by James Rochabrun on 21-07-16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import "TextFieldView.h"
#import "CommonUIConstants.h"


@interface TextFieldView ()


@end

@implementation TextFieldView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _textField = [UITextField new];
        _postTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_postTextButton withText:@"SEND" fontSize:kGeomFontSizeH3 width:0 height:0 backgroundColor:kColorTextActive target:self selector:@selector(test)];
               [self addSubview:_postTextButton];
        
        [self addSubview:_textField];
        
    }
    return self;
}

- (void)test {
    NSLog(@"this works");
}

- (void)layoutSubviews {
    
    CGRect frame = self.frame;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    CGFloat margin = 8;
    
    frame = _textField.frame;
    frame.size.width = w * 0.7 - margin;
    frame.size.height = kGeomIconSize;
    frame.origin.x = margin;
    frame.origin.y = (h - _textField.bounds.size.height)/2 ;
    _textField.frame = frame;
    _textField.backgroundColor = [UIColor whiteColor];

    frame = _postTextButton.frame;
    frame.size.width = w * 0.3 - margin * 2;
    frame.size.height = kGeomIconSize;
    frame.origin.x = CGRectGetMaxX(_textField.frame) + margin;
    frame.origin.y = (h - _postTextButton.frame.size.height)/2;
    _postTextButton.frame = frame;
   

}





@end
