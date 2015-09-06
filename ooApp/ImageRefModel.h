//
//  ImageRefModel.h
//  ooApp
//
//  Created by Anuj Gujar on 9/4/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageRefModel : NSObject

@property (nonatomic, strong) NSString *imageRef;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) NSUInteger height;
@property (nonatomic) NSUInteger width;


@end
