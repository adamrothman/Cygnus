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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.titleTextField) {
    [self.descriptionTextField becomeFirstResponder];
    return YES;
  } else {
    [self releaseFirstResponders];
    return YES;
  }
}

- (void)releaseFirstResponders
{
  [self.titleTextField resignFirstResponder];
  [self.descriptionTextField resignFirstResponder];
}


- (IBAction)addPointSelected:(id)sender {
  if (![self.titleTextField.text length]) {
    [self.titleTextField becomeFirstResponder];
    return;
  } else if (![self.descriptionTextField.text length]) {
    [self.descriptionTextField becomeFirstResponder];
    return;
  }

  [self releaseFirstResponders];

  //do all the things.
  CYPoint *localPoint = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CYPoint class]) inManagedObjectContext:[CYAppDelegate appDelegate].managedObjectContext];
  localPoint.name = self.titleTextField.text;
  localPoint.summary = self.descriptionTextField.text;
  localPoint.latitude = @(self.userPointAnnotation.coordinate.latitude);
  localPoint.longitude = @(self.userPointAnnotation.coordinate.longitude);

  PFObject *point = [PFObject objectWithClassName:PointClassName];
  [point setObject:localPoint.name forKey:PointNameKey];
  [point setObject:localPoint.summary forKey:PointSummaryKey];
  PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.userPointAnnotation.coordinate.latitude longitude:self.userPointAnnotation.coordinate.longitude];
  [point setObject:geoPoint forKey:PointLocationKey];
  [point setObject:[PFObject objectWithoutDataWithClassName:MapClassName objectId:[CYUser user].activeMap.unique] forKey:@"map"];
  [point saveInBackgroundWithBlock:NULL];
  localPoint.unique = point.objectId;

  [[CYUser user].activeMap addPointsObject:localPoint];
  [self.delegate userDidAddPoint:localPoint];
}

- (IBAction)addImageSelected:(id)sender {
  //do nothing for now
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.titleTextField.delegate = self;
  self.descriptionTextField.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.titleTextField becomeFirstResponder];

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

+ (QRootElement *)rootElement
{
  return [[QRootElement alloc] initWithJSONFile:@"pointCreationDefaultScheme"];
}

@end
