//
//  Common.h: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Google/Analytics.h>
#import "OOAPI.h"
#import "Reachability.h"
#import "UserObject.h"

typedef enum {
    kAppSettingsPhotos,
    kAppSettingsCamera,
    kAppSettingsLocation,
    kAppSettingsContacts
} kAppSettings;

#define HALF_HOUR (30*60)
#define ONE_HOUR (60*60)
#define ONE_DAY (24*ONE_HOUR)
#define TWO_DAYS (2*ONE_DAY)
#define ONE_WEEK (7*ONE_DAY)

@class AppDelegate;
#define APP ((AppDelegate* )[UIApplication sharedApplication].delegate)

#define LOCAL(STR) NSLocalizedString(STR, nil)
//The problem with using this macro is that it is hard to step into the block with the debugger.
#define ON_MAIN_THREAD(BLK) dispatch_async(dispatch_get_main_queue(),BLK)
#define RUN_AFTER(MS,BLK) {dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW,MS * 1000000);dispatch_after(delayTime, dispatch_get_main_queue(), BLK); }
#define IS_IPAD ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
#define IS_IPHONE4  ( [UIScreen  mainScreen].bounds.size.height <= 480) 

extern NSString *const kNotificationLocationBecameAvailable;
extern NSString *const kNotificationLocationBecameUnavailable;
extern NSString *const kNotificationGotFirstLocation;

extern void message(NSString *str);
extern void messageWithTitle(NSString *str, NSString *string);
extern void messageWithTitleAndCompletionBlock(NSString *title, NSString *string, void (^block)(BOOL result),
                                         BOOL showCancel);

extern NSString *const kOOURLStage;
extern NSString *const kOOURLProduction;
extern NSString *const kOOURLLocal;
extern NSString *const kHTTPProtocol;
extern NSString *getDateString();
extern NSString *trimString(NSString *s);
extern NSString *platformString();
extern NSString *concatenateStrings(NSString *, NSString *);
extern unsigned long msTime (void);
extern NSString *stringFromUnsigned(NSUInteger);

extern NSAttributedString *attributedStringOf(NSString *, double fontSize);
extern NSAttributedString *underlinedAttributedStringOf(NSString *, double fontSize);
extern NSAttributedString *attributedIconStringOf(NSString *string, double fontSize);
extern NSAttributedString *attributedStringWithColorOf(NSString *string, double fontSize, UIColor *color);
extern NSAttributedString *attributedBoldStringWithColorOf(NSString *string, double fontSize, UIColor *color);

extern UIImageView *makeImageView(UIView *parent, id image);
extern UIButton *makeButton(UIView *parent, NSString *title, float fontSize, UIColor *fg, UIColor *bg, id target, SEL callback, float borderWidth);
extern UIButton *makeRoundIconButton (UIView *parent, NSString *title, float fontSize, UIColor *fg, UIColor *bg, id target, SEL callback, float borderWidth, float radius);
extern UIButton *makeRoundButton(UIView *parent, NSString *title, float fontSize, UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth, float radius);
extern UIButton *makeIconButton(UIView *parent, NSString *title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UILabel *makeLabel(UIView *parent, NSString*  text, float fontSize);
extern UILabel *makeAttributedLabel(UIView *parent, NSString *text, float fontSize);
extern UILabel *makeAttributedLabelWithColor (UIView *parent, NSString *text, float fontSize, UIColor *color);
extern UILabel *makeLabelLeft(UIView *parent, NSString *text, float fontSize);
extern UITextView *makeTextView(UIView *parent, UIColor *bg, BOOL editable);
extern UILabel *makeIconLabel(UIView *parent, NSString *text, float fontSize);
extern UITableView *makeTable(UIView *parent, id delegate);
extern UICollectionView *makeCollectionView(UIView *parent, id delegate, UICollectionViewLayout *layout);
extern UICollectionView *makeHorizontalCollectionView(UIView *parent,id  delegate, CGSize itemSize);
extern UICollectionView *makeVerticalCollectionView(UIView *parent,id  delegate, CGSize itemSize);
extern UIButton *makeAttributedButton(UIView *parent, NSString *title, float fontSize,  UIColor *fg, UIColor *bg, id  target, SEL callback, float borderWidth);
extern UIView *makeView(UIView *parent, UIColor *backgroundColor);

extern void addBorder(UIView *, float width, UIColor *color);

extern NSDate *parseUTCDateFromServer(NSString *string);
extern NSString *parseStringOrNullFromServer(id object);
extern double parseNumberOrNullFromServer(id object);
extern NSInteger parseIntegerOrNullFromServer(id object);
extern NSUInteger parseUnsignedIntegerOrNullFromServer(id object);
extern NSArray *parseArrayOrNullFromServer(id object);
extern BOOL parseBoolOrNullFromServer(id object);
extern CGFloat parseFloatOrNullFromServer (id object);


extern BOOL isValidEmailAddress(NSString *string);

extern NSString *expressLocalDateTime(NSDate * date);
extern NSString *expressLocalTime(NSDate *date);
extern NSString *expressLocalMonth(NSDate *date);
extern NSInteger getLocalDayNumber(NSDate *);
extern NSInteger getLocalDayOfMonth(NSDate *date);
extern NSInteger getLocalHour(NSDate *date);

#define NOTIFY(NNN) { \
[[NSNotificationCenter defaultCenter] postNotificationName:NNN object:nil]; \
}

#define NOTIFY_WITH(NNN,OOO) { \
[[NSNotificationCenter defaultCenter] postNotificationName:NNN object:OOO]; \
}

static inline BOOL is_reachable(void) {
	NetworkStatus status = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
	return status ==ReachableViaWiFi || status==ReachableViaWWAN;
}

extern void ANALYTICS_INIT(void);
extern void ANALYTICS_SCREEN(NSString *);
extern void ANALYTICS_EVENT_UI(NSString *);
extern void ANALYTICS_EVENT_CLOUD(NSString *);
extern void ANALYTICS_EVENT_OTHER(NSString *);
extern void ANALYTICS_FORCE_SYNC(void);
extern void ANALYTICS_EVENT_ERROR(NSString *name);

@interface Common : NSObject

+ (NSString *)platformRawString;
+ (NSString *)versionString;
+ (NSString *)locationString:(CLPlacemark *)placemark;
+ (void)goToSettings:(kAppSettings)settings;
+ (void)addShadowTo:(UIView *)view withColor:(NSUInteger)color;
+ (BOOL)validateEmailWithString:(NSString*)checkString;
+ (BOOL)validatePasswordWithString:(NSString*)checkString;
+ (void)addMotionEffectToView:(UIView *)view;

@end
