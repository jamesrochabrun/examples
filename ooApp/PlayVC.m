//
//  PlayVC.m
//  ooApp
//
//  Created by Anuj Gujar on 7/16/15.
//  Copyright (c) 2015 Oomami Inc. All rights reserved.
//

#import "PlayVC.h"
#import "DraggableViewBackground.h"

@interface PlayVC ()

@end

@implementation PlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NavTitleObject *nto = [[NavTitleObject alloc] initWithHeader:@"Play" subHeader:@"please"];
    self.navTitle = nto;
    
    self.view = [[DraggableViewBackground alloc] initWithFrame:self.view.bounds];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
