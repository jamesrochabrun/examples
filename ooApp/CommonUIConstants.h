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
        alpha:(rgbValue >> 24)/255.0f]

#define UIColorRGBOverlay(rgbValue, alphaValue) [UIColor colorWithRed:(255&(rgbValue>> 16))/255.0f \
        green:(255&(rgbValue >> 8))/255.0f \
        blue:(255&rgbValue)/255.0f \
        alpha:alphaValue]

static const NSUInteger kColorElements1 = 0xFF272727;
static const NSUInteger kColorElements2 = 0xFFe0e0e0;
static const NSUInteger kColorElements3 = 0xff8D99AE;

static const NSUInteger kColorGrayMiddle = 0xFFB2B2B2;
static const NSUInteger kColorWhite = 0xFFFFFFFF;
static const NSUInteger kColorBlack = 0xFF000000;
static const NSUInteger kColorClear = 0x00000000;
static const NSUInteger kColorNavyBlue = 0xFF000080;
static const NSUInteger kColorYellow = 0xFFF9FF00;
static const NSUInteger kColorMarkerFaded = 0x701874CD;

static NSUInteger kColorOffBlack = 0xFF272727;
static NSUInteger kColorOffWhite = 0xFFE5E5E5;

static const NSUInteger kColorOverlay10 = 0xE6000000;
static const NSUInteger kColorOverlay20 = 0xCC000000;
static const NSUInteger kColorOverlay25 = 0xC0000000;
static const NSUInteger kColorOverlay30 = 0xB3000000;
static const NSUInteger kColorOverlay35 = 0xA6000000;
static const NSUInteger kColorOverlay40 = 0x99000000;
static const NSUInteger kColorOverlay50 = 0x7F000000;

#define LIGHT_SCHEME 1

// App colors
#ifdef DARK_SCHEME
static NSUInteger kColorBackgroundTheme = 0xFF171717;
static const NSUInteger kColorTextActive = kColorYellow;
static NSUInteger kColorTextActiveFaded = (kColorTextActive & 0x99FFFFFF);
static NSUInteger kColorLightImageOverlay = (kColorOverlay50 | 0x00000000);
static NSUInteger kColorDarkImageOverlay = (kColorOverlay20 | 0x00000000);
static NSUInteger kColorText = kColorWhite;
static NSUInteger kColorTextReverse = kColorBlack;
static const NSUInteger kColorNavBarText = kColorWhite;
static const NSUInteger kColorNavBar = kColorBlack;
static const NSUInteger kColorReverseBackground = kColorElements2;
static const NSUInteger kColorStripHeader = kColorElements1;
static const NSUInteger kColorButtonBackground = kColorElements1;
static const NSUInteger kColorTileBackground = 0xFF1a1a1a;
static NSUInteger kColorFilterBackground = kColorStripHeader;
static NSUInteger kColorEmptyTileBackground = kColorStripHeader;
static NSUInteger kColorConnectHeaderBackground = kColorStripHeader;
static NSUInteger kColorCellBackground = kColorStripHeader;
static NSUInteger kColorCellSelected = kColorStripHeader;
static NSUInteger kColorTabBar = kColorNavBar;
static NSUInteger kColorBordersAndLines = kColorStripHeader;
static NSUInteger kColorMarker = kColorTextActive;
#elif LIGHT_SCHEME
static NSUInteger kColorBackgroundTheme = 0xFFefefef;
static const NSUInteger kColorTextActive = 0xFFd95030;//orange;0xff69a583;//green;//0xff9f38cf;purple
static NSUInteger kColorTextActiveFaded = 0xFFd95030;//orange;0xff69a583;//green;0xFFd95030;//orange; 0xFF9782cf; //(kColorTextActive & 0x99FFFFFF);
static NSUInteger kColorLightImageOverlay = (kColorOverlay50 | 0x00FFFFFF);
static NSUInteger kColorDarkImageOverlay = (kColorOverlay30 | 0x00FFFFFF);
static NSUInteger kColorText = 0xFF111111;
static NSUInteger kColorTextReverse = kColorWhite;
static const NSUInteger kColorNavBarText = kColorWhite;
static const NSUInteger kColorNavBar = 0xff121212;//gray 0xFF626064;//
static const NSUInteger kColorReverseBackground = kColorElements1;
static const NSUInteger kColorStripHeader = kColorElements2;
static const NSUInteger kColorButtonBackground = kColorElements2;
static const NSUInteger kColorTileBackground = 0xFFe6e6e6;
static NSUInteger kColorFilterBackground = kColorStripHeader;
static NSUInteger kColorEmptyTileBackground = kColorStripHeader;
static NSUInteger kColorConnectHeaderBackground = kColorStripHeader;
static NSUInteger kColorCellBackground = kColorStripHeader;
static NSUInteger kColorCellSelected = kColorStripHeader;
static NSUInteger kColorTabBar = kColorWhite;
static NSUInteger kColorBordersAndLines = kColorStripHeader;
static NSUInteger kColorMarker = kColorTextActive;
#elif A_SCHEME
static NSUInteger kColorBackgroundTheme = 0xffEDF2F4;
static const NSUInteger kColorTextActive = 0xffD90429;
static NSUInteger kColorTextActiveFaded = (kColorTextActive & 0x99FFFFFF);
static NSUInteger kColorLightImageOverlay = (kColorOverlay50 | 0x00FFFFFF);
static NSUInteger kColorDarkImageOverlay = (kColorOverlay20 | 0x00FFFFFF);
static NSUInteger kColorText = kColorBlack;
static NSUInteger kColorTextReverse = kColorWhite;
static const NSUInteger kColorNavBarText = kColorWhite;
static const NSUInteger kColorNavBar = 0xff2B2D42;
static const NSUInteger kColorReverseBackground = 0xffebd4c8;
static NSUInteger kColorStripHeader = kColorElements3;
static const NSUInteger kColorButtonBackground = kColorElements3;
static const NSUInteger kColorTileBackground = 0xFFe6e6e6;
static NSUInteger kColorFilterBackground = kColorElements3;
static NSUInteger kColorEmptyTileBackground = kColorElements3;
static NSUInteger kColorConnectHeaderBackground = kColorElements3;
static NSUInteger kColorCellBackground = kColorElements3;
static NSUInteger kColorCellSelected = kColorElements3;
static NSUInteger kColorTabBar = kColorWhite;
static NSUInteger kColorBordersAndLines = kColorElements3;
static NSUInteger kColorMarker = kColorTextActive;
#endif

