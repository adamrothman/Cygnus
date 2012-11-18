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

@interface CYMapViewController () <CYMapEditorDelegate>

@property (strong, nonatomic) CYPointCreationViewController *pointCreationVC;
@property (nonatomic, strong) id<MKAnnotation> userPointAnnotation;

@end

@implementation CYMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _currentVC = self;

  // You can optionally listen to notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(semiModalPresented:)
                                               name:kSemiModalDidShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(semiModalDismissed:)
                                               name:kSemiModalDidHideNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(semiModalResized:)
                                               name:kSemiModalWasResizedNotification
                                             object:nil];

  self.mapView.delegate = self;

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
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - UI

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan || ![CYUser user].activeMap) return;

  CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[recognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
  self.userPointAnnotation = [[MKPointAnnotation alloc] init];
  self.userPointAnnotation.coordinate = coordinate;
  [self.mapView addAnnotation:self.userPointAnnotation];
  [self userDidDropPin:self.userPointAnnotation];
}

#pragma mark - Optional notifications

- (void)semiModalResized:(NSNotification *)notification {
  if(notification.object == self){
    NSLog(@"The view controller presented was been resized");
  }
}

- (void)semiModalPresented:(NSNotification *)notification {
  if (notification.object == self) {
    NSLog(@"This view controller just shown a view with semi modal annimation");
  }
}

- (void)semiModalDismissed:(NSNotification *)notification {
  if (notification.object == self) {
    [self.mapView removeAnnotation:self.userPointAnnotation];
    self.userPointAnnotation = nil;
    [self.pointCreationVC.view endEditing:YES];
  }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  MKCoordinateSpan span = MKCoordinateSpanMake(ONE_MILE_RADIUS, ONE_MILE_RADIUS);
  MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
  if (![CYUser user].activeMap) {
    if (isnan(region.center.latitude) || !CLLocationCoordinate2DIsValid(userLocation.coordinate)) return;
    [mapView setRegion:region animated:NO];
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

#pragma mark - CYMapEditorDelegate

- (void)userDidAddPoint:(CYPoint *)point {
  [self dismissSemiModalView];
  [self.mapView addAnnotation:point];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_USER_ADDED_POINT withParameters:nil];
}

- (void)userDidDropPin:(id<MKAnnotation>)userPointAnnotation {
  // get schema from map
  // QRootElement *root = [CYPointCreationViewController rootElement];
  self.userPointAnnotation = userPointAnnotation;
  self.pointCreationVC = [[CYPointCreationViewController alloc] initWithNibName:@"CYPointCreationViewController" bundle:nil];
  self.pointCreationVC.userPointAnnotation = self.userPointAnnotation;
  self.pointCreationVC.delegate = self;
  [self presentSemiViewController:self.pointCreationVC withOptions:@{
   KNSemiModalOptionKeys.pushParentBack    : @(NO),
   KNSemiModalOptionKeys.animationDuration : @(0.3),
   }];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_USER_DROPPED_POINT withParameters:nil];

  [self.pointCreationVC.titleTextField becomeFirstResponder];
}

#pragma mark - AwesomeMenuDelegate

- (void)menu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
  //  NSLog(@"Selected index %d", idx);
  switch (idx) {
    case 0:
      [self.mapView zoomToFitUserAnimated:YES];
      break;
    case 1:
      NSLog(@"Option2");
      break;
    case 2:
      NSLog(@"Option3");
      break;
    case 3:
      break;
  }
}

#pragma mark - CYTabBar

+ (CYMapViewController *)currentVC {
  return _currentVC;
}

@end

//  UIImage *background = [UIImage imageNamed:@"bg-menuitem.png"];
//	UIImage *backgroundHighlighted = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
//  UIImage *eye = [UIImage imageNamed:@"04-eye-white.png"];
//  UIImage *pin = [UIImage imageNamed:@"08-pin-white.png"];
//  UIImage *star = [UIImage imageNamed:@"icon-star.png"];

//  NSArray *menus = @[
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:eye highlightedContentImage:nil],
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:pin highlightedContentImage:nil],
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil],
//    [[AwesomeMenuItem alloc] initWithImage:background highlightedImage:backgroundHighlighted contentImage:star highlightedContentImage:nil]
//  ];
//  self.menu = [[AwesomeMenu alloc] initWithFrame:self.map.bounds menus:menus];
//  self.menu.delegate = self;
//  self.menu.menuWholeAngle = M_PI_2;
//  self.menu.rotateAngle = -M_PI_2;
//  [self.map addSubview:self.menu];

//  self.menu.startPoint = CGPointMake(self.map.bounds.size.width - 32, self.map.bounds.size.height - 32);
// this isn't useful until the user has actually been located, so
// do it after a second (this is highly scientific)
