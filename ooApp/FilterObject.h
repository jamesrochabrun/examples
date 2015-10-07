//
//  FilterObject.h
//  ooApp
//
//  Created by Anuj Gujar on 10/6/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) SEL selector;
@property (nonatomic, strong) id target;

@end
