//
//  AddCaptionToMIOVC.m
//  ooApp
//
//  Created by Anuj Gujar on 1/3/16.
//  Copyright © 2016 Oomami Inc. All rights reserved.
//

#import "AddCaptionToMIOVC.h"
#import "OOAPI.h"

@interface AddCaptionToMIOVC ()

@end

@implementation AddCaptionToMIOVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nto = [[NavTitleObject alloc] initWithHeader:@"Add a Caption" subHeader:@""];
    self.navTitle = self.nto;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)post:(UIButton *)sender
{
    __weak AddCaptionToMIOVC *weakSelf = self;
    [OOAPI setMediaItemCaption:_mio.mediaItemId
                       caption:[self text]
                       success:^{
        [weakSelf.delegate textEntryFinished:[self text]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)setMio:(MediaItemObject *)mio {
    if (_mio == mio) return;
    _mio = mio;
    self.defaultText = mio.caption;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
