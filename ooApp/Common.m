//
//  Common.m: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

//NSString*const kOOURL= @"www.oomamiapp.com/api/v1";
NSString*const kOOURL= @"stage.oomamiapp.com/api/v1";

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

UIButton* makeButton (UIView *parent, NSString*  title,  UIColor *fg, UIColor *bg, id  target, SEL callback)
{
    UIButton* button= [ UIButton buttonWithType:  UIButtonTypeCustom];
    if  (title ) {
        [ button setTitle: title forState:UIControlStateNormal ];
    }
    if ( target && callback) {
        [ button addTarget: target action: callback forControlEvents:UIControlEventTouchUpInside ];
    }
    if  (fg ) {
        [button setTitleColor:fg forState:UIControlStateNormal];
    }
    if  (bg ) {
        button.layer.backgroundColor= bg.CGColor;
    }
    [ parent addSubview: button ];
    return button;
}