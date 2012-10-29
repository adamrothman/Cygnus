//
//  CYConsoleViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYConsoleViewController.h"
#import "CYUser.h"

@interface CYConsoleViewController ()

@end

@implementation CYConsoleViewController


- (IBAction)userDidLogOut:(id)sender {
  [CYUser logOut];
}


#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
