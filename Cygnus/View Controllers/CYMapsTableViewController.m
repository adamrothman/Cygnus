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
#import "CYMapCreationTableViewController.h"
#import "CYUI.h"

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

- (void)viewDidLoad {
  [super viewDidLoad];
  int height = self.navigationController.navigationBar.frame.size.height;
  int width = self.navigationController.navigationBar.frame.size.width;
  UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  navLabel.text = @"Maps";
  navLabel.backgroundColor = [UIColor clearColor];
  navLabel.textColor = [UIColor whiteColor];
  navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  navLabel.font = [UIFont fontWithName:@"Code Light" size:27];
  navLabel.textAlignment = UITextAlignmentCenter;
  self.navigationItem.titleView = navLabel;
  [navLabel sizeToFit];
  [navLabel alignHorizontally:UIViewHorizontalAlignmentCenter];

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
  [CYAnalytics logEvent:CYAnalyticsEventMapsVisited withParameters:nil];
}

#pragma mark - Fetch and search setup

- (void)setUpFetchedResultsController {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYMap class]) inManagedObjectContext:[CYAppDelegate mainContext]];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
  request.fetchBatchSize = 50;
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
    CYMapDetailViewController *destination = segue.destinationViewController;
    destination.map = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
  } else if ([segue.identifier isEqualToString:@"CYMapCreationTableViewController_Segue"]) {
    [CYAnalytics logEvent:CYAnalyticsEventMapCreateSelected withParameters:nil];
  }
}

- (IBAction)refresh:(UIRefreshControl *)sender {
  [CYMap fetchMapsWithSuccess:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.refreshControl endRefreshing];
    });
  }];
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateRecognized) return;

  NSLog(@"long press");

  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
  CYMapsTableViewCell *cell = (CYMapsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

  if ([CYUser activeMap] != cell.map) {
    // restore the old one
    self.activeMapCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // make the new one active
    [CYUser setActiveMap:cell.map];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.activeMapCell = cell;
    NSLog(@"%@ becoming active", cell.map.name);
  } else {
    // clear active state
    [CYUser setActiveMap:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.activeMapCell = nil;
    NSLog(@"%@ becoming inactive", cell.map.name);
  }
  [[CYAppDelegate mainContext] saveWithSuccess:nil];
}

- (IBAction)mapCreationDidSave:(UIStoryboardSegue *)segue {
  CYMapCreationTableViewController *source = segue.sourceViewController;
  if (source.nameTextField.text.length && source.summaryTextView.text.length) {
    [CYMap mapWithName:source.nameTextField.text summary:source.summaryTextView.text context:[CYAppDelegate mainContext] save:YES];
    [CYAnalytics logEvent:CYAnalyticsEventMapCreated withParameters:nil];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.tableView) {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
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
  if (map == [CYUser activeMap]) self.activeMapCell = cell;
  return cell;
}

#pragma mark - UISearchDisplayDelegate

- (void)filterMapsForQuery:(NSString *)query {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYMap class]) inManagedObjectContext:[CYAppDelegate mainContext]];
  request.predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or summary contains[cd] %@", query, query];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

  NSError *error = nil;
  NSArray *fetchedObjects = [[CYAppDelegate mainContext] executeFetchRequest:request error:&error];
  if (error) {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Couldn't filter maps for query %@.", query];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
  }

  [self.searchResults removeAllObjects];
  [self.searchResults addObjectsFromArray:fetchedObjects];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterMapsForQuery:searchString];
  return YES;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeUpdate:
      ((CYMapsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).map = [self.fetchedResultsController objectAtIndexPath:indexPath];
      break;
    case NSFetchedResultsChangeMove:
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