static NSUInteger kColorRed = 0xFFFF0000;
static NSUInteger kColorGreen = 0xFF00FF00;
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
static CGFloat kGeomIconSize = 30;
static CGFloat kGeomIconSizeSmall = 27;
static CGFloat kGeomIconSizeSmallest = 20;

static NSInteger kGeomPeopleIconFontSize = 30;
static CGFloat kGeomHeightButton = 44.0;
static CGFloat kGeomHeightTextField = 40.0;
static CGFloat kGeomDimensionsIconButtonSmall = 35.0;
static CGFloat kGeomDimensionsIconButton = 40.0;
static CGFloat kGeomHeightNavBarStatusBar = 64.0;
static CGFloat kGeomHeightStatusBar = 20.0;
static CGFloat kGeomHeightNavBar = 44;
static CGFloat kGeomHeightTabBar = 49;
static CGFloat kGeomHeightFilters = 40.0;
static CGFloat kGeomWidthButton = 100;
static CGFloat kGeomWidthButtoniPadMax = 300;
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
static CGFloat kGeomSpaceInter = 8;
static CGFloat kGeomSampleUsernameTableHeight = 175;
static CGFloat kGeomInterImageGap = 2;
static CGFloat kGeomSpaceLineEdgeBuffer = 4;
static CGFloat kGeomMotionEffectDelta = 20;

static CGFloat kGeomUploadWidth = 750;

static CGFloat kParalaxFactor = 0.5;

// Profile screen.
static CGFloat kGeomProfileImageSize = 94;
static CGFloat kGeomProfileFilterViewHeight = 27;
//static CGFloat kGeomProfileTextviewHeight= 36;
static CGFloat kGeomProfileStatsItemHeight= 30;

static CGFloat kGeomFollowButtonHeight = 24;
static CGFloat kGeomProfileHeaderViewHeightOfBloggerButton = 25;
static NSUInteger kProfileNumColumnsForMediaItemsPhone = 2;
static CGFloat kGeomProfileSettingsBadgeSize=  30;
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
//extern NSString *const kFontLatoThin; feel to thin
extern NSString *const kFontLatoLight;
extern NSString *const kFontLatoRegular;
extern NSString *const kFontLatoBold;
extern NSString *const kFontLatoMedium;
//extern NSString *const kFontLatoMediumItalic;
//extern NSString *const kFontLatoSemiboldItalic;
//extern NSString *const kFontLatoBoldItalic;
//extern NSString *const kFontLatoHeavyItalic;

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
extern NSString *const kFontIconPinDot;
extern NSString *const kFontIconPinDotFilled;
extern NSString *const kFontIconArrow;
extern NSString *const kFontIconClosed;
extern NSString *const kFontIconCreateList;
extern NSString *const kFontIconInvite;


extern NSString *const kNotificationConnectNeedsUpdate;
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

extern NSString *const kImageBackgroundImage;

#endif
