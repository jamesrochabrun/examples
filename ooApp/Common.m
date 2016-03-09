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
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>

NSString *const kNotificationLocationBecameAvailable = @"notificationLocationAvailable";
NSString *const kNotificationLocationBecameUnavailable = @"notificationLocationUnavailable";

NSString *const kOOURLStage = @"stage.oomamiapp.com/v1";
NSString *const kOOURLProduction = @"api.oomamiapp.com/v1";

//NSString *const kOOURL = @"localhost:3000/api/v1";
NSString *const kHTTPProtocol = @"https";

void message (NSString *str)
{
    messageWithTitle (str,nil);
}

void messageWithTitle (NSString *title, NSString*string)
{
    messageWithTitleAndCompletionBlock(title, string, NULL, NO);
}

void messageWithTitleAndCompletionBlock (NSString *title, NSString*string, void (^block)(BOOL result),
                                         BOOL showCancel)
{
    UIAlertController *a= [UIAlertController alertControllerWithTitle: title ?: @""
                                                              message:string
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = nil;
    if (showCancel)
        cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                          style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                              if (block) block(NO);
                                          }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style: UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     if (block) block(YES);
                                                 }];
    
    if (showCancel)
        [a addAction:cancel];
    [a addAction:ok];
    
    [[UIApplication sharedApplication].windows[0].rootViewController.childViewControllers.lastObject presentViewController:a animated:YES completion:nil];
}

NSString *concatenateStrings(NSString*a,NSString*b)
{
    return [NSString  stringWithFormat: @"%@%@",a,b];
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

NSString *stringFromUnsigned(NSUInteger value)
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)value];
}

NSString *trimString(NSString *s)
{
    if (!s) {
        return @"";
    }
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

void addBorder (UIView*v, float width, UIColor *color)
{
    if (!color) {
        color= UIColorRGBA(kColorWhite);
    }
    v.layer.borderColor= color.CGColor;
    v.layer.borderWidth= width;
}

UIImageView *makeImageViewFromURL(UIView *parent, NSString *urlString, NSString *placeholderImageName)
{
    NSURL *url= [NSURL  URLWithString:urlString];
    UIImageView *iv= nil;
    UIImage *image=nil;
    if ( !url) {
        // RULE:  if the URL is bad just go with the placeholder.
        image = [UIImage imageNamed:placeholderImageName];
        iv = [[UIImageView alloc] initWithImage:image];
    } else {
        image = [UIImage imageNamed:placeholderImageName];
        iv = [[UIImageView alloc] initWithImage:image];
        [iv setImageWithURL:url placeholderImage:image];
    }
    
    [parent addSubview:iv];
    return iv;
}

UIButton *makeProfileImageButton (UIView *parent,UserObject* user,id delegate,SEL callback)
{
    UIButton* b= makeButton( parent, nil, 0, UIColorRGBA(kColorWhite), UIColorRGBA(kColorClear),  delegate,  callback, 1);
    b.tag=  user.userID;
    [b setImage:APP.imageForNoProfileSilhouette forState:UIControlStateNormal];
    b.layer.cornerRadius=kGeomFaceBubbleDiameter/2;
    b.clipsToBounds= YES;
    b.layer.borderColor= UIColorRGBA(kColorWhite).CGColor;

    if ( user.imageIdentifier && user.imageIdentifier.length) {
        
        /*self.requestOperation =*/
        [OOAPI getUserImageWithImageID: user.imageIdentifier
                              maxWidth: kGeomFaceBubbleDiameter
                             maxHeight: 0
                               success: ^(NSString *link)  {
                                   NSURL *url= [NSURL URLWithString: link];
                                   if  (url) {
                                       NSURLRequest *r= [NSURLRequest requestWithURL:url];
                                       __weak UIButton *weakButton = b;
                                       [b.imageView setImageWithURLRequest:r
                                                          placeholderImage:APP.imageForNoProfileSilhouette
                                                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                                                       ON_MAIN_THREAD( ^{
                                                                           [weakButton setImage:image forState:UIControlStateNormal];
                                                                       });
                                                                       
                                                                   } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                                                       ;
                                                                   }];
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               }];
    }
    else if (user.facebookProfileImageURLString  && user.facebookProfileImageURLString.length) {//  Facebook photo
        NSURL *url= [NSURL URLWithString: user.facebookProfileImageURLString];
        if  ( url) {
            NSURLRequest*r= [NSURLRequest requestWithURL:url];
            __weak UIButton *weakButton = b;
            [b.imageView setImageWithURLRequest:r
                               placeholderImage:APP.imageForNoProfileSilhouette
                                        success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                            ON_MAIN_THREAD( ^{
                                                [weakButton setImage:image forState:UIControlStateNormal];
                                            });
                                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                            ;
                                        }];
        }
    }
    
    return b;
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
        url= imageIsURL? [NSURL  URLWithString:image_] : nil;
        if ( !imageIsURL) {
            image= [UIImage imageNamed:image_];
        }
    }
    UIImageView* iv= [[UIImageView alloc ]initWithImage:  image  ];
    if  ( imageIsURL && url) {
        [iv setImageWithURL:url placeholderImage:nil];
    }
    [parent addSubview: iv ];
    
    iv.contentMode= UIViewContentModeScaleAspectFill;
    iv.clipsToBounds= YES;
    return iv;
}

