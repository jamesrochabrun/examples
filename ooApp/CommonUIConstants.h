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
static NSUInteger kColorBlack = 0xff000000;
static NSUInteger kColorButtonSelected = 0xff0000FF;
static NSUInteger kColorCellSelected = 0xff330000;
static NSUInteger kColorClear = 0x00000000;
static NSUInteger kColorGray = 0xff555555;
static NSUInteger kColorGrayMiddle = 0xffB2B2B2;
static NSUInteger kColorNavBar = 0xff000000;
static NSUInteger kColorNavyBlue = 0xff000080;
static NSUInteger kColorOffBlack = 0xff222222;
static NSUInteger kColorOffWhite = 0xffDDDDDD;
static NSUInteger kColorStripOverlay = 0x99000000;
static NSUInteger kColorWhite = 0xffFFFFFF;

// Geometry and metrics
static CGFloat kGeomCornerRadius = 3.0;
static NSUInteger kGeomFontSizeHeader = 16;
static NSUInteger kGeomFontSizeSubheader = 14;
static NSUInteger kGeomFontSizeDetail = 11;
static CGFloat kGeomHeightButton = 40.0;
static CGFloat kGeomProfileInformationHeight = 18;
static CGFloat kGeomButtonWidth = 100;
static CGFloat kGeomHeightFeaturedRow = 180.0;
static CGFloat kGeomHeightFeaturedCellWidth = 320.0;
static CGFloat kGeomHeightFeaturedCellHeight = 150.0;
static CGFloat kGeomHeightListRow = 130.0;
static CGFloat kGeomHeightListCell = 100.0;
static CGFloat kGeomHeightListRowReveal = 240.0;
static NSUInteger kGeomIconSize = 25;
static CGFloat kGeomSpaceEdge = 5.0;
static CGFloat kGeomSpaceIcon = 5.0;
static CGFloat kGeomSpaceInter = 10.0;
static float kProfileImageSize=  100;

// Images
extern NSString *const kImageNoProfileImage;

// Custom Fonts
extern NSString *const kFontIcons;
extern NSString *const kFontSFTextRegular;
extern NSString *const kFontSFTextLight;
extern NSString *const kFontLatoThin;
extern NSString *const kFontLatoRegular;
extern NSString *const kFontLatoBold;

// Icon font mappings
extern NSString *const kFontIconAdd;
extern NSString *const kFontIconDiscover;
extern NSString *const kFontIconEvent;
extern NSString *const kFontIconFeed;
extern NSString *const kFontIconMenu;
extern NSString *const kFontIconMore;
extern NSString *const kFontIconProfile;
extern NSString *const kFontIconSearch;
extern NSString *const kFontIconSettings;
extern NSString *const kFontIconWhatsNew;

#endif
