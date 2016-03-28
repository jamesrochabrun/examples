//
//  OOErrorObject.m
//  ooApp
//
//  Created by Anuj Gujar on 3/28/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "OOErrorObject.h"


NSString *const kKeyErrorDescription = @"description";
NSString *const kKeyErrorType = @"type";
NSString *const kKeyError = @"error";

@implementation OOErrorObject

+ (OOErrorObject *)errorFromDict:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    //NSLog(@"dict=%@", dict);
    OOErrorObject *error = [[OOErrorObject alloc] init];
    error.errorDescription = parseStringOrNullFromServer([dict objectForKey:kKeyErrorDescription]);
    error.type = parseUnsignedIntegerOrNullFromServer([dict objectForKey:kKeyErrorType]);
    return error;
}

@end
