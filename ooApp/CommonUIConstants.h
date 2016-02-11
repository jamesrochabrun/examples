//
//  CommonUIConstants.h
//  ooApp
//
//  Created by Anuj Gujar on 7/31/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef ooApp_CommonUI_h
#define ooApp_CommonUI_h

// Convenience Macros
#define UIColorRGB(rgbValue) [UIColor colorWithRed:(255&(rgbValue>> 16))/255.0f \
        green:(255&(rgbValue >> 8))/255.0 \
        blue:(255&rgbValue)/255.0 alpha:1.0]
#define UIColorRGBA(rgbValue) [UIColor colorWithRed:(255&(rgbValue>> 16))/255.0f \
        green:(255&(rgbValue >> 8))/255.0f \
        blue:(255&rgbValue)/255.0f \
        alpha:(rgbValue >> 24)/255.0f ]

// App colors
static NSUInteger kColorBlack = 0xFF000000;
static NSUInteger kColorBackgroundTheme = 0xFF171717;
static NSUInteger kColorButtonSelected = 0xFF0000FF;
static NSUInteger kColorCellSelected =  0xFF323232;//0xFFF9FF00;
static NSUInteger kColorClear = 0x00000000;
static NSUInteger kColorLightGray = 0xFF808080;
static NSUInteger kColorGray = 0xFFE5E5E5;
static NSUInteger kColorGrayMiddle = 0xFFB2B2B2;
static NSUInteger kColorNavBar = 0xFF000000;
static NSUInteger kColorNavyBlue = 0xFF000080;
static NSUInteger kColorMarker = 0xFFF9FF00;//0xFF1874CD;//0xDD0000A0;
static NSUInteger kColorMarkerFaded = 0x701874CD;//0x700000A0;
static NSUInteger kColorOffBlack = 0xFF272727;
static NSUInteger kColorOffWhite = 0xFFE5E5E5;
static NSUInteger kColorOverlay10 = 0xE6000000;
static NSUInteger kColorOverlay20 = 0xCC000000;
static NSUInteger kColorOverlay25 = 0xC0000000;
static NSUInteger kColorOverlay30 = 0xB3000000;
static NSUInteger kColorOverlay35 = 0xA6000000;
static NSUInteger kColorOverlay40 = 0x99000000;
static NSUInteger kColorOverlay50 = 0x7F000000;
static NSUInteger kColorLightOverlay50 = 0x7F555555;
static NSUInteger kColorWhite = 0xFFFFFFFF;
static NSUInteger kColorRed = 0xFFFF0000;
static NSUInteger kColorGreen = 0xFF00FF00;
static NSUInteger kColorBlue = 0xFF0000FF;
static NSUInteger kColorYellow = 0xFFF9FF00;
static NSUInteger kColorYellowFaded = 0x99F9FF00;
static NSUInteger kColorYellowReallyFaded = 0x45F9FF00;
static NSUInteger kColorStripHeaderShadow = 0x88898989;
static NSUInteger kColorIconSelected = 0xFFFFFFFF;
static NSUInteger kColorCoordinatorBoxBackground = 0xFF2b2b2b;
static CGFloat kColorEventOverlayAlpha = 0.3;

// Geometry and metrics
static CGFloat kGeomCornerRadius = 3.0;
static NSUInteger kGeomFontSizeBig = 19;
static NSUInteger kGeomFontSizeH1 = 17;
static NSUInteger kGeomFontSizeH2 = 15;
static NSUInteger kGeomFontSizeH3 = 13;
static NSUInteger kGeomFontSizeH4 = 12;
static NSUInteger kGeomFontSizeH5 = 11;
static NSUInteger kGeomFontSizeH6 = 9;
static NSUInteger kGeomFontSizeHeader = 16;
static NSUInteger kGeomFontSizeSubheader = 13;
static NSUInteger kGeomFontSizeListButton = 12;
static NSUInteger kGeomFontSizeStripHeader = 13;
static NSUInteger kGeomFontSizeBannerMain = 12;
static NSUInteger kGeomFontSizeDetail = 11;
static NSUInteger kGeomFontSizeAbout = 13;
static CGFloat kGeomIconSize = 30;
static CGFloat kGeomIconSizeSmall = 27;

static NSInteger kGeomPeopleIconFontSize = 30;
static CGFloat kGeomHeightButton = 44.0;
static CGFloat kGeomDimensionsIconButtonSmall = 35.0;
static CGFloat kGeomDimensionsIconButton = 40.0;
static CGFloat kGeomHeightNavBarStatusBar = 64.0;
static CGFloat kGeomHeightStatusBar = 20.0;
static CGFloat kGeomHeightTabBar = 49;
static CGFloat kGeomHeightFilters = 40.0;
static CGFloat kGeomButtonWidth = 100;
static CGFloat kGeomHeightSampleUsernameRow = 180.0;
static CGFloat kGeomHeightFeaturedRow = 180.0;
static CGFloat kGeomHeightFeaturedCellWidth = 320.0;
static CGFloat kGeomHeightFeaturedCellHeight = 150.0;
static CGFloat kGeomHeightStripListRow = 135.0;
static CGFloat kGeomHeightStripListCell = 100.0;
static CGFloat kGeomHeightHorizontalListRow = 100.0;
static NSUInteger kGeomPlayIconSize = 35;
static NSUInteger kGeomPlayButtonSize = 65;
static CGFloat kGeomSpaceCellPadding = 3;
static CGFloat kGeomSpaceEdge = 6;
static CGFloat kGeomSpaceIcon = 5.0;
static CGFloat kGeomSpaceInter = 8;
static CGFloat kGeomSampleUsernameTableHeight = 175;
static CGFloat kGeomInterImageGap = 2;

