//
//  CYMapsTableViewController.m
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapsTableViewController.h"
#import "CYMap+Additions.h"
#import "CYAppDelegate.h"

@interface CYMapsTableViewController () <UISearchDisplayDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation CYMapsTableViewController

@synthesize fetchedResultsController;

@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize searchResults;

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (NSManagedObjectContext *)context {
  return [CYAppDelegate appDelegate].managedObjectContext;
}

- (void)setUpFetchedResultsController {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYMap class]) inManagedObjectContext:self.context];
  request.fetchBatchSize = 50;
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Error performing fetch for CYMapsTableViewController: %@ %@", error.localizedDescription, error.userInfo);
  }
}

- (void)setUpSearchBar {
  self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
  self.tableView.tableHeaderView = self.searchBar;
  CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
  self.tableView.contentOffset = offset;

  self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
  self.searchDisplayController.searchResultsDataSource = self;
  self.searchDisplayController.searchResultsDelegate = self;
  self.searchDisplayController.delegate = self;
}

- (void)objectsDidChange:(NSNotification *)notification {
  [self.tableView reloadData];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[CYAppDelegate appDelegate].managedObjectContext];

  [CYMap fetchMaps];

  [self setUpFetchedResultsController];

  [self setUpSearchBar];
  self.searchResults = [NSMutableArray array];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  static NSString *identifier = @"MapTableViewCell";
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

  CYMap *map = nil;
  if (tableView == self.tableView) {
    map = [self.fetchedResultsController objectAtIndexPath:indexPath];
  } else {
    map = self.searchResults[indexPath.row];
  }

  cell.textLabel.text = map.name;
  cell.detailTextLabel.text = map.summary;

  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryNone ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchDisplayDelegate

- (void)filterMapsForSearch:(NSString *)searchString {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = [NSEntityDescription entityForName:NSStringFromClass([CYMap class]) inManagedObjectContext:self.context];
  request.predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or summary contains[cd] %@", searchString, searchString];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

  NSError *error = nil;
  NSArray *fetchedObjects = [self.context executeFetchRequest:request error:&error];
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

@end
