//
//  SocialMedia.m: helper routines e.g. facebook.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "SocialMedia.h"
#import "UserObject.h"
#import "Settings.h"

@implementation SocialMedia

//------------------------------------------------------------------------------
// Name:    fetchProfilePhoto
// Purpose: Get the user's photo URL from Facebook. If the URL has changed then
//          fetch the new image.
// Note:    To be put into future class e.g. SocialMediaHelpers.
//------------------------------------------------------------------------------
+ (void)fetchProfilePhotoWithCompletionBlock:(void (^)(NSString*urlString))completionBlock;
{
	[[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/picture?width=1080&height=1080&redirect=false"
		parameters: nil ]
		startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
			if (!error) {
				NSDictionary *dictionary = result;
				if (![dictionary isKindOfClass:[NSDictionary class]]) {
					if (completionBlock) completionBlock(nil);
					return;
				}

				NSLog(@"FACEBOOK USER DICTIONARY:%@", dictionary);

				NSDictionary *pictureData = dictionary[@"data"];
				if (pictureData) {
					NSString *urlString = pictureData[@"url"];
					if (urlString) {
						UserObject *userInfo = [Settings sharedInstance].userObject;
						NSString* existingURL = userInfo.facebookProfileImageURLString;
						if (!existingURL || ![existingURL isEqualToString:urlString]) {
							// RULE: Only fetch, store and upload the profile image if the URL has changed.
							userInfo.facebookProfileImageURLString = urlString;
							[[Settings sharedInstance] save];
							NSLog (@"NEW PROFILE PICTURE URL: %@", urlString); //Just save for now
						}
						if (completionBlock) completionBlock(urlString);
					} else {
						if (completionBlock) completionBlock(nil);
					}
				} else {
					if (completionBlock) completionBlock(nil);
				}
			} else {
				NSLog(@"FACEBOOK ERROR %@", error);
				if (completionBlock) completionBlock(nil);
			}
		}];
}

//------------------------------------------------------------------------------
// Name:    fetchUserFriendListFromFacebook
// Purpose:
//------------------------------------------------------------------------------
+ (void) fetchUserFriendListFromFacebook:(void (^)(NSArray*friends))completionBlock;
{
    //---------------------------------------------
    //  Make a formal request for friend information.
    //
    NSMutableString *facebookRequest = [NSMutableString new];
    [facebookRequest appendString:@"/me/friends?fields=id,name,email&limit=200"];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:facebookRequest
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection,
                                           id result, NSError *error) {
        if (error) {
            NSLog (@"FACEBOOK ERR %@",error);
            completionBlock(nil);
            return;
        }
        if (![result isKindOfClass: [NSDictionary class] ] ) {
            NSLog (@"FACEBOOK RESULT NOT ARY");
            return;
        }
        NSArray *arrayData= ((NSDictionary*)result) [@"data"];
        if ([arrayData isKindOfClass: [NSArray  class] ] ) {
            NSUInteger  total= arrayData.count;
            NSLog  (@"SUCCESSFULLY FOUND %lu FRIENDS", (unsigned long) total);
            if  (!total) {
                completionBlock ( @[] );

            } else {
                NSMutableArray* facebookIDs = [NSMutableArray new];
                for (id object in arrayData) {
                    if ([object isKindOfClass: [NSDictionary  class] ] ) {
                        
                        NSDictionary*d= (NSDictionary*)object;
                        
                        NSString *identifier= d[ @"id"];
                        NSString *name= d[ @"name"];
                        
                        NSLog (@"FOUND FRIEND %@: id=%@", name,  identifier);
                        if  (identifier ) {
                            [facebookIDs  addObject: identifier];
                        }
                    }
                }
                completionBlock ( [NSArray arrayWithArray: facebookIDs ]);
            }
        }
        
    }
     ];
}



@end
