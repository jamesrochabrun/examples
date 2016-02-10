//
//  SpecialtyObject.h
//  ooApp
//
//  Created by Zack Smith on 10/22/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
@interface SpecialtyObject: NSObject
@property (nonatomic,strong) NSString*name;
@property (nonatomic, assign) NSUInteger specialtyID;
@property (nonatomic, assign) NSUInteger userID;

+ (instancetype)specialtyFromDictionary:(NSDictionary *)dictionary;


@end

