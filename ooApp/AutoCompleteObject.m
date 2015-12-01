//
//  AutoCompleteObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "AutoCompleteObject.h"

@implementation AutoCompleteObject

+ (instancetype)autoCompleteObjectFromDictionary:(NSDictionary *)dictionary;
{
    if  (!dictionary) {
        return nil;
    }
    
    AutoCompleteObject *object = [[AutoCompleteObject alloc] init];
    object.desc = parseStringOrNullFromServer( dictionary[@"description"]);
    object.identifier = parseStringOrNullFromServer( dictionary[@"id"]);
    object.placeIdentifier = parseStringOrNullFromServer( dictionary[@"place_id"]);
    object.reference = parseStringOrNullFromServer( dictionary[@"reference"]);

    object.terms=  parseArrayOrNullFromServer( dictionary[ @"terms"] );
    object.types=  parseArrayOrNullFromServer( dictionary[ @"types"] );
    object.matchedSubstrings=  parseArrayOrNullFromServer( dictionary[ @"matched_substrings"] );
    
    return object;
}

@end

