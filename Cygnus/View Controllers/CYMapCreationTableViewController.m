//
//  CYMapCreationTableViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 11/19/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapCreationTableViewController.h"

@implementation CYMapCreationTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.summaryTextView.placeholder = @"Map summary";

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.summaryTextView becomeFirstResponder];
  return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
  [self.summaryTextView setNeedsDisplay];
}

@end
