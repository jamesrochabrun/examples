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
    NSString *itemType;
    if (_list) {
        itemType = @"list";
    } else if (_restaurant) {
        if (_mio) {
            itemType = @"mediaItem";
        } else {
            itemType = @"restaurant";
        }
    } else {
        itemType = @"";
    }
    
    NSString *message, *title;
    
    if (_list) {
        message = [NSString stringWithFormat:@"I use Oomami to find great places to eat. Download it from iTunes - %@", @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];        
    } else if (_restaurant) {
        title = _restaurant.name;
        if (_mio) {
            message = [NSString stringWithFormat:@"Check out this great dish at \"%@\" on Oomami - %@", title, @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
        } else {
            message = [NSString stringWithFormat:@"Check out \"%@\" on Oomami - %@", title, @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
        }
    } else {
        message = [NSString stringWithFormat:@"I use Oomami to find great places to eat. Download it from iTunes - %@", @"itms://itunes.apple.com/us/app/apple-store/id1053373398?mt=8"];
    }
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSString *iTunesLink = message;
        return iTunesLink;
    } else if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        NSString *iTunesLink = message;
        return iTunesLink;
    } else if ( [activityType isEqualToString:UIActivityTypeMessage] ) {
        NSString *iTunesLink = message;
        return iTunesLink;
    } else if ( [activityType isEqualToString:UIActivityTypeMail] ) {
        NSString *iTunesLink = message;
        return iTunesLink;
    }
    return nil;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

@end
