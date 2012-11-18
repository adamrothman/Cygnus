//
//  CYMapsTableViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapsTableViewController.h"
#import "CYMapDetailViewController.h"
#import "CYMap+Additions.h"
#import "CYAppDelegate.h"
#import "CYMapsTableViewCell.h"
#import "CYUser+Additions.h"
#import "CYMapCreationViewController.h"

@interface CYMapsTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, weak) CYMapsTableViewCell *activeMapCell;

@end

@implementation CYMapsTableViewController

// need to do this to avoid collision with UIViewController property
@synthesize searchDisplayController=__searchDisplayController;

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self.refreshControl selector:@selector(endRefreshing) name:NSManagedObjectContextDidSaveNotification object:[CYAppDelegate mainContext]];

  [self setUpFetchedResultsController];
  [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  [self setUpSearchBar];
  self.searchResults = [NSMutableArray array];

  // add a swipe recognizer to change follow state
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
  [self.tableView addGestureRecognizer:longPress];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_SEARCH_VISIT withParameters:nil];
}

#pragma mark - Fetch and search setup

- (void)setUpFetchedResultsController {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYMap class]) inManagedObjectContext:[CYAppDelegate mainContext]];
  request.fetchBatchSize = 50;
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CYAppDelegate mainContext] sectionNameKeyPath:nil cacheName:nil];
  self.fetchedResultsController.delegate = self;
  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Error performing fetch for CYMapsTableViewController: %@ %@", error.localizedDescription, error.userInfo);
  }
}

- (void)setUpSearchBar {
  self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
  self.tableView.tableHeaderView = self.searchBar;

  self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
  self.searchDisplayController.searchResultsDataSource = self;
  self.searchDisplayController.searchResultsDelegate = self;
  self.searchDisplayController.delegate = self;
}

#pragma mark - UI

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"CYMapDetailViewController_Segue"]) {
    CYMapDetailViewController *vc = (CYMapDetailViewController *)segue.destinationViewController;
    vc.map = (CYMap*)sender;
  }
}

- (IBAction)refresh:(UIRefreshControl *)sender {
  [CYMap fetchMapsWithSuccess:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.refreshControl endRefreshing];
    });
  }];
}

- (IBAction)addMap:(UIBarButtonItem *)sender {
  [CYAnalytics logEvent:CYANALYTICS_EVENT_MAP_CREATE_SELECTED withParameters:nil];
  QRootElement *root = [CYMapCreationViewController rootElement];
  CYMapCreationViewController *creationViewController = (CYMapCreationViewController *)[QuickDialogController controllerForRoot:root];
  creationViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  [self.navigationController pushViewController:creationViewController animated:YES];
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateRecognized) return;

  NSLog(@"long press");

  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
  CYMapsTableViewCell *cell = (CYMapsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

  if ([CYUser user].activeMap != cell.map) {
    // restore the old one
    self.activeMapCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // make the new one active
    [CYUser user].activeMap = cell.map;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.activeMapCell = cell;
    NSLog(@"%@ becoming active", cell.map.name);
  } else {
    // clear active state
    [CYUser user].activeMap = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.activeMapCell = nil;
    NSLog(@"%@ becoming inactive", cell.map.name);
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.tableView) {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
  } else {
    return self.searchResults.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *identifier = @"MapsTableViewCell";
  CYMapsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
  // [cell.imageView cancelImageRequestOperation];
  CYMap *map = nil;
  if (tableView == self.tableView) {
    map = [self.fetchedResultsController objectAtIndexPath:indexPath];
  } else {
    map = self.searchResults[indexPath.row];
  }
  cell.map = map;
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CYMap *map = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [self performSegueWithIdentifier:@"CYMapDetailViewController_Segue" sender:map];
}

#pragma mark - UISearchDisplayDelegate

- (void)filterMapsForSearch:(NSString *)searchString {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYMap class]) inManagedObjectContext:[CYAppDelegate mainContext]];
  request.predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or summary contains[cd] %@", searchString, searchString];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

  NSError *error = nil;
  NSArray *fetchedObjects = [[CYAppDelegate mainContext] executeFetchRequest:request error:&error];
  if (error) {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Couldn't filter maps for string %@.", searchString];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
  }

  [self.searchResults removeAllObjects];
  [self.searchResults addObjectsFromArray:fetchedObjects];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterMapsForSearch:searchString];
  return YES;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  UITableView *tableView = self.tableView;
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeUpdate:
      ((CYMapsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).map = [self.fetchedResultsController objectAtIndexPath:indexPath];
      break;
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