UILabel* makeAttributedLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [[ UILabel alloc ]init ];
    [parent addSubview: l ];
    l.numberOfLines= 0;
    l.textAlignment= NSTextAlignmentCenter;
    if (text)
        l.attributedText= attributedStringOf(text, fontSize) ;
    
    return l;
}

UILabel* makeAttributedLabelWithColor (UIView *parent, NSString*  text, float fontSize,UIColor*color)
{
    UILabel* l= [[ UILabel alloc ]init ];
    [parent addSubview: l ];
    l.numberOfLines= 0;
    l.textAlignment= NSTextAlignmentCenter;
    if (text)
        l.attributedText= attributedStringWithColorOf(text, fontSize,color) ;
    
    return l;
}

UILabel* makeLabel (UIView *parent, NSString*  text, float fontSize)
{
    UILabel* l= [[ UILabel alloc ]init ];
    [parent addSubview: l ];
    l.numberOfLines= 0;
    l.textAlignment= NSTextAlignmentCenter;
    l.text=  text;
    if ( fontSize >0) {
        l.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    }
    l.lineBreakMode= NSLineBreakByWordWrapping;
    l.clipsToBounds= NO;
    return l;
}

UIView* makeView (UIView *parent, UIColor* backgroundColor)
{
    UIView* v = [[ UIView alloc ]init ];
    [parent addSubview: v];
    v.backgroundColor= backgroundColor;
    return v;
}

UICollectionView* makeCollectionView (UIView *parent,id  delegate, UICollectionViewLayout* layout)
{
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout: layout];
    cv.delegate = delegate;
    cv.dataSource = delegate;
    cv.showsHorizontalScrollIndicator = NO;
    cv.showsVerticalScrollIndicator = NO;
    cv.alwaysBounceHorizontal = NO;
    cv.allowsSelection = YES;
    cv.backgroundColor= UIColorRGBA(kColorClear);
    [parent addSubview: cv];
    return cv;
}

UICollectionView* makeHorizontalCollectionView (UIView *parent,id  delegate, CGSize itemSize)
{
    UICollectionViewFlowLayout *cvLayout= [[UICollectionViewFlowLayout alloc] init];
    cvLayout.itemSize = itemSize;
    cvLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    cvLayout.minimumInteritemSpacing = 5;
    cvLayout.minimumLineSpacing = 3;
    return makeCollectionView(parent,delegate,cvLayout);
}

UICollectionView* makeVerticalCollectionView (UIView *parent,id  delegate, CGSize itemSize)
{
    UICollectionViewFlowLayout *cvLayout= [[UICollectionViewFlowLayout alloc] init];
    cvLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    cvLayout.itemSize = itemSize;
    cvLayout.minimumInteritemSpacing = 5;
    cvLayout.minimumLineSpacing = 3;
    cvLayout.sectionHeadersPinToVisibleBounds= YES;

    return makeCollectionView(parent,delegate,cvLayout);
}