static CGFloat kGeomUploadWidth = 750;

// Profile screen.
static CGFloat kGeomProfileImageSize = 94;
static CGFloat kGeomProfileFilterViewHeight = 27;
static CGFloat kGeomProfileTextviewHeight= 36;
static CGFloat kGeomProfileStatsItemHeight= 30;
//<<<<<<< HEAD
//#define PROFILE_HEADERVIEW_BASE_HEIGHT 213
//#define PROFILE_HEADERVIEW_FOLLOW_HEIGHT 35
//#define PROFILE_HEADERVIEW_URL_HEIGHT 29
//static CGFloat kGeomProfileHeaderViewHeightSelf = PROFILE_HEADERVIEW_BASE_HEIGHT;
//static CGFloat kGeomProfileHeaderViewHeightNormal = PROFILE_HEADERVIEW_BASE_HEIGHT+PROFILE_HEADERVIEW_FOLLOW_HEIGHT;
//static CGFloat kGeomProfileHeaderViewHeightOfBloggerButton = 25;
//=======
#define PROFILE_HEADERVIEW_FOLLOW_BUTTON_HEIGHT 24
static CGFloat kGeomFollowButtonHeight= PROFILE_HEADERVIEW_FOLLOW_BUTTON_HEIGHT; // Connect screen, profile screen
#define PROFILE_HEADERVIEW_FOLLOW_HEIGHT (PROFILE_HEADERVIEW_FOLLOW_BUTTON_HEIGHT+11) // includes spacer
#define PROFILE_HEADERVIEW_BASE_HEIGHT 213
#define PROFILE_HEADERVIEW_SPECIALTIES_HEIGHT 38
#define PROFILE_HEADERVIEW_URL_BUTTON_HEIGHT 25
static CGFloat kGeomProfileHeaderViewHeightOfBloggerButton = PROFILE_HEADERVIEW_URL_BUTTON_HEIGHT;
#define PROFILE_HEADERVIEW_URL_HEIGHT (PROFILE_HEADERVIEW_URL_BUTTON_HEIGHT+4)
static CGFloat kGeomProfileHeaderViewHeightSelf = PROFILE_HEADERVIEW_BASE_HEIGHT;
static CGFloat kGeomProfileHeaderViewHeightNormal = PROFILE_HEADERVIEW_BASE_HEIGHT+PROFILE_HEADERVIEW_FOLLOW_HEIGHT;
//>>>>>>> OOAP-417
static CGFloat kGeomProfileHeaderViewHeightBlogger = PROFILE_HEADERVIEW_BASE_HEIGHT+PROFILE_HEADERVIEW_FOLLOW_HEIGHT+PROFILE_HEADERVIEW_URL_HEIGHT;
static NSUInteger kProfileNumColumnsForMediaItemsPhone = 2;
static CGFloat kGeomProfileStatsOverallWidth= 171;
static CGFloat kGeomProfileSettingsBadgeSize=  30;
static CGFloat kGeomProfileEmptyPlusSize= 40;
static NSUInteger kGeomFontSizeStatsText = 14;
static NSUInteger kGeomFontSizeStatsIcons = 22;

static CGFloat kGeomUserListUserImageHeight=82;

static CGFloat kGeomForkImageSize = 150;
static CGFloat kGeomEmptyTextViewWidth = 200;
static CGFloat kGeomEmptyTextFieldWidth = 150;
static CGFloat kGeomLogoWidth = 200;
static CGFloat kGeomLogoHeight = 100;
static CGFloat kGeomLoginVerticalDisplacement = 75;
static CGFloat kGeomWidthMenuButton = 44;// The button should stay at 44. The titleView should shrink if required
static CGFloat kGeomCancelButtonInteriorPadding = 3.5;
static CGFloat kGeomHeightFilterSelectedLine = 3.0;
static CGFloat kGeomHeightSearchBar = 55;

static CGFloat kGeomHeightEventCellHeight = 160.0;
static CGFloat kGeomEventHeadingFontSize = 30;

static CGFloat kGeomEventCoordinatorBoxHeight = 130;
static CGFloat kGeomEventCoordinatorPieDiameter = 33;
static CGFloat kGeomEventCoordinatorBoxHeightTopmost = 230;

static CGFloat kGeomHeightEventWhoTableCellHeight = 100;
static CGFloat kGeomHeightEventWhoTableCellImageHeight = 84;

