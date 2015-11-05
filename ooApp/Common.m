//
//  Common.m: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <sys/types.h>
#import <sys/sysctl.h>
#import "UIImageView+AFNetworking.h"
#import "UserObject.h"
#import "AppDelegate.h"

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

void message2 (NSString *str, NSString*string)
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: str
                                                     message:string
                                                    delegate: nil
                                           cancelButtonTitle: @"OK" otherButtonTitles: nil ];
    [alert show];
}

NSString *getDateString()
{
    time_t t = time (NULL);
    struct tm *tm = localtime (&t);
    int year= 1900 + tm->tm_year;
    int month= 1 + tm->tm_mon;
    int day= tm->tm_mday;
    return [NSString stringWithFormat: @"%04d/%02d/%02d",year,month,day];
}

NSString* trimString(NSString* s)
{
    if (!s) {
        return  @"";
    }
    return [s stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

UIImageView* makeImageViewFromURL (UIView *parent,NSString* urlString, NSString* placeholderImageName)
{
    NSURL *url= [ NSURL  URLWithString:urlString];
    UIImageView* iv= nil;
    UIImage* image=nil;
    if ( !url) {
        // RULE:  if the URL is bad just go with the placeholder.
        image= [ UIImage imageNamed:placeholderImageName];
        iv= [ [UIImageView alloc ]initWithImage:  image  ];
    } else {
        image= [ UIImage imageNamed:placeholderImageName];
        iv= [ [UIImageView alloc ]initWithImage:image];
        [iv setImageWithURL:url placeholderImage:image];
    }

    [ parent addSubview: iv ];
    return iv;
}

UIImageView* makeImageView (UIView *parent, id image_)
{
    BOOL imageIsURL= NO;
    NSURL *url= nil;
    UIImage* image=nil;
    if ([image_ isKindOfClass:[UIImage class  ] ]) {
        image=  image_;
    }
    else if([image_ isKindOfClass:[NSString class   ]] ){
        imageIsURL= [[image_ lowercaseString] hasPrefix: @"http"];
        url= imageIsURL? [ NSURL  URLWithString:image_] : nil;
        if ( !imageIsURL) {
            image= [ UIImage imageNamed:image_];
        }
    }
    UIImageView* iv= [ [UIImageView alloc ]initWithImage:  image  ];
    if  ( imageIsURL && url) {
        [iv setImageWithURL:url placeholderImage:nil];
    }
    [ parent addSubview: iv ];
    return iv;
}

NSMutableArray* makeImageViewsForUsers (UIView *parent, NSMutableOrderedSet*users, NSUInteger  maximum)
{
    NSMutableArray* array= [NSMutableArray new];
    NSUInteger i= 0;
    for (UserObject* user  in  users) {
        UIImage *silhouette=APP.imageForNoProfileSilhouette;// XX:  need to make a smaller copy of the silhouette.
        UIImageView* iv=  makeImageView(parent, user.imageURLString.length ? user.imageURLString :  silhouette);
        iv.backgroundColor= WHITE;
        iv.layer.cornerRadius=  kGeomFaceBubbleDiameter/2;
        iv.clipsToBounds= YES;
        iv.frame = CGRectMake(0,0, kGeomFaceBubbleDiameter, kGeomFaceBubbleDiameter);
        iv.layer.borderColor= GREEN.CGColor;
        iv.layer.borderWidth= 1;
        [array addObject: iv];
        i++;
        if  (i>=  maximum ) {
            break;
        }
    }
    return array;
}

UILabel* makeAttributedLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [ [ UILabel alloc ]init ];
    [ parent addSubview: l ];
    l.numberOfLines= 0;
    l.textAlignment= NSTextAlignmentCenter;
    l.attributedText= attributedStringOf(text, fontSize) ;

    return l;
}

UILabel* makeLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [ [ UILabel alloc ]init ];
    [ parent addSubview: l ];
    l.numberOfLines= 0;
    l.textAlignment= NSTextAlignmentCenter;
    l.text=  text;
    if ( fontSize >0) {
        l.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    }
    l.lineBreakMode= NSLineBreakByWordWrapping;
    return l;
}

