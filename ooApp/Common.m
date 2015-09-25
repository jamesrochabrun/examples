//
//  Common.m: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

//NSString *const kOOURL= @"www.oomamiapp.com/api/v1";
NSString *const kOOURL= @"stage.oomamiapp.com/api/v1";

void message (NSString *str)
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: str
				message:nil
				delegate: nil
				cancelButtonTitle: @"OK" otherButtonTitles: nil ];
    [alert show];
}

NSString *getDateString()
{
    struct tm tm;
    timelocal(&tm);
    int year= tm.tm_year;
    int month= tm.tm_mon;
    int day= 1 + tm.tm_mday;
    return [NSString stringWithFormat: @"%04d/%02d/%02d",year,month,day];
}

UIImageView* makeImageView (UIView *parent, NSString* imageName)
{
    UIImage* image= imageName? [ UIImage imageNamed:imageName] :nil;
    UIImageView* iv= [ [UIImageView alloc ]initWithImage:  image  ];
    [ parent addSubview: iv ];
    return iv;
}

UILabel* makeLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [ [ UILabel alloc ]init ];
    [ parent addSubview: l ];
    l.textAlignment= NSTextAlignmentCenter;
    l.text=  text;
    l.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    return l;
}

UILabel* makeIconLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [ [ UILabel alloc ]init ];
    [ parent addSubview: l ];
    l.textAlignment= NSTextAlignmentCenter;
    l.text=  text;
    l.font= [UIFont fontWithName:@"oomami-icons" size: fontSize];
    return l;
}

UILabel* makeLabelLeft (UIView *parent, NSString*  text, float fontSize)
{
    UILabel *l= makeLabel( parent, text,fontSize);
    l.textAlignment= NSTextAlignmentLeft;
    return l;
}

UITextView* makeTextView (UIView*parent, UIColor *bg,BOOL  editable)
{
    UITextView *textView= [ UITextView  new];
    textView.editable= editable;
    textView.backgroundColor= bg;
    [parent addSubview: textView];
    return textView;
}

UIButton* makeButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    UIButton* button= [ UIButton buttonWithType:  UIButtonTypeCustom];
    if  (title ) {
        [ button setTitle: title forState:UIControlStateNormal ];
        button.titleLabel.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    }
    if ( target && callback) {
        [ button addTarget: target action: callback forControlEvents:UIControlEventTouchUpInside ];
    }
    if  (fg ) {
        [button setTitleColor:fg forState:UIControlStateNormal];
        if (borderWidth > 0 ) {
            button.layer.borderColor=fg.CGColor;
            button.layer.borderWidth= borderWidth;
            button.layer.cornerRadius= kGeomCornerRadius;
        }
    }
    if  (bg ) {
        button.layer.backgroundColor= bg.CGColor;
    }
    [ parent addSubview: button ];
    return button;
}