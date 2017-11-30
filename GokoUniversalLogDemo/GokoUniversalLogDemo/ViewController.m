//
//  ViewController.m
//  GokoUniversalLog
//
//  Created by Goko on 27/11/2017.
//  Copyright © 2017 Goko. All rights reserved.
//

#import "ViewController.h"
#import "GokoUniversalLog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * fooo = @"Fooo";
    NSLog(@"%@%@",fooo,[Foo new]);
    GokoLog(fooo,[Foo new], nil);
    GokoDescriptionLog(fooo,[Foo new], nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
