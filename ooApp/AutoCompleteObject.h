//
//  AutoCompleteObject.h
//  ooApp
//
//  Created by Zack Smith on 11/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//
@interface AutoCompleteObject: NSObject
@property (nonatomic, strong) NSString* desc;
@property (nonatomic, strong) NSArray *terms;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) NSArray *matchedSubstrings;
@property (nonatomic,  strong) NSString *identifier;
@property (nonatomic,  strong) NSString *placeIdentifier;
@property (nonatomic,  strong) NSString *reference;

+ (instancetype)autoCompleteObjectFromDictionary:(NSDictionary *)dictionary;

@end

