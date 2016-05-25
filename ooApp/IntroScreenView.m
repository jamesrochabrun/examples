//
//  IntroScreenView.m
//  ooApp
//
//  Created by Anuj Gujar on 3/23/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "IntroScreenView.h"
#import "DebugUtilities.h"
#import "UILabel+Additions.h"

//#define kIntroViewPhoneImageHeight 363

//#define kIntroViewiPadImageWidth 694
//#define kIntroViewiPadImageHeight 454

@interface IntroScreenView ()
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImageView *phoneImage;
@property (nonatomic, strong) UILabel *title;
@end

@implementation IntroScreenView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = UIColorRGBA(kColorClear);
        
        _backgroundImage = [UIImageView new];
        _backgroundImage.backgroundColor = UIColorRGBA(kColorClear);
        _backgroundImage.contentMode = UIViewContentModeScaleAspectFill;

        self.backgroundColor = UIColorRGBA(kColorClear);
        
        _phoneImage = [UIImageView new];
        _phoneImage.backgroundColor = UIColorRGBA(kColorClear);
        _phoneImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_phoneImage];
        
        _title = [UILabel new];
        [_title withFont:[UIFont fontWithName:kFontLatoRegular size:kGeomFontSizeH5] textColor:kColorTextReverse backgroundColor:kColorClear numberOfLines:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter];
        [self addSubview:_title];        
    }
    
    //[DebugUtilities addBorderToViews:@[_phoneImage]];
    return self;
}

- (void)setIntroTitle:(NSString *)introTitle {
    if (_introTitle == introTitle) return;
    _introTitle = introTitle;
    //_title.text = _introTitle;
    [self formatHeader];
}

- (void)setIntroDescription:(NSString *)introDescription {
    if (_introDescription == introDescription) return;
    _introDescription = introDescription;
    //_title.text = _introTitle;
    [self formatHeader];
}

- (void)setUnderlinedWords:(NSArray *)underlinedWords {
    if (_underlinedWords == underlinedWords) return;
    _underlinedWords = underlinedWords;
    //_title.text = _introTitle;
    [self formatHeader];
}

- (void)formatHeader {
    NSDictionary *titleAttributes = @{
        NSFontAttributeName:[UIFont fontWithName:kFontLatoBold size:(IS_IPHONE4) ? kGeomFontSizeH1 : kGeomFontSizeBig]
        };
    
    NSDictionary *descriptionAttributes = @{
                                            NSFontAttributeName:[UIFont fontWithName:kFontLatoRegular size:(IS_IPHONE4) ? kGeomFontSizeH2 : kGeomFontSizeH1]
        };

    NSDictionary *underlineAttributes =  @{
        NSFontAttributeName:[UIFont fontWithName:kFontLatoRegular size:(IS_IPHONE4) ? kGeomFontSizeH2 : kGeomFontSizeH1],
        NSUnderlineStyleAttributeName:@(NSUnderlineStyleThick),
        NSUnderlineColorAttributeName:UIColorRGBA(kColorTextActive)
        };

    NSString *s = [NSString stringWithFormat:@"%@ %@", _introTitle, _introDescription];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:s];
    
    NSRange r;
    if (_introTitle) {
        r = [s rangeOfString:_introTitle];
        [as setAttributes:titleAttributes range:r];
    }

    if (_introDescription) {
        r = [s rangeOfString:_introDescription];
        [as setAttributes:descriptionAttributes range:r];
    }

    for (NSString *u in _underlinedWords) {
        r = [s rangeOfString:u];
        if (r.length != NSNotFound) {
            [as setAttributes:underlineAttributes range:r];
        }
    }

    _title.attributedText = as;
    
    [self setNeedsLayout];
}

- (void)setBackgroundImageURL:(NSString *)backgroundImageURL {
    [_backgroundImage setImage:[UIImage imageNamed:backgroundImageURL]];
}

- (void)setPhoneImageURL:(NSString *)phoneImageURL {
    [_phoneImage setImage:[UIImage imageNamed:phoneImageURL]];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = windowWidth();
    CGFloat h = height(self);
    CGFloat imageWidth = w*5/6;
    CGFloat imageY = h*1/3;
    CGFloat imageHeight = 0;
    
    if (_phoneImage.image) {
        imageHeight = _phoneImage.image.size.height/_phoneImage.image.size.width*imageWidth;
    }
    
    CGRect frame;

    frame = _backgroundImage.frame;
    frame.size = self.frame.size;
    _backgroundImage.frame = frame;
    
    CGSize s = [_title sizeThatFits:CGSizeMake(imageWidth, 200)];
    frame = _title.frame;
    frame.size = s;
    _title.frame = frame;
    
    frame.origin = CGPointMake((self.frame.size.width - _title.frame.size.width)/2, (imageY-CGRectGetHeight(frame))/2);
    
    _title.frame = frame;
    
    frame = _phoneImage.frame;
    
    frame.origin = CGPointMake((self.frame.size.width - imageWidth)/2, imageY);
    frame.size = CGSizeMake(imageWidth, imageHeight);
    
    _phoneImage.frame = frame;

//    [DebugUtilities addBorderToViews:[NSArray arrayWithObject:self]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
