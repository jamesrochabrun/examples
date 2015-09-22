//
//  UserObject.m
//  Oomami
//
//  Created by Anuj Gujar on 7/30/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "UserObject.h"

NSString *const kKeyID = @"user_id";
NSString *const kKeyFirstName = @"first_name";
NSString *const kKeyLastName = @"last_name";
NSString *const kKeyMiddleName = @"middle_name";
NSString *const kKeyEmail = @"email";
NSString *const kKeyPhoneNumber = @"phone_number";
NSString *const kKeyToken = @"backend_auth_token";
NSString *const kKeyGender = @"gender";

@interface UserObject()
@property (nonatomic, strong) NSMutableArray *lists;

@end

@implementation UserObject

- (instancetype) init
{
    self = [super init];
    if (self) {
        _lists = [NSMutableArray array];
        ListObject *list;

        // NOTE:  these will later be stored in user defaults.
        
        list = [[ListObject alloc] init];
        list.name = @"Featured";
        list.listType = kListTypeFeatured;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Thai";
        list.listType = KListTypeStrip;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Chinese";
        list.listType = KListTypeStrip;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Vegetarian";
        list.listType = kListTypeFeatured;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Burgers";
        list.listType = KListTypeStrip;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Vietnamese";
        list.listType = KListTypeStrip;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"New";
        list.listType = kListTypeFeatured;
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Mexican";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Peruvian";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Delivery";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Date Night";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Party";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Drinks";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Mediterranean";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Steak";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Indian";
        [_lists addObject:list];
        
        list = [[ListObject alloc] init];
        list.name = @"Tandoor";
        [_lists addObject:list];
        
    }
    return self;
}

//------------------------------------------------------------------------------
// Name:    +userFromDict
// Purpose: Instantiates user object from user dictionary.
//------------------------------------------------------------------------------
+ (UserObject *)userFromDict:(NSDictionary *)dict
{
    UserObject *user =[[UserObject alloc] init];
    user.userID = [dict objectForKey:kKeyID];
    user.firstName = [dict objectForKey:kKeyFirstName];
    user.middleName = [dict objectForKey:kKeyMiddleName];
    user.lastName = [dict objectForKey:kKeyLastName];
    user.email = [dict objectForKey:kKeyEmail];
    user.phoneNumber = [dict objectForKey:kKeyPhoneNumber];
    user.backendAuthorizationToken = [dict objectForKey:kKeyToken];
    user.gender = [dict objectForKey:kKeyGender];

    return user;
}

//------------------------------------------------------------------------------
// Name:    dictionaryFromUser
// Purpose: Provides dict from user object.
//------------------------------------------------------------------------------
- (NSDictionary*) dictionaryFromUser;
{
    return @{
             kKeyID : self.userID ?: @"",
             kKeyMiddleName:self.middleName ?: @"",
             kKeyFirstName:self.firstName ?: @"",
             kKeyLastName:self.lastName ?: @"",
             kKeyEmail: self.email ?: @"",
             kKeyPhoneNumber:self.phoneNumber ?: @"",
             kKeyToken:self.backendAuthorizationToken ?: @"",
             kKeyGender:self.gender ?: @""
             };
}

- (NSMutableArray*) lists;
{
    return _lists;
}

- (void) addList: (ListObject*) list;
{
    if (! list) {
        return;
    }
    [self.lists  addObject: list];
}

@end
