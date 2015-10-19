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
// NOTE: Correct hex format for RGBA is 0xAARRGGBB on little-endian systems.
//
static NSUInteger kColorBlack = 0xFF000000;
static NSUInteger kColorButtonSelected = 0xFF0000FF;
static NSUInteger kColorCellSelected = 0xFFF9FF00;
static NSUInteger kColorClear = 0x00000000;
static NSUInteger kColorGray = 0xFF555555;
static NSUInteger kColorGrayMiddle = 0xFFB2B2B2;
static NSUInteger kColorNavBar = 0xFFFFFFFF;
static NSUInteger kColorNavyBlue = 0xFF000080;
static NSUInteger kColorOffBlack = 0xFF222222;
static NSUInteger kColorOffWhite = 0xFFE5E5E5;
static NSUInteger kColorStripOverlay = 0x99000000;
static NSUInteger kColorWhite = 0xFFFFFFFF;
static NSUInteger kColorRed = 0xFFFF0000;
static NSUInteger kColorGreen = 0xFF00FF00;
static NSUInteger kColorBlue = 0xFF0000FF;
static NSUInteger kColorYellow = 0xFFF9FF00;
static NSUInteger kColorStripHeaderShadow = 0x88898989;

// Geometry and metrics
static CGFloat kGeomCornerRadius = 3.0;
static NSUInteger kGeomFontSizeHeader = 16;
static NSUInteger kGeomFontSizeSubheader = 14;
static NSUInteger kGeomFontSizeDetail = 11;
static NSUInteger kGeomFontSizeStripHeader = 13;
static NSInteger kGeomPeopleIconFontSize = 30;
static NSInteger kGeomEventHeadingFontSize = 30;
static CGFloat kGeomHeightButton = 44.0;
static CGFloat kGeomHeightNavBarStatusBar = 64.0;
static CGFloat kGeomHeightFilters = 40.0;
static CGFloat kGeomProfileInformationHeight = 18;
static CGFloat kGeomButtonWidth = 100;
static CGFloat kGeomHeightSampleUsernameRow = 180.0;
static CGFloat kGeomHeightFeaturedRow = 180.0;
static CGFloat kGeomHeightFeaturedCellWidth = 320.0;
static CGFloat kGeomHeightFeaturedCellHeight = 150.0;
static CGFloat kGeomHeightStripListRow = 130.0;
static CGFloat kGeomHeightStripListCell = 100.0;
static CGFloat kGeomHeightHorizontalListRow = 90.0;
static NSUInteger kGeomIconSize = 25;
static CGFloat kGeomSpaceEdge = 6;
static CGFloat kGeomSpaceIcon = 5.0;
static CGFloat kGeomSpaceInter = 8;
static CGFloat kGeomSampleUsernameTableHeight=  175;
static NSUInteger kGeomSampleUsernameTableWidth=  175/.62;
static CGFloat kGeomProfileImageSize =  100;
static CGFloat kGeomForkImageSize =  150;
static CGFloat kGeomEmptyTextViewWidth = 200;
static CGFloat kGeomEmptyTextFieldWidth = 150;
static CGFloat kGeomLogoWidth= 200;
static CGFloat kGeomLogoHeight= 100;
static CGFloat kGeomLoginVerticalDisplacement = 75;
static CGFloat kGeomWidthMenuButton = 44;// The button should stay at 44. The titleView should shrink if required
static CGFloat kGeomCancelButtonInteriorPadding = 3.5;
static CGFloat kGeomHeightFilterSelectedLine = 3.0;
static CGFloat kGeomHeightSearchBar=  55;
static CGFloat kGeomEventCoordinatorBoxHeight=  160
;

// Images
extern NSString *const kImageNoProfileImage;

// Custom FontsGood and yet so as
extern NSString *const kFontIcons;
extern NSString *const kFontSFTextRegular;
extern NSString *const kFontSFTextLight;
extern NSString *const kFontLatoThin;
extern NSString *const kFontLatoRegular;
extern NSString *const kFontLatoBold;
extern NSString *const kFontLatoMedium;

// Icon font mappings
extern NSString *const kFontIconAdd;
extern NSString *const kFontIconDiscover;
extern NSString *const kFontIconEvent;
extern NSString *const kFontIconFeed;
extern NSString *const kFontIconMenu;
extern NSString *const kFontIconMore;
extern NSString *const kFontIconProfile;
extern NSString *const kFontIconRemove;
extern NSString *const kFontIconSearch;
extern NSString *const kFontIconSettings;
extern NSString *const kFontIconWhatsNew;
extern NSString *const kFontIconPerson;
extern NSString *const kFontIconCheckmark;

#define BLACK UIColorRGB(kColorBlack)
#define WHITE UIColorRGB(kColorWhite)
#define GRAY UIColorRGB(kColorGray)
#define CLEAR UIColorRGBA(kColorClear)
#define RED UIColorRGB(kColorRed)
#define GREEN UIColorRGB(kColorGreen)
#define BLUE UIColorRGB(kColorBlue)
#define YELLOW UIColorRGB(kColorYellow)

#endif
