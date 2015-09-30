//
//  Common.m: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <sys/types.h>
#import <sys/sysctl.h>

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

NSString* trimString(NSString* s)
{
    if (!s) {
        return  @"";
    }
    return [s stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
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

UITableView* makeTable (UIView *parent,id  delegate)
{
    UITableView* tv= [ [ UITableView alloc ]init ];
    if  (tv ) {
        [ parent addSubview: tv ];
    }
    tv.delegate= delegate;
    tv.dataSource= delegate;
    return tv;
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

UIWebView* makeWebView (UIView*parent, id  delegate)
{
    UIWebView *v= [ UIWebView  new];
    v.delegate=  delegate;
    [parent addSubview: v];
    return v;
}

UITextView* makeTextView (UIView*parent, UIColor *bg,BOOL  editable)
{
    UITextView *textView= [ UITextView  new];
    textView.editable= editable;
    textView.backgroundColor= bg;
    [parent addSubview: textView];
    return textView;
}

UIButton* makeAttributedButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    UIButton* button= [ UIButton buttonWithType:  UIButtonTypeCustom];
    if  (title ) {
        NSAttributedString* a= [[NSAttributedString alloc] initWithString:title];
        [ button setAttributedTitle: a forState:UIControlStateNormal ];
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

NSAttributedString* attributedStringOf(NSString* string,double fontSize)
{
    NSAttributedString* a= [[NSAttributedString alloc]
                            initWithString:string ?: @""
                            attributes: @{
                                          NSFontAttributeName:
                                              [UIFont fontWithName: kFontLatoRegular size:fontSize]
                                          }];
    return a;
}

NSAttributedString* underlinedAttributedStringOf(NSString*string,double fontSize)
{
    NSAttributedString* a= [[NSAttributedString alloc]
                            initWithString:string ?: @""
                            attributes: @{
                                          NSUnderlineStyleAttributeName: @(NSUnderlineStyleThick),
                                          
                                          NSFontAttributeName:
                                              [UIFont fontWithName: kFontLatoRegular size:fontSize]
                                          }];
    return a;
}

NSString * platformString()
{
    int mib[2];
    char *machine;
    size_t length;
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl (mib, 2, NULL, &length, NULL, 0);
    machine = malloc(length+1);
    sysctl (mib, 2, machine, &length, NULL, 0);
    NSString *platform = [NSString stringWithCString: machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}
