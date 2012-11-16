//
//  CYPointCreationViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointCreationViewController.h"
#import "CYUser+Additions.h"
#import "CYPoint+Additions.h"
#import "UIViewController+KNSemiModal.h"

@interface CYPointCreationViewController () <UITextFieldDelegate>

@end

@implementation CYPointCreationViewController

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.titleTextField) {
    [self.descriptionTextField becomeFirstResponder];
    return YES;
  } else {
    [self.view endEditing:YES];
    return YES;
  }
}

- (IBAction)addPointSelected:(id)sender {
  if (![self.titleTextField.text length]) {
    [self.titleTextField becomeFirstResponder];
    return;
  } else if (![self.descriptionTextField.text length]) {
    [self.descriptionTextField becomeFirstResponder];
    return;
  }

  [self.view endEditing:YES];

  // do all the things
  CYPoint *newPoint = [CYPoint pointWithName:self.titleTextField.text summary:self.descriptionTextField.text imageURLString:@"" location:self.userPointAnnotation.coordinate map:[CYUser user].activeMap context:[CYAppDelegate mainContext] save:NO];
  [self.delegate userDidAddPoint:newPoint];
}

- (IBAction)addImageSelected:(id)sender {
  // do nothing for now
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.titleTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.titleTextField.layer.borderWidth = 1.f;
  self.titleTextField.layer.cornerRadius = 4.f;
  self.titleTextField.delegate = self;

  self.descriptionTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.descriptionTextField.layer.borderWidth = 1.f;
  self.descriptionTextField.layer.cornerRadius = 4.f;
  self.descriptionTextField.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.titleTextField becomeFirstResponder];
}

+ (QRootElement *)rootElement {
  return [[QRootElement alloc] initWithJSONFile:@"pointCreationDefaultScheme"];
}

@end
