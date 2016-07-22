//
//  TextFieldView.m
//  test1
//
//  Created by James Rochabrun on 21-07-16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import "TextFieldView.h"


@interface TextFieldView ()


@end

@implementation TextFieldView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _textField = [UITextField new];
        _postTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    NSLog(@"the height of the view is %f", h);
    
    frame = _textField.frame;
    frame.size.width = w * 0.7 - margin;
    frame.size.height = 44;
    frame.origin.x = margin;
    frame.origin.y = (h - _textField.bounds.size.height)/2 ;
    _textField.frame = frame;

    frame = _postTextButton.frame;
    frame.size.width = w * 0.3 - margin * 2;
    frame.size.height = 44;
    frame.origin.x = CGRectGetMaxX(_textField.frame) + margin;
    frame.origin.y = _textField.frame.origin.y;
    _postTextButton.frame = frame;
   
    _textField.backgroundColor = [UIColor redColor];
    _postTextButton.backgroundColor = [UIColor blueColor];
 
    
    
    

    
    
}

@end
