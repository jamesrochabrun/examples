//
//  ImageRefObject.m
//  ooApp
//
//  Created by Anuj Gujar on 9/4/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "ImageRefObject.h"

NSString *const kKeyPhotoReference = @"photo_reference";


@implementation ImageRefObject

+ (ImageRefObject *)imageRefFromDict:(NSDictionary *)dict {
    ImageRefObject *iro = [[ImageRefObject alloc] init];
    iro.reference = [dict objectForKey:kKeyPhotoReference];
    return iro;
}

@end
