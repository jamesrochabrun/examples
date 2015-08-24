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
#define UIColorRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 blue:((float)((rgbValue & 0x0000FF00) >> 8))/255.0 alpha:1.0]

#define UIColorRGBA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 blue:((float)((rgbValue & 0x0000FF00) >> 8))/255.0 alpha:(rgbValue & 0x000000FF)/255.0]

// App colors
#define kColorBlack     0x000000FF
#define kColorClear 0x00000000
#define kColorGray      0x555555FF
#define kColorGrayMiddle 0xB2B2B2FF
#define kColorWhite     0xFFFFFFFF

// Geometry and metrics
static CGFloat kGeomHeightButton = 40.0;
static CGFloat kGeomSpaceEdge = 10.0;
static CGFloat kGeomSpaceInter = 10.0;
static CGFloat kGeomCornerRadius = 3.0;

// Custom Fonts
extern NSString *const kFontIcons;
extern NSString *const kFontSFTextRegular;
extern NSString *const kFontSFTextLight;

// Icon font mappings
extern NSString *const kFontIconExplore;
extern NSString *const kFontIconMeet;
extern NSString *const kFontIconInbox;
extern NSString *const kFontIconLike;
extern NSString *const kFontIconShare;
extern NSString *const kFontIconAddToList;
extern NSString *const kFontIconHeart;
extern NSString *const kFontIconFacebook;


#endif