UITableView* makeTable (UIView *parent,id  delegate)
{
    UITableView* tv= [[ UITableView alloc ]init ];
    if  (tv) {
        [parent addSubview: tv ];
    }
    tv.delegate= delegate;
    tv.dataSource= delegate;
    tv.separatorStyle= UITableViewCellSeparatorStyleNone;
    if([tv respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
        tv.cellLayoutMarginsFollowReadableWidth = NO;
    return tv;
}

UILabel *makeIconLabel(UIView *parent, NSString *text, float fontSize)
{
    UILabel* l= [[ UILabel alloc ]init ];
    [parent addSubview: l ];
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

UIWebView *makeWebView(UIView *parent, id delegate)
{
    UIWebView *v= [UIWebView new];
    v.delegate = delegate;
    [parent addSubview:v];
    return v;
}

UITextView *makeTextView(UIView *parent, UIColor *bg, BOOL editable)
{
    UITextView *textView= [UITextView  new];
    textView.editable= editable;
    textView.backgroundColor= bg;
    [parent addSubview: textView];
    return textView;
}

UIButton *makeAttributedButton (UIView *parent, NSString *title, float fontSize, UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
    if (title) {
        NSAttributedString* a= [[NSAttributedString alloc] initWithString:title];
        [button setAttributedTitle: a forState:UIControlStateNormal ];
        button.titleLabel.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    }
    if ( target && callback) {
        [button addTarget: target action: callback forControlEvents:UIControlEventTouchUpInside ];
    }
    if  (fg ) {
        [button setTitleColor:fg forState:UIControlStateNormal];
        if (borderWidth > 0 ) {
            button.layer.borderColor=fg.CGColor;
            button.layer.borderWidth= borderWidth;
            button.layer.cornerRadius= kGeomCornerRadius;
        }
    }
    if (bg) {
        button.layer.backgroundColor = bg.CGColor;
    }
    [parent addSubview:button];
    return button;
}

UIButton* makeIconButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    fontSize=kGeomIconSize;
    UIButton* button= [UIButton buttonWithType:  UIButtonTypeCustom];
    if  (title ) {
        [button setTitle: title forState:UIControlStateNormal ];
        button.titleLabel.font= [UIFont fontWithName: kFontIcons size:fontSize];
    }
    if ( target && callback) {
        [button addTarget: target action: callback forControlEvents:UIControlEventTouchUpInside ];
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
    [parent addSubview: button ];
    return button;
}

UIButton* makeButtonForAutolayout (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    UIButton* button= [UIButton buttonWithType:  UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;

    if  (title ) {
        [button setTitle: title forState:UIControlStateNormal ];
        button.titleLabel.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    }
    if ( target && callback) {
        [button addTarget: target action: callback forControlEvents:UIControlEventTouchUpInside ];
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
    [parent addSubview: button ];
    return button;
}

UIButton* makeButton (UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth)
{
    UIButton* button= [UIButton buttonWithType:  UIButtonTypeCustom];
    if  (title ) {
        [button setTitle: title forState:UIControlStateNormal ];
        button.titleLabel.font= [UIFont fontWithName: kFontLatoRegular size:fontSize];
    }
    if ( target && callback) {
        [button addTarget: target action: callback forControlEvents:UIControlEventTouchUpInside ];
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
    [parent addSubview: button ];
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

UIButton* makeRoundIconButtonForAutolayout(UIView *parent, NSString*  title, float fontSize,  UIColor *fg, UIColor *bg, id target, SEL callback, float borderWidth, float radius)
{
    UIButton *b = makeButtonForAutolayout(parent, title, fontSize, fg, bg, target, callback, borderWidth);
    b.titleLabel.font = [UIFont fontWithName:kFontIcons size:fontSize];
    b.layer.cornerRadius = radius;
    return b;
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

NSAttributedString* attributedBoldStringWithColorOf(NSString* string,double fontSize, UIColor*color)
{
    NSAttributedString* a= [[NSAttributedString alloc]
                            initWithString:string ?: @""
                            attributes: @{
                                          NSFontAttributeName:[UIFont fontWithName: kFontLatoBold size:fontSize],
                                          NSForegroundColorAttributeName:color
                                          }];
    return a;
}

NSAttributedString* attributedStringWithColorOf(NSString* string,double fontSize, UIColor*color)
{
    NSAttributedString* a= [[NSAttributedString alloc]
                            initWithString:string ?: @""
                            attributes: @{
                                          NSFontAttributeName:[UIFont fontWithName: kFontLatoRegular size:fontSize],
                                          NSForegroundColorAttributeName:color
                                          }];
    return a;
}

NSAttributedString* attributedIconStringWithColorOf(NSString* string,double fontSize, UIColor*color)
{
    NSAttributedString* a= [[NSAttributedString alloc]
                            initWithString:string ?: @""
                            attributes: @{
                                          NSFontAttributeName: [UIFont fontWithName: kFontIcons size:fontSize],
                                          NSForegroundColorAttributeName:color
                                          
                                          }];
    return a;
}

NSAttributedString* attributedIconStringOf(NSString* string,double fontSize)
{
    NSAttributedString* a= [[NSAttributedString alloc]
                            initWithString:string ?: @""
                            attributes: @{
                                          NSFontAttributeName: [UIFont fontWithName: kFontIcons size:fontSize],

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
    temp= [temp stringByReplacingOccurrencesOfString: @"Z" withString: @""];
    temp= [temp stringByReplacingOccurrencesOfString: @"  " withString: @" "];
    temp= [temp stringByReplacingOccurrencesOfString: @".000" withString: @""];
    temp= trimString( temp);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:   temp];
    return date;
}

NSUInteger parseUnsignedIntegerOrNullFromServer (id object)
{
    if  (object && [object isKindOfClass:[NSNumber class]]) {
        return  (( NSNumber*)object).unsignedIntegerValue;
    }
    if  (object && [object isKindOfClass:[NSString class]]) {
        return (NSUInteger) (( NSString*)object).integerValue;
    }
    return 0;
}

NSInteger parseIntegerOrNullFromServer (id object)
{
    if  (object && [object isKindOfClass:[NSNumber class]]) {
        return  (( NSNumber*)object).integerValue;
    }
    if  (object && [object isKindOfClass:[NSString class]]) {
        return  (( NSString*)object).integerValue;
    }
    return 0;
}

double parseNumberOrNullFromServer (id object)
{
    if  (object && [object isKindOfClass:[NSNumber class]]) {
        return  (( NSNumber*)object).doubleValue;
    }
    if  (object && [object isKindOfClass:[NSString class]]) {
        return  (( NSString*)object).doubleValue;
    }
    return 0;
}

NSArray* parseArrayOrNullFromServer (id object)
{
    if  (object && [object isKindOfClass:[NSArray class]]) {
        return  (NSArray*)object;
    }
    return nil;
}

NSString* parseStringOrNullFromServer (id object)
{
    if  (object && [object isKindOfClass:[NSString class]]) {
        return  (NSString*)object;
    }
    return nil;
}

NSString* expressLocalDateTime(NSDate* date)
{
    if (!date) {
        return  @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, h:mmaa";
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:gmt];
    NSString *string = [dateFormatter stringFromDate: date];
    return string;
}

NSString* expressLocalTime(NSDate* date)
{
    if (!date) {
        return  @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mmaa";
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:gmt];
    NSString *string = [dateFormatter stringFromDate: date];
    return string;
}

NSInteger getLocalHour (NSDate* date)
{
    if (!date) {
        return 0;
    }
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitHour fromDate: date];
    [dateComponents  setTimeZone:gmt];
    NSInteger n = [dateComponents hour];
    return n;
}

NSInteger getLocalDayOfMonth (NSDate* date)
{
    if (!date) {
        return 0;
    }
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitDay fromDate: date];
    [dateComponents  setTimeZone:gmt];
    NSInteger n = [dateComponents day];
    return n;
}

NSInteger getLocalDayNumber(NSDate* date)
{
    if (!date) {
        return 0;
    }
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    NSDateComponents *dateComponents = [calender components:NSCalendarUnitWeekday fromDate: date];
    [dateComponents  setTimeZone:gmt];
    NSInteger n = [dateComponents weekday]-1;
    return n;
}

NSString* expressLocalMonth(NSDate* date)
{
    if (!date) {
        return  @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM";
    NSTimeZone *gmt = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:gmt];
    NSString *string = [dateFormatter stringFromDate: date];
    return string;
}

BOOL isValidEmailAddress (NSString *string)
{
    if  (!string || ![string isKindOfClass:[NSString class ]]) {
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

void ANALYTICS_INIT(void)
{
    NSError *configureError= nil;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    if (!configureError) {
        return;
    }
    
    GAI *gai = [GAI sharedInstance];
    
    [gai trackerWithTrackingId: GOOGLE_ANALYTICS_ID];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release

}

void ANALYTICS_SCREEN(NSString* name)
{
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:name];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

void ANALYTICS_FORCE_SYNC ()
{
    [[GAI sharedInstance] dispatch];
}

void ANALYTICS_EVENT_ERROR (NSString*name)
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"error"
                                                          action:  name?:  @"unknown"
                                                           label:@""
                                                           value:nil] build]];
    
}

void ANALYTICS_EVENT_OTHER (NSString*name)
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"other"
                                                          action:  name?:  @"unknown"
                                                           label:@""
                                                           value:nil] build]];
    
}

void ANALYTICS_EVENT_CLOUD (NSString* name)
{
	 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"cloud"
                                                              action:  name?:  @"unknown"
                                                               label:@""
                                                               value:nil] build]];
    
}