UIView* makeView (UIView *parent, UIColor* backgroundColor)
{
    UIView* v = [ [ UIView alloc ]init ];
    [ parent addSubview: v];
    v.backgroundColor= backgroundColor;
    return v;
}

UITableView* makeTable (UIView *parent,id  delegate)
{
    UITableView* tv= [ [ UITableView alloc ]init ];
    if  (tv) {
        [ parent addSubview: tv ];
    }
    tv.delegate= delegate;
    tv.dataSource= delegate;
    if([tv respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
        tv.cellLayoutMarginsFollowReadableWidth = NO;
    return tv;
}

UILabel* makeIconLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [ [ UILabel alloc ]init ];
    [ parent addSubview: l ];
    l.textAlignment= NSTextAlignmentCenter;
    l.text=  text;
    l.font= [UIFont fontWithName:kFontIcons size: fontSize];
    return l;
}

UILabel* makeLabelLeft (UIView *parent, NSString*  text, float fontSize)
{
    UILabel *l= makeLabel( parent, text,fontSize);
    l.textAlignment= NSTextAlignmentLeft;
    return l;
}

UIScrollView* makeScrollView (UIView*parent, id  delegate)
{
    UIScrollView *v= [ UIScrollView  new];
    v.delegate=  delegate;
    [parent addSubview: v];
    return v;
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

UIButton* makeIconButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    fontSize=kGeomIconSize;
    UIButton* button= [ UIButton buttonWithType:  UIButtonTypeCustom];
    if  (title ) {
        [ button setTitle: title forState:UIControlStateNormal ];
        button.titleLabel.font= [UIFont fontWithName: kFontIcons size:fontSize];
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

UIButton* makeButtonForAutolayout (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    UIButton* button= [ UIButton buttonWithType:  UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;

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

UIButton* makeRoundButton(UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius)
{
    UIButton*b= makeButton(parent, title, fontSize, fg, bg, target, callback, borderWidth);
    b.layer.cornerRadius=  radius;
    return b;
}

UIButton* makeRoundIconButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius)
{
    UIButton*b= makeIconButton(parent, title, fontSize, fg, bg, target, callback, borderWidth);
    b.layer.cornerRadius=  radius;
    return b;
}

UIButton* makeRoundIconButtonForAutolayout(UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius)
{
    UIButton*b= makeButtonForAutolayout(parent, title, fontSize, fg, bg, target, callback, borderWidth);
    b.titleLabel.font= [UIFont fontWithName: kFontIcons size:fontSize];
    b.layer.cornerRadius=  radius;
    return b;
}

void addShadowTo (UIView*v)
{
    v.opaque= YES;
    v.layer.shadowOffset= CGSizeMake ( 2, 2);
    v.layer.shadowColor= BLACK.CGColor;
    v.layer.shadowOpacity= .5;
    v.layer.shadowRadius= 4;
    v.clipsToBounds= NO;
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

NSDate* parseUTCDateFromServer(NSString *string)
{
    if  (!string) {
        return nil;
    }
    if  ([string isKindOfClass:[NSDate class]]) {
        return  (NSDate*)string;
    }
    if  (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString* temp= [string stringByReplacingOccurrencesOfString: @"T" withString: @" "];
    temp= [ temp stringByReplacingOccurrencesOfString: @"Z" withString: @""];
    temp= [ temp stringByReplacingOccurrencesOfString: @"  " withString: @" "];
    temp= [ temp stringByReplacingOccurrencesOfString: @".000" withString: @""];
    temp= trimString( temp);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:   temp];
    return date;
}

NSUInteger parseUnsignedIntegerOrNullFromServer (id object)
{
    if  (object && [ object isKindOfClass:[NSNumber class]]) {
        return  (( NSNumber*)object).unsignedIntegerValue;
    }
    if  (object && [ object isKindOfClass:[NSString class]]) {
        return (NSUInteger) (( NSString*)object).integerValue;
    }
    return 0;
}

NSInteger parseIntegerOrNullFromServer (id object)
{
    if  (object && [ object isKindOfClass:[NSNumber class]]) {
        return  (( NSNumber*)object).integerValue;
    }
    if  (object && [ object isKindOfClass:[NSString class]]) {
        return  (( NSString*)object).integerValue;
    }
    return 0;
}

double parseNumberOrNullFromServer (id object)
{
    if  (object && [ object isKindOfClass:[NSNumber class]]) {
        return  (( NSNumber*)object).doubleValue;
    }
    if  (object && [ object isKindOfClass:[NSString class]]) {
        return  (( NSString*)object).doubleValue;
    }
    return 0;
}

NSString* parseStringOrNullFromServer (id object)
{
    if  (object && [ object isKindOfClass:[NSString class]]) {
        return  (NSString*)object;
    }
    return nil;
}

NSMutableAttributedString *createPeopleIconString (NSInteger count)
{
    NSString *iconicRepresentationOfNumberOfPeople= [NSString stringWithFormat: @"%@",kFontIconPerson ];
    NSAttributedString *countString= attributedStringOf([NSString stringWithFormat: @"%lu ",
                                                         ( unsigned long)  count], kGeomFontSizeHeader);
    NSAttributedString *iconString= [[NSAttributedString alloc]
                                     initWithString: iconicRepresentationOfNumberOfPeople
                                     attributes: @{
                                                   NSFontAttributeName: [UIFont fontWithName: kFontIcons size:kGeomPeopleIconFontSize]
                                                   }];
    NSMutableAttributedString* a= [[NSMutableAttributedString  alloc] initWithAttributedString:countString];
    [a appendAttributedString:iconString];
    return a;
}

NSString* expressLocalDateTime(NSDate* date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, h:mmaa";
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:gmt];
    NSString *string = [dateFormatter stringFromDate: date];
    return string;
}

NSString* expressLocalTime(NSDate* date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mmaa";
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:gmt];
    NSString *string = [dateFormatter stringFromDate: date];
    return string;
}

NSInteger getLocalHour (NSDate* date)
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitHour fromDate: date];
    [dateComponents  setTimeZone:gmt];
    NSInteger n = [dateComponents hour];
    return n;
}

NSInteger getLocalDayOfMonth (NSDate* date)
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitDay fromDate: date];
    [dateComponents  setTimeZone:gmt];
    NSInteger n = [dateComponents day];
    return n;
}

NSInteger getLocalDayNumber(NSDate* date)
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitWeekday fromDate: date];
    [dateComponents  setTimeZone:gmt];
    NSInteger n = [dateComponents weekday]-1;
    return n;
}

NSString* expressLocalMonth(NSDate* date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM";
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:gmt];
    NSString *string = [dateFormatter stringFromDate: date];
    return string;
}

BOOL isValidEmailAddress (NSString *string)
{
    if  (!string) {
        return NO;
    }
    
    if ([string hasPrefix: @"@"] || [string hasSuffix: @"@"] || [string hasSuffix: @"."]) {
        return NO;
    }
    
    if  (string.length < 6 ) {
        return NO;
    }

    NSArray *a = [string componentsSeparatedByString:@"@"];
    if (a.count != 2 ) {
        return NO;
    }
    NSString *second= a[1];
    if  (![second containsString: @"."]) {
        return NO;
    }
    
    return YES;
}

unsigned long msTime (void)
{
    struct timeval t;
    gettimeofday (&t, NULL);
    unsigned long ms = (t.tv_sec  * 1000) + (t.tv_usec / 1000);
    return ms;
}
