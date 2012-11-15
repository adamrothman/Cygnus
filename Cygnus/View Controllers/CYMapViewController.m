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

@property (weak, nonatomic)       IBOutlet CYMapView *mapView;
@property (strong, nonatomic)     CYPointCreationViewController *pointCreationVC;
@end

@implementation CYMapViewController

#pragma mark - CYMapEditorDelegate

- (void)userDidDropPoint:(id<MKAnnotation>)newPointAnnotation
{
  QRootElement *root = [CYPointCreationViewController rootElement];
  self.pointCreationVC = (CYPointCreationViewController *)[QuickDialogController controllerForRoot:root];
  [self presentSemiViewController:self.pointCreationVC withOptions:@{
  KNSemiModalOptionKeys.pushParentBack    : @(YES),
  KNSemiModalOptionKeys.animationDuration : @(0.3),
  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
  }];
}

#pragma mark - Actions, Gestures, Notification Handlers

#pragma mark - VC Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  _currentVC = self;
  self.mapView.editorDelegate = self;
  
  // You can optionally listen to notifications
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
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.mapView updatePointsForMap:[CYUser user].activeMap animated:NO];
  if (!self.mapView.userDidInteract) [self.mapView zoomToFitAnnotationsAnimated:YES]; // basically on first load zoom otherwise leave map alone.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self setMapView:nil];
  _currentVC = nil;
}

#pragma mark - Optional notifications

- (void) semiModalResized:(NSNotification *) notification {
  if(notification.object == self){
    NSLog(@"The view controller presented was been resized");
  }
}

- (void)semiModalPresented:(NSNotification *) notification {
  if (notification.object == self) {
    NSLog(@"This view controller just shown a view with semi modal annimation");
  }
}
- (void)semiModalDismissed:(NSNotification *) notification {
  if (notification.object == self) {
    NSLog(@"A view controller was dismissed with semi modal annimation");
  }
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


+ (CYMapViewController *)currentVC
{
  return _currentVC;
}

@end
//
//PFQuery *mapQuery = [PFQuery queryWithClassName:@"Map"];
//[mapQuery whereKey:@"objectId" equalTo:@"Y5gEmr6b3d"];
//CYMap __block *map = [CYMap mapWithObject:[mapQuery getObjectWithId:@"Y5gEmr6b3d"]];
//PFQuery *pointQuery = [PFQuery queryWithClassName:@"Point"];
//[pointQuery whereKey:@"map" matchesQuery:mapQuery];
//[pointQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//  for (PFObject *object in objects) {
//    [map addPoint:[CYPoint pointWithObject:object]];
//  }
//}];



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
