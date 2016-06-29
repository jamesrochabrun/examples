//
//  NSString+Util.m
//  ooApp
//
//  Created by Anuj Gujar on 5/4/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

// https://developers.facebook.com/blog/post/2012/02/21/improving-app-distribution-on-ios/

- (NSDictionary *)parseURLParams {
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (NSString *)stringWithAlphaNumericAndHyphens {
    NSMutableCharacterSet *charactersToRemove = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToRemove addCharactersInString:@" "];
    
    NSString *strippedReplacement = [[self componentsSeparatedByCharactersInSet:[charactersToRemove invertedSet]] componentsJoinedByString:@""];
    strippedReplacement = [strippedReplacement stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    return [strippedReplacement stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

@end
