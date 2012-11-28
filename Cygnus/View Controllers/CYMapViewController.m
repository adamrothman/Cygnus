//
//  CYMapViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapViewController.h"
#import "CYMap+Additions.h"
#import "CYUser+Additions.h"
#import "CYPoint+Additions.h"
#import "CYUI.h"
#import "CYMapView.h"
#import "AwesomeMenuItem.h"
#import "CYPointDetailViewController.h"

#define THRESHOLD_DISTANCE              70
#define ONE_MILE_IN_METERS              1609.34
#define SIGNIFICANT_LOCATION_CHANGE     ONE_MILE_IN_METERS/4
#define HALF_HOUR_IN_SECONDS            60*30
#define UPDATE_FREQUENCY                3*60

#define ANIMATION_DURATION              0.25

static NSString *alertKey = @"CYMapViewController alert shown";

@interface CYMapViewController ()

@property (nonatomic, strong) id<MKAnnotation> userPointAnnotation;
@property (nonatomic) BOOL hasPerformedInitialZoom;

@end

@implementation CYMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
  navLabel.text = @"CYGNUS";
  navLabel.backgroundColor = [UIColor clearColor];
  navLabel.textColor = [UIColor whiteColor];
  navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  navLabel.font = [UIFont fontWithName:@"Code Light" size:27];
  navLabel.textAlignment = UITextAlignmentCenter;
  self.navigationItem.titleView = navLabel;
  [navLabel sizeToFit];
  [navLabel alignHorizontally:UIViewHorizontalAlignmentCenter];

  [self.pointCreationView setUp];
  self.pointCreationView.delegate = self;
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
  [self.pointCreationView addGestureRecognizer:pan];

  [self setUpAwesomeMenu];

  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
  longPress.cancelsTouchesInView = NO;
  [self.mapView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
//  [[self navigationController] setNavigationBarHidden:YES animated:YES];
  self.mapView.map = [CYUser activeMap];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
//  [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventMapVisited withParameters:nil];

  if (!self.pointCreationView.framesSet) {
    self.pointCreationView.onscreenFrame = self.pointCreationView.frame;
    NSLog(@"%@", NSStringFromCGRect(self.pointCreationView.onscreenFrame));
    self.pointCreationView.offscreenFrame = CGRectMake(self.pointCreationView.frame.origin.x, -(self.pointCreationView.frame.size.height + 10), self.pointCreationView.frame.size.width, self.pointCreationView.frame.size.height);
    NSLog(@"%@", NSStringFromCGRect(self.pointCreationView.offscreenFrame));
    self.pointCreationView.framesSet = YES;
  }
  [self.pointCreationView dismissWithDuration:0 completion:nil];

  self.menu.startPoint = CGPointMake(self.mapView.bounds.size.width - 32, self.mapView.bounds.size.height - 32);

  [self.mapView zoomToFitAnnotationsWithUser:NO animated:YES];

  if (![[NSUserDefaults standardUserDefaults] boolForKey:alertKey]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atlas" message:@"Points for the active map are displayed here. To add a point, press and hold on the map in the desired location.\n\nYou can dismiss the input tray by swiping it offscreen." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
    [alert show];
  }
}

- (void)setUpAwesomeMenu {
  UIImage *background = [UIImage imageNamed:@"bg-menuitem.png"];
	UIImage *backgroundHighlighted = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
  UIImage *eye = [UIImage imageNamed:@"04-eye-white.png"];
  UIImage *pin = [UIImage imageNamed:@"08-pin-white.png"];
  UIImage *star = [UIImage imageNamed:@"icon-star.png"];

  NSArray *menus = @[
  [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:eye highlightedContentImage:nil],
  [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:pin highlightedContentImage:nil],
  [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
//  [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil]
  ];

  self.menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:menus];
  self.menu.menuWholeAngle = M_PI_2;
  self.menu.rotateAngle = -M_PI_2;
  self.menu.delegate = self;
  [self.view addSubview:self.menu];
}

