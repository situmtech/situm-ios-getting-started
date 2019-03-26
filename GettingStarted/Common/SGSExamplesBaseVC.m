//
//  SGSExamplesBaseVC.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 26/03/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSExamplesBaseVC.h"

@interface SGSExamplesBaseVC ()

@end

@implementation SGSExamplesBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)customizeNavigationBarWithTitle:(NSString *)title{
    self.title = title;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(exitExample:)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

#pragma mark - Exit example
-(void)exitExample:(UIBarButtonItem *)sender{
    //Default behaviour can be override by son
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
