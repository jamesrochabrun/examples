//
//  OOFilterView.m
//  ooApp
//
//  Created by Anuj Gujar on 10/6/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOFilterView.h"
#import "FilterObject.h"

@interface OOFilterView()

@property (nonatomic, strong) NSMutableArray *filterControls;
@property (nonatomic, strong) NSMutableArray *filters;
@property (nonatomic) NSUInteger current;
@property (nonatomic, strong) UIView *currentLine;

@end

@implementation OOFilterView

- (instancetype)init {
    self = [super init];
    if (self) {
        _filterControls = [NSMutableArray array];
        _filters = [NSMutableArray array];
        _currentLine = [[UIView alloc] init];
        _currentLine.backgroundColor = UIColorRGBA(kColorYellow);
        [self addSubview:_currentLine];
        self.backgroundColor = UIColorRGBA(kColorOffWhite);
    }
    return  self;
}

- (void)filterPressed:(id)sender {
    UIButton *b = (UIButton *)sender;
    NSLog(@"filter pressed");
    
    FilterObject *fo = [_filters objectAtIndex:b.tag];
    [fo.target performSelectorOnMainThread:fo.selector withObject:nil waitUntilDone:NO];
    
    CGRect frame = _currentLine.frame;
    frame.origin.x = b.frame.origin.x + (CGRectGetWidth(b.frame) - CGRectGetWidth(frame))/2;
    [UIView animateWithDuration:0.2 animations:^{
        _currentLine.frame = frame;
    }];

}

- (void)addFilter:(NSString *)name target:(id)target selector:(SEL)selector {

    //NOTE: not sure we need filter objects
    FilterObject *fo = [[FilterObject alloc] init];
    fo.name = name;
    fo.selector = selector;
    fo.target = target;
    [_filters addObject:fo];
    
    UIButton *filterControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterControl withText:name fontSize:kGeomFontSizeSubheader width:0 height:0 backgroundColor:kColorClear target:self selector:@selector(filterPressed:)];
    filterControl.tag = [_filterControls count];
    [_filterControls addObject:filterControl];
    
    [self addSubview:filterControl];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.frame;
    __block CGRect bFrame;

    CGSize filterSize = CGSizeMake(CGRectGetWidth(frame)/[_filterControls count], CGRectGetHeight(frame));
    [_filterControls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *b = (UIButton *)obj;
        bFrame = b.frame;
        bFrame.size = filterSize;
        bFrame.origin.y = (CGRectGetHeight(frame) - filterSize.height)/2;
        bFrame.origin.x = idx*filterSize.width;
        b.frame = bFrame;
    }];
    
    CGRect lineFrame = _currentLine.frame;
    lineFrame.size.height = 2;
    lineFrame.size.width = filterSize.width *0.7;
    lineFrame.origin.y = CGRectGetHeight(frame) - 5;
    lineFrame.origin.x = (CGRectGetWidth(bFrame) - CGRectGetWidth(lineFrame))/2;
    _currentLine.frame = lineFrame;
}

- (void)selectFilter:(NSUInteger)which {
    UIButton *b = (UIButton *)[_filterControls objectAtIndex:which];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end