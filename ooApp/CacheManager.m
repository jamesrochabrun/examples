//
//  CacheManager.m
//  Oomami
//
//  Created by Zack on 9/1/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CacheManager.h"
#import "UserObject.h"

NSString *const kImageListingFileName=  @"images.plist";
NSString *const kRestaurantListingFileName=  @"restaurants.plist";

@interface CacheManager ()
@property (nonatomic,retain) NSMutableDictionary * images;
@property (nonatomic,retain) NSMutableDictionary * restaurants;
@end

@implementation CacheManager

//------------------------------------------------------------------------------
// Name:    +sharedInstance
// Purpose: Provides the singleton instance.
//------------------------------------------------------------------------------
+ (instancetype) sharedInstance;
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)  init
{
    self= [super init];
    if  (self) {
        _images= [NSMutableDictionary new];
        _restaurants= [NSMutableDictionary new];
    }
    return self;
}

- (void) dealloc
{
    self.images= nil;
    self.restaurants= nil;
}

- (NSString*) getDirectoryPath;
{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return directory;
}

- (unsigned long) totalAssets;
{
    return self.images.count + self.restaurants.count;
}

- (NSArray*) lookupImagesByRestaurant: (NSString*)identifier;
{
    
    return nil;
}

- (NSArray*) lookupRestaurantsByLocation: (CLLocationCoordinate2D) location  radius: (float) radius;
{
    return nil;
}

- (void) addImage:(UIImage*) image withMetadata: (NSDictionary*)metadata
{
    if (!metadata) {
        return;
    }
    NSString *identifier= metadata[ @"id"];
    if  (! identifier) {
        return;
    }
    
    NSString *checksum=  metadata[ @"checksum"];
    
    // XX  need to generate this checksum somewhere else
    if  (!checksum) {
        checksum= [NSString stringWithFormat: @"%lu", (unsigned long) image.hash ];
    }
    
    NSData *data= UIImagePNGRepresentation (image);
    NSString *path =  [self getDirectoryPath];
    path=  [path stringByAppendingFormat: @"/%@.png", checksum ];
    [data writeToFile:path atomically:YES];

    self.images[identifier]= metadata;
}

- (void) addRestaurant: (NSDictionary*)metadata;
{
    if (!metadata) {
        return;
    }
    NSString *identifier= metadata[ @"id"];
    if  (! identifier) {
        return;
    }
    self.restaurants[identifier]=metadata;
}

//------------------------------------------------------------------------------
// Name:    saveListings
//------------------------------------------------------------------------------
- (void)  saveListings
{
    NSString *path =  [self getDirectoryPath];
    
    NSString *rpath=  [path stringByAppendingFormat: @"/%@", kRestaurantListingFileName ];
    [self.restaurants writeToFile:rpath atomically:YES ];

    NSString *ipath=  [path stringByAppendingFormat: @"/%@", kImageListingFileName ];
    [self.images writeToFile:ipath atomically:YES ];

}

//------------------------------------------------------------------------------
// Name:    removeRestaurants
//------------------------------------------------------------------------------
- (void) removeRestaurants
{
    NSString *path =  [self getDirectoryPath];
    NSString *rpath=  [path stringByAppendingFormat: @"/%@", kRestaurantListingFileName ];
    unlink (rpath.UTF8String);
}

//------------------------------------------------------------------------------
// Name:    removeImages
//------------------------------------------------------------------------------
- (void) removeImages
{
    // XX need to remove individual PNG files's
    NSString *path =  [self getDirectoryPath];
    NSString *ipath=  [path stringByAppendingFormat: @"/%@", kImageListingFileName ];
    unlink (ipath.UTF8String);
}

//------------------------------------------------------------------------------
// Name:    removeAll
//------------------------------------------------------------------------------
- (void) removeAll
{
    [self removeImages];
    [self removeRestaurants];
}

//------------------------------------------------------------------------------
// Name:    updateRestaurants
//------------------------------------------------------------------------------
- (void) updateRestaurants
{
    
}

//------------------------------------------------------------------------------
// Name:    updateImages
//------------------------------------------------------------------------------
- (void) updateImages
{
    
}


@end







