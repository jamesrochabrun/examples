//
//  NavTitleObject.h
//  ooApp
//
//  Created by Anuj Gujar on 9/15/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavTitleObject : NSObject

@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *subheader;

- (id)initWithHeader:(NSString *)header subHeader:(NSString *)subHeader;
    
@end