#pragma mark - UI

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"CYPointDetailViewController_Segue"]) {
    UINavigationController *destination = segue.destinationViewController;
    CYPointDetailViewController *pointDetailViewController = (CYPointDetailViewController *)destination;
    CYPoint *point = ((MKAnnotationView *)sender).annotation;
    pointDetailViewController.point = point;
  }
}

- (IBAction)pointDetailDone:(UIStoryboardSegue *)segue {
  // pass
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan || ![CYUser activeMap]) return;

  CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[recognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
  self.userPointAnnotation = [[MKPointAnnotation alloc] init];
  self.userPointAnnotation.coordinate = coordinate;
  [self.mapView addAnnotation:self.userPointAnnotation];
  [CYAnalytics logEvent:CYAnalyticsEventPointDropped withParameters:nil];

  [self.pointCreationView.nameTextField becomeFirstResponder];
  [self.pointCreationView summonWithDuration:ANIMATION_DURATION completion:^(BOOL finished) {
    [self.mapView zoomToFitAnnotation:self.userPointAnnotation animated:YES];
  }];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGRect frame = self.pointCreationView.frame;
    frame.origin.y += [recognizer translationInView:self.view].y;
    self.pointCreationView.frame = frame;

    [recognizer setTranslation:CGPointZero inView:self.view];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    if (self.pointCreationView.frame.origin.y <= 0.f) {
      [self.mapView removeAnnotation:self.userPointAnnotation];
      self.userPointAnnotation = nil;
      [self.pointCreationView endEditing:NO];
      [self.pointCreationView dismissWithDuration:ANIMATION_DURATION completion:nil];
    } else {
      [self.pointCreationView summonWithDuration:ANIMATION_DURATION completion:nil];
    }
    [recognizer setTranslation:CGPointZero inView:self.view];
  }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  if (!self.hasPerformedInitialZoom) {
    [mapView zoomToFitUserAnimated:YES];
    self.hasPerformedInitialZoom = YES;
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (annotation == mapView.userLocation) return nil;

  static NSString *identifier = @"CYMapViewControllerPin";
  MKAnnotationView *view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
  if (!view) view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

  if (annotation == self.userPointAnnotation) {
//    view.pinColor = MKPinAnnotationColorGreen;
    [view setImage:[UIImage imageNamed:@"greenPin.png"]];
    view.canShowCallout = NO;
  } else {
    [view setImage:[UIImage imageNamed:@"grayPin.png"]];
    view.canShowCallout = YES;
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
  }

  return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  [self performSegueWithIdentifier:@"CYPointDetailViewController_Segue" sender:view];
}

#pragma mark - CYPointCreationDelegate

- (void)pointCreationView:(CYPointCreationView *)view didSave:(UIButton *)sender {
  if (!(view.nameTextField.text.length && view.summaryTextView.text.length)) return;

  CYPoint *point = [CYPoint pointWithName:view.nameTextField.text summary:view.summaryTextView.text imageURLString:@"" location:self.userPointAnnotation.coordinate map:[CYUser activeMap] context:[CYAppDelegate mainContext] save:YES];
  [self.mapView addAnnotation:point];
  [CYAnalytics logEvent:CYAnalyticsEventPointCreated withParameters:nil];

  [self.mapView removeAnnotation:self.userPointAnnotation];
  self.userPointAnnotation = nil;
  [self.pointCreationView endEditing:NO];

  [view dismissWithDuration:ANIMATION_DURATION completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.pointCreationView.summaryTextView becomeFirstResponder];
  return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
  [textView setNeedsDisplay];
}

#pragma mark - AwesomeMenuDelegate

- (void)menu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
  switch (idx) {
    case 0:
      NSLog(@"Awesome menu button 0");
      [self.mapView zoomToFitUserAnimated:YES];
      break;
    case 1:
      NSLog(@"Awesome menu button 1");
      [self.mapView zoomToFitAnnotationsWithUser:NO animated:YES];
      break;
    case 2:
      NSLog(@"Awesome menu button 2");
      break;
    case 3:
      NSLog(@"Awesome menu button 3");
      break;
  }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:alertKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
