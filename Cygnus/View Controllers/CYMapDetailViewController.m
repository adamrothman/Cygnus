//
//  CYMapDetailViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/9/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapDetailViewController.h"
#import "CYPointDetailViewController.h"
#import "CYMap.h"
#import "CYPoint+Additions.h"
#import "CYUser+Additions.h"
#import "MKMapView+ARKit.h"
#import "CYUI.h"
#import "CYMapView.h"

@interface CYMapDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CYMapDetailViewController

#pragma mark - VC Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  int height = self.navigationController.navigationBar.frame.size.height;
  int width = self.navigationController.navigationBar.frame.size.width;
  UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  navLabel.text = self.map.name;
  navLabel.backgroundColor = [UIColor clearColor];
  navLabel.textColor = [UIColor whiteColor];
  navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  navLabel.font = [UIFont fontWithName:@"Code Light" size:22];
  navLabel.textAlignment = UITextAlignmentCenter;
  self.navigationItem.titleView = navLabel;
  [navLabel sizeToFit];
  [navLabel alignHorizontally:UIViewHorizontalAlignmentCenter];
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:nil action:nil];

  self.mapView.map = self.map;
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];
  self.mapContainerView.layer.cornerRadius = 3.0f;
  [self setUpFetchedResultsController];

  //  self.headerContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
  //  self.nameLabel.text = [NSString stringWithFormat:@"%@ (%d)", self.map.name, self.map.points.count];
  //  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  //  [df setDateFormat:@"MM.dd.YY"];
  //  self.lastUpdatedValueLabel.text = [df stringFromDate:self.map.updatedAt];
  //  [self.lastUpdatedLabel setFont:[UIFont fontWithName:@"CODE Light" size:9]];
  //  [self.lastUpdatedValueLabel setFont:[UIFont fontWithName:@"accent" size:9]];
  //  [self.lastUpdatedLabel sizeToFit];
  //  [self.lastUpdatedValueLabel sizeToFit];
  //
  //  [self.nameLabel setFont:[UIFont fontWithName:@"CODE Bold" size:17]];
  //  [self.nameLabel sizeToFit];
  //  self.followButton.transform = CGAffineTransformIdentity;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];
  [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventMapDetailVisited withParameters:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"CYPointDetailViewController_Segue"]) {
    CYPointDetailViewController *destination = segue.destinationViewController;
    destination.navigationItem.rightBarButtonItem = nil;
    CYPoint *point = nil;
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
      point = ((MKAnnotationView *)sender).annotation;
    } else {
      point = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    }
    destination.point = point;
  }
}

#pragma mark - Fetch setup

- (void)setUpFetchedResultsController {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYPoint class]) inManagedObjectContext:[CYAppDelegate mainContext]];
  request.predicate = [NSPredicate predicateWithFormat:@"map.unique like %@", self.map.unique];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
  request.fetchBatchSize = 50;
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CYAppDelegate mainContext] sectionNameKeyPath:nil cacheName:nil];
  self.fetchedResultsController.delegate = self;
  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Error performing fetch for CYMapDetailViewController: %@ %@", error.localizedDescription, error.userInfo);
  }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (annotation == mapView.userLocation) return nil;

  static NSString *identifier = @"CYMapDetailViewControllerPin";
  MKAnnotationView *view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
  if (!view) view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
  view.canShowCallout = YES;
  [view setImage:[UIImage imageNamed:@"grayPin.png"]];\
  view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
  return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  [self performSegueWithIdentifier:@"CYPointDetailViewController_Segue" sender:view];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"CYPointDetailViewController_Segue" sender:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
  return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *identifier = @"CYMapDetailViewControllerCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

  CYPoint *point = [self.fetchedResultsController objectAtIndexPath:indexPath];

  cell.textLabel.font = [UIFont fontWithName:@"Fabrica" size:15];
  cell.textLabel.text = point.name;
  return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      self.mapView.map = self.map;
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeDelete:
      self.mapView.map = self.map;
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeUpdate:
      self.mapView.map = self.map;
      [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text = ((CYPoint *)[self.fetchedResultsController objectAtIndexPath:indexPath]).name;
      break;
    case NSFetchedResultsChangeMove:
      self.mapView.map = self.map;
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
  [self.tableView endUpdates];
}

@end
