//
//  SpecialtyObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "SpecialtyObject.h"

@implementation SpecialtyObject


+ (instancetype)specialtyFromDictionary:(NSDictionary *)dictionary;
{
    if  (!dictionary) {
        return nil;
    }
    
    SpecialtyObject *object = [[SpecialtyObject alloc] init];
    object.specialtyID= parseIntegerOrNullFromServer( dictionary[@"specialty_id"]);
    object.userID = parseIntegerOrNullFromServer( dictionary[@"user_id"]);
    object.name = parseStringOrNullFromServer( dictionary[@"name"]);
    object.createdAt=  parseUTCDateFromServer(dictionary[@"created_at"]);
    object.updatedAt=  parseUTCDateFromServer(dictionary[@"updated_at"]);
    
    return object;
}

@end

