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

// Convenience marcos
#define UIColorRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 24))/255.0 green:((float)((rgbValue & 0x00FF00) >> 16))/255.0 blue:((float)((rgbValue & 0x0000FF) >> 8))/255.0 alpha:1.0]

#define UIColorRGBA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 24))/255.0 green:((float)((rgbValue & 0x00FF00) >> 16))/255.0 blue:((float)((rgbValue & 0x0000FF) >> 8))/255.0 alpha:(rgbValue & 0xff000000)/255.0]

// App colors
static NSUInteger kColorBlack = 0x000000FF;
static NSUInteger kColorButtonSelected = 0x0000FFFF;
static NSUInteger kColorCellSelected = 0x330000FF;
static NSUInteger kColorClear = 0x00000000;
static NSUInteger kColorGray = 0x555555FF;
static NSUInteger kColorGrayMiddle = 0xB2B2B2FF;
static NSUInteger kColorNavBar = 0x000000FF;
static NSUInteger kColorNavyBlue = 0x000080FF;
static NSUInteger kColorOffBlack = 0x222222FF;
static NSUInteger kColorOffWhite = 0xDDDDDDFF;
static NSUInteger kColorStripOverlay = 0x00000099;
static NSUInteger kColorWhite = 0xFFFFFFFF;

// Geometry and metrics
static CGFloat kGeomCornerRadius = 3.0;
static NSUInteger kGeomFontSizeHeader = 16;
static NSUInteger kGeomFontSizeSubheader = 14;
static NSUInteger kGeomFontSizeDetail = 11;
static CGFloat kGeomHeightButton = 40.0;
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
