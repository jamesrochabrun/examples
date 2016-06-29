//
//  OOActivityItemProvider.m
//  ooApp
//
//  Created by Anuj Gujar on 10/27/15.
//  Copyright © 2015 Oomami Inc. All rights reserved.
//

#import "OOActivityItemProvider.h"
#import "NSString+Util.h"


@implementation OOActivityItemProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    NSString *itemType;
    
    if (_image && [activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return nil;
    } else if (_image) {
        return _image;
    }
    
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
    
    NSString *message, *title, *urlLink;
    
    if (_list) {
        message = [NSString stringWithFormat:@"\"%@\" by @%@ on Oomami.\nhttps://%@/list/%lu",_list.name, _username, kWebAppHost, (unsigned long)_list.listID];
    } else if (_restaurant) {
        title = _restaurant.name;
        if (_mio) {
            message = [NSString stringWithFormat:@"%@ on Oomami:\nhttps://%@/restaurant//%lu", title, kWebAppHost, (unsigned long)_restaurant.restaurantID];
            urlLink = [NSString stringWithFormat:@"https://%@/restaurant/%@/%lu", kWebAppHost, [_restaurant.name stringWithAlphaNumericAndHyphens], (unsigned long)_restaurant.restaurantID];
        } else {
            message = [NSString stringWithFormat:@"%@ on Oomami:\nhttps://%@/restaurant/%@/%lu", title, kWebAppHost, [_restaurant.name stringWithAlphaNumericAndHyphens], (unsigned long)_restaurant.restaurantID];
            urlLink = [NSString stringWithFormat:@"https://%@/restaurant//%lu", kWebAppHost, (unsigned long)_restaurant.restaurantID];
        }
    } else {
//        message = [NSString stringWithFormat:@"I use Oomami to find new bars and restaurants with my friends (like you!). Check it out: https://itunes.apple.com/us/app/oomami-best-restaurants-bars/id1053373398?mt=8"];
        message = [NSString stringWithFormat:@"Get Oomami: https://%@", kWebAppHost];
        urlLink = [NSString stringWithFormat:@"https://%@", kWebAppHost];
    }
    
    //NSString *iTunesLink;
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return message;
    } else if ([activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        return message;
    } else if ([activityType isEqualToString:UIActivityTypeMessage] ) {
        return message;
    } else if ([activityType isEqualToString:UIActivityTypeMail] ) {
        return message;
    } else {
        return message;
    }
    return nil;
}

////net.whatsapp.WhatsApp.ShareExtension
//static NSString *encodeByAddingPercentEscapes(NSString *input) {
//    NSString *encodedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)input, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
//    
//    return encodedValue;
//}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

- (id)postToFacebook {
    [FBSDKSettings setAppID:@"927463500628206"];
    //NSMutableDictionary *item
    //NSArray *imagesListingArray = [[item objectForKey:@"imgs"] valueForKey:@"img"];
    //NSString * shareImage = [imagesListingArray objectAtIndex:0];

    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = @"F-Spot";
    content.contentDescription = @"description";
    //content.imageURL = [NSURL URLWithString:shareImage];

    
    return content;
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
}
@end
