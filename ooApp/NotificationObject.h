//
//  NotificationObject.h
//  ooApp
//
//  Created by Anuj Gujar on 12/23/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNotificationTypeViewUser = 1,
    kNotificationTypeViewEvent = 2,
    kNotificationTypeViewList = 3,
    kNotificationTypeViewRestaurant = 4,
    kNotificationTypeViewMediaItem = 5
} NotificationObjectType;

extern NSString *const kKeyNotificationType;
extern NSString *const kKeyNotificationID;

@interface NotificationObject : NSObject

@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, assign) NotificationObjectType type;

@end
