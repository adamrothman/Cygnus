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

#define POINT_CELL              @"CYPointTableViewCell"
#define MAP_CELL                @"CYMapTableViewCell"
#define GROUP_CELL              @"CYGroupTableViewCell"

@interface CYMapDetailViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CYMapDetailViewController

#pragma mark - VC Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = self.map.name;

  self.mapView.map = self.map;

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
  [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];
  [CYAnalytics logEvent:CYAnalyticsEventMapDetailVisited withParameters:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"CYPointDetailViewController_Segue"]) {
    CYPointDetailViewController *destination = segue.destinationViewController;
    destination.navigationItem.rightBarButtonItem = nil;
    destination.point = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    destination.distanceLabel.text = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow].detailTextLabel.text;
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
  return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = POINT_CELL;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

  CYPoint *point = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = point.name;

  CLLocation *temp = [[CLLocation alloc] initWithCoordinate:point.coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
  float distance = [temp distanceFromLocation:self.mapView.userLocation.location];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", distance/1000];
  [cell.textLabel setFont:[UIFont fontWithName:@"CODE Light" size:17]];
  [cell.detailTextLabel setFont:[UIFont fontWithName:@"accent" size:9]];
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
