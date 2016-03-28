//
//  OOErrorObject.h
//  ooApp
//
//  Created by Anuj Gujar on 3/28/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyError;
extern NSString *const kKeyErrorDescription;
extern NSString *const kKeyErrorType;

@interface OOErrorObject : NSObject

@property (nonatomic, strong) NSString *errorDescription;
@property (nonatomic) NSUInteger type;

+ (OOErrorObject *)errorFromDict:(NSDictionary *)dict;

@end
