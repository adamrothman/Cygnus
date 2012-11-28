//
//  CYMapCreationTableViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 11/19/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapCreationTableViewController.h"
#import "CYUI.h"

@interface CYMapCreationTableViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation CYMapCreationTableViewController

- (IBAction)cancelSelected:(id)sender {
  [self dismissViewControllerAnimated:YES
                           completion:NULL];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:@"Code Light" size:27.0f], UITextAttributeFont,
                                           [UIColor whiteColor], UITextAttributeTextColor,
                                           [UIColor colorWithWhite:0.0 alpha:0.5], UITextAttributeTextShadowColor,
//                                           [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                           nil]];


  self.summaryTextView.placeholderText = @"Map summary";


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


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventMapCreateSelected withParameters:nil];
}

@end