static CGFloat kGeomEventParticipantFirstBoxHeight = 170;
static CGFloat kGeomEventParticipantButtonHeight =  33;
static CGFloat kGeomEventParticipantRestaurantHeight = 92;
static CGFloat kGeomEventParticipantSeparatorHeight = 6;

static CGFloat kGeomVotingResultsBoxHeight = 175;
static CGFloat kGeomVotingResultsRestaurantHeight = 92;

static CGFloat kGeomFaceBubbleDiameter = 26;
static CGFloat kGeomFaceBubbleSpacing = 5;

static CGFloat kGeomStripHeaderHeight = 27;
static CGFloat kGeomSideBarRevealWidth = 235;
static CGFloat kGeomHeightCreateListButton = 23;
static CGFloat kGeomVerticalSpaceCreateList = 31;
static CGFloat kGeomHeightDropDownListRow = 40;
static CGFloat kNumDropDownListRows = 5;

static CGFloat kGeomHeightFeedWithImageTableCellHeight= 180;
static CGFloat kGeomHeightFeedWithoutImageTableCellHeight=  60;

static CGFloat kGeomCreateUsernameCentralIconSize= 150;

static CGFloat kGeomConnectScreenHeaderHeight= 33;
static CGFloat kGeomConnectScreenUserImageHeight= 82;

// Images
extern NSString *const kImageNoProfileImage;

// Custom Fonts
extern NSString *const kFontIcons;
extern NSString *const kFontLatoThin;
extern NSString *const kFontLatoRegular;
extern NSString *const kFontLatoBold;
extern NSString *const kFontLatoMedium;
extern NSString *const kFontLatoMediumItalic;
extern NSString *const kFontLatoSemiboldItalic;
extern NSString *const kFontLatoBoldItalic;
extern NSString *const kFontLatoHeavyItalic;

// Icon font mappings
extern NSString *const kFontIconAdd;
extern NSString *const kFontIconDiscover;
extern NSString *const kFontIconEvent;
extern NSString *const kFontIconFeed;
extern NSString *const kFontIconMenu;
extern NSString *const kFontIconMore;
extern NSString *const kFontIconPlay;
extern NSString *const kFontIconProfileFilled;
extern NSString *const kFontIconRemove;
extern NSString *const kFontIconSearch;
extern NSString *const kFontIconSettings;
extern NSString *const kFontIconSettingsFilled;
extern NSString *const kFontIconWhatsNew;
extern NSString *const kFontIconWhatsNewFilled;
extern NSString *const kFontIconPerson;
extern NSString *const kFontIconCheckmarkCircle;
extern NSString *const kFontIconDontCare;
extern NSString *const kFontIconFavorite;
extern NSString *const kFontIconFavoriteFilled;
extern NSString *const kFontIconPhoto;
extern NSString *const kFontIconUpload;
extern NSString *const kFontIconLocation;
extern NSString *const kFontIconLocationFilled;
extern NSString *const kFontIconToTry;
extern NSString *const kFontIconToTryFilled;
extern NSString *const kFontIconList;
extern NSString *const kFontIconEmptyCircle;
extern NSString *const kFontIconFilledCircle;
extern NSString *const kFontIconBack;
extern NSString *const kFontIconPin;
extern NSString *const kFontIconPinFilled;
extern NSString *const kFontIconMap;
extern NSString *const kFontIconLogo;
extern NSString *const kFontIconShare;
extern NSString *const kFontIconCheckmark;
extern NSString *const kFontIconFoodFeed;
extern NSString *const kFontIconCirclePlus;
extern NSString *const kFontIconCircleX;
extern NSString *const kFontIconYum;
extern NSString *const kFontIconThumbsUp;
extern NSString *const kFontIconYumOutline;
extern NSString *const kFontIconLogoFull;
extern NSString *const kFontIconCaption;
extern NSString *const kFontIconCaptionFilled;

extern NSString *const kNotificationFoodFeedNeedsUpdate;
extern NSString *const kNotificationRestaurantListsNeedsUpdate;
extern NSString *const kNotificationEventAltered;
extern NSString *const kNotificationEventDeleted;
extern NSString *const kNotificationOwnProfileNeedsUpdate;
extern NSString *const kNotificationPhotoDeleted;
extern NSString *const kNotificationRestaurantDeleted;
extern NSString *const kNotificationListDeleted;
extern NSString *const kNotificationListAltered;
extern NSString *const kNotificationMediaItemAltered;
extern NSString *const kNotificationUserStatsChanged;
extern NSString *const kNotificationUserFollowingChanged;

#define BLACK UIColorRGB(kColorBlack)
#define WHITE UIColorRGB(kColorWhite)
#define GRAY UIColorRGB(kColorGray)
#define MIDDLEGRAY UIColorRGB(kColorGrayMiddle)
#define CLEAR (UIColor.clearColor)
#define RED UIColorRGB(kColorRed)
#define GREEN UIColorRGB(kColorGreen)
#define BLUE UIColorRGB(kColorBlue)
#define YELLOW UIColorRGB(kColorYellow)

#endif