void ANALYTICS_EVENT_UI (NSString* name)
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui"
                                                          action: name ?:  @"unknown"
                                                           label:  @""
                                                           value:nil] build]];
}

@implementation Common

+ (NSString *)versionString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *s = [NSString stringWithFormat:@"v%@b%@", majorVersion, minorVersion];
    return s;
}

+ (NSString *)locationString:(CLPlacemark *)placemark {
    NSMutableArray *locationElements = [NSMutableArray array];
    if ([placemark.addressDictionary objectForKey:@"Street"]) [locationElements addObject:[placemark.addressDictionary objectForKey:@"Street"]];
    if (![locationElements count] && [placemark.addressDictionary objectForKey:@"SubLocality"]) [locationElements addObject:[placemark.addressDictionary objectForKey:@"SubLocality"]];
    if ([placemark.addressDictionary objectForKey:@"City"]) [locationElements addObject:[placemark.addressDictionary objectForKey:@"City"]];
    if ([placemark.addressDictionary objectForKey:@"State"]) [locationElements addObject:[placemark.addressDictionary objectForKey:@"State"]];
    if ([placemark.addressDictionary objectForKey:@"ZIP"]) [locationElements addObject:[placemark.addressDictionary objectForKey:@"ZIP"]];
    if ([placemark.addressDictionary objectForKey:@"Country"]) [locationElements addObject:[placemark.addressDictionary objectForKey:@"Country"]];

    return [locationElements componentsJoinedByString:@", "];
}

+ (void)goToSettings:(kAppSettings)settings
{
    NSString *path;
    
    switch (settings) {
        case kAppSettingsCamera:
            path = @"prefs:root=Privacy&path=CAMERA";
            break;
        case kAppSettingsPhotos:
            path = @"prefs:root=Privacy&path=PHOTOS";
            break;
        default:
            break;
    }
    
    NSURL*url=[NSURL URLWithString:path];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)addShadowTo:(UIView *)view withColor:(NSUInteger)color
{
    view.opaque = YES;
    view.layer.shadowOffset = CGSizeMake ( 2, 2);
    view.layer.shadowColor = UIColorRGBA(color).CGColor;
    view.layer.shadowOpacity = .5;
    view.layer.shadowRadius = 4;
    view.clipsToBounds = NO;
}

@end
