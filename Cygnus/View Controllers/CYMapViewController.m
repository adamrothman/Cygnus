//
//  CYMapViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapViewController.h"
#import "CYPointCreationViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "CYMap+Additions.h"
#import "CYUser+Additions.h"
#import "CYPoint+Additions.h"
#import "CYUI.h"
#import "CYMapView.h"
#import "AwesomeMenuItem.h"

CYMapViewController *_currentVC;

#define THRESHOLD_DISTANCE               70
#define ONE_MILE_IN_METERS              1609.34
#define SIGNIFICANT_LOCATION_CHANGE     ONE_MILE_IN_METERS/4
#define HALF_HOUR_IN_SECONDS            60*30
#define UPDATE_FREQUENCY                3*60

@interface CYMapViewController ()

@property (nonatomic, strong) id<MKAnnotation> userPointAnnotation;
@property (nonatomic) BOOL hasPerformedInitialZoom;

@end

@implementation CYMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _currentVC = self;

  self.pointCreationView.delegate = self;
  [self setUpAwesomeMenu];

  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
  longPress.cancelsTouchesInView = NO;
  [self.mapView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.hidden = YES;
  [self.mapView removeAnnotations:self.mapView.annotations];
  [self.mapView updatePointsForMap:[CYUser user].activeMap animated:NO];
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:YES];

  self.activeMapLabel.text = [CYUser user].activeMap ? [NSString stringWithFormat:@"Displaying %@", [CYUser user].activeMap.name] : @"No active map";
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_MAP_VISIT withParameters:nil];

  if (!self.pointCreationView.framesSet) {
    self.pointCreationView.onscreenFrame = self.pointCreationView.frame;
    NSLog(@"%@", NSStringFromCGRect(self.pointCreationView.onscreenFrame));
    self.pointCreationView.offscreenFrame = CGRectMake(self.pointCreationView.frame.origin.x, -(self.pointCreationView.frame.size.height + 10), self.pointCreationView.frame.size.width, self.pointCreationView.frame.size.height);
    NSLog(@"%@", NSStringFromCGRect(self.pointCreationView.offscreenFrame));
    self.pointCreationView.framesSet = YES;
  }
  [self.pointCreationView dismissAnimated:NO completion:nil];

  self.menu.startPoint = CGPointMake(self.mapView.bounds.size.width - 32, self.mapView.bounds.size.height - 32);
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationController.navigationBar.hidden = NO;
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
    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil]
  ];

  self.menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:menus];
  self.menu.menuWholeAngle = M_PI_2;
  self.menu.rotateAngle = -M_PI_2;
  self.menu.delegate = self;
  [self.view addSubview:self.menu];
}

#pragma mark - UI

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan || ![CYUser user].activeMap) return;

  CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[recognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
  self.userPointAnnotation = [[MKPointAnnotation alloc] init];
  self.userPointAnnotation.coordinate = coordinate;
  [self.mapView addAnnotation:self.userPointAnnotation];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_USER_DROPPED_POINT withParameters:nil];

  [self.pointCreationView summonAnimated:YES completion:^(BOOL finished) {
    if (finished) [self.pointCreationView.nameTextField becomeFirstResponder];
  }];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  if (!self.hasPerformedInitialZoom) {
    [mapView zoomToFitUserAnimated:YES];
    self.hasPerformedInitialZoom = YES;
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
  MKPinAnnotationView *pinView = nil;
  static NSString *defaultPin=@"default-pin";
  pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPin];
  if (annotation == self.userPointAnnotation) {
    pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.canShowCallout = NO;
  } else { //Map point annotation
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    pinView.animatesDrop = NO;

    //    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //    [rightButton addTarget:self
    //                    action:@selector(showDetails:)
    //          forControlEvents:UIControlEventTouchUpInside];
    //    pinView.rightCalloutAccessoryView = rightButton;

    //    UIImageView *sfIconView = [[UIImageView alloc] init];
    //    pinView.leftCalloutAccessoryView = sfIconView;

  }
  return pinView;
}

#pragma mark - CYPointCreationDelegate

- (void)pointCreationView:(CYPointCreationView *)view didSave:(UIButton *)sender {
  CYPoint *point = [CYPoint pointWithName:view.nameTextField.text summary:view.summaryTextView.text imageURLString:@"" location:self.userPointAnnotation.coordinate map:[CYUser user].activeMap context:[CYAppDelegate mainContext] save:YES];
  [self.mapView addAnnotation:point];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_USER_ADDED_POINT withParameters:nil];

  [self.mapView removeAnnotation:self.userPointAnnotation];
  self.userPointAnnotation = nil;
  [self.pointCreationView endEditing:NO];

  [view dismissAnimated:YES completion:nil];
}

- (void)pointCreationView:(CYPointCreationView *)view didCancel:(UIButton *)sender {
  [self.mapView removeAnnotation:self.userPointAnnotation];
  self.userPointAnnotation = nil;
  [self.pointCreationView endEditing:NO];

  [view dismissAnimated:YES completion:nil];
}

#pragma mark - AwesomeMenuDelegate

- (void)menu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
  //  NSLog(@"Selected index %d", idx);
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

#pragma mark - CYTabBar

+ (CYMapViewController *)currentVC {
  return _currentVC;
}

@end
