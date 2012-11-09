//
//  CYSearchViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYSearchViewController.h"
#import "CYMapDetailViewController.h"
#import "CYUser.h"
#import "CYMap.h"
#import "CYGroup.h"
  
#import "CYUI.h"

@interface CYSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)        NSOrderedSet *groups;
@property (strong, nonatomic)        NSOrderedSet *maps;


@end

@implementation CYSearchViewController


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
  return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
  return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (!section) return [self.groups count];
  return [self.maps count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (!section) return @"Groups";
  return @"Maps";
}

#define MAP_CELL                @"CYMapTableViewCell"
#define GROUP_CELL              @"CYGroupTableViewCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = (!indexPath.section) ? GROUP_CELL : MAP_CELL;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
  if (indexPath.section) {
    CYMap *map = (CYMap*)self.maps[indexPath.row];
    cell.textLabel.text = map.name;
    float hoursSinceEdit = - ([map.updatedAt timeIntervalSinceNow] / (60.0*60));
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f hr", hoursSinceEdit];
    
  } else {
    CYGroup *group = (CYGroup *)self.groups[indexPath.row];
    cell.textLabel.text = group.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group.size integerValue]];
  }
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section) {
    [self performSegueWithIdentifier:@"CYMapDetailViewController_Segue" sender:self.maps[indexPath.row]];
  }
}

#pragma mark - Convenience

- (void)releaseFirstResponders
{
  [self.searchBar resignFirstResponder];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  [UIView animateWithDuration:0.28 animations:^{
    self.searchBar.yOrigin -= (kbSize.height - self.searchBar.height) - 5;
  }];
  
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
  [UIView animateWithDuration:0.18 animations:^{
    self.searchBar.yOrigin = self.view.height - self.searchBar.height;
  }];
}


#pragma mark - VC Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.searchBar.delegate = self;
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(releaseFirstResponders)];
  tgr.cancelsTouchesInView = NO;
  [self.view addGestureRecognizer:tgr];

  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];


}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [CYGroup fetchAllGroups:^(NSSet *groups, NSError *error) {
    self.groups = [NSOrderedSet orderedSetWithSet:groups];
    [self.tableView reloadData];
  }];
  [CYMap fetchAllMaps:^(NSSet *maps, NSError *error) {
    self.maps = [NSOrderedSet orderedSetWithSet:maps];
    [self.tableView reloadData];
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"CYMapDetailViewController_Segue"]) {
    CYMapDetailViewController *vc = (CYMapDetailViewController *)segue.destinationViewController;
    vc.map = (CYMap*)sender;
  }
}

@end
