//
//  OOActivityItemProvider.m
//  ooApp
//
//  Created by Anuj Gujar on 10/27/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOActivityItemProvider.h"

@implementation OOActivityItemProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    
    NSString *title = _restaurant.name;
    NSString *itemType;
    if (_list) {
        itemType = @"list";
    } else if (_restaurant) {
        itemType = @"restaurant";
    } else {
        itemType = @"";
    }
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSString *iTunesLink = [NSString stringWithFormat:@"Check out \"%@\" on Oomami - %@", title, @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
        return iTunesLink;
    } else if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        NSString *iTunesLink = [NSString stringWithFormat:@"Check out \"%@\" on Oomami - %@", title, @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
        return iTunesLink;
    } else if ( [activityType isEqualToString:UIActivityTypeMessage] ) {
        NSString *iTunesLink = [NSString stringWithFormat:@"Check out \"%@\" on Oomami - %@", title, @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
        return iTunesLink;
    } else if ( [activityType isEqualToString:UIActivityTypeMail] ) {
        NSString *iTunesLink = [NSString stringWithFormat:@"Check out \"%@\" on Oomami - %@", title, @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
        return iTunesLink;
    }
    return nil;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

@end
