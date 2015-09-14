//
//  Common.m: helper routines.
//  ooApp
//
//  Created by Zack Smith on 9/8/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

//NSString*const kOOURL= @"www.oomamiapp.com/api/v1";
NSString*const kOOURL= @"stage.oomamiapp.com/api/v1";

void message (NSString *str)
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: str
				message:nil
				delegate: nil
				cancelButtonTitle: @"OK" otherButtonTitles: nil ];
    [alert show];
}

NSString *getDateString()
{
    struct tm tm;
    timelocal(&tm);
    int year= tm.tm_year;
    int month= tm.tm_mon;
    int day= 1 + tm.tm_mday;
    return [NSString stringWithFormat: @"%04d/%02d/%02d",year,month,day];
}