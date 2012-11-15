//
//  CYConsoleViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYConsoleViewController.h"
#import "CYMapDetailViewController.h"
#import "CYTabBarViewController.h"
#import "CYMapCreationViewController.h"

#import "CYUser+Additions.h"
#import "CYMap+Additions.h"
#import "CYUI.h"


#define CANCEL          @"Cancel"
#define JOIN            @"Join"
#define CREATE_NEW      @"Create"
#define SEARCH          @"Search"

@interface CYConsoleViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mapsAddButton;
@property (weak, nonatomic) IBOutlet UITableView *mapsTableView;
@property (strong, nonatomic)        UIActionSheet *mapActionSheet;
@property (strong, nonatomic)        NSOrderedSet *maps;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation CYConsoleViewController

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.mapActionSheet) {
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            // do horrible things
        } else if ([choice isEqualToString:SEARCH]) {
          [self.tabBarController setSelectedIndex:2];
        } else if ([choice isEqualToString:CREATE_NEW]) {
          QRootElement *root = [CYMapCreationViewController rootElement];
          CYMapCreationViewController *myDialogController = (CYMapCreationViewController *)[QuickDialogController controllerForRoot:root];
          myDialogController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
          [self.navigationController pushViewController:myDialogController animated:YES];
        }
    }
}

#pragma mark - Actions, Gestures, Notification Handlers

- (IBAction)addMapSelected:(id)sender {
    [self.mapActionSheet showFromTabBar:self.tabBarController.tabBar];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (!section) {
    return ([CYUser user].activeMap)? 1 : 0;
  } else {
    return [self.maps count];
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (!section) {
    return @"Active";
  } else {
    return @"Following";
  }
}

#define MAP_CELL                @"CYMapTableViewCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier;
  if (tableView == self.mapsTableView)    identifier = MAP_CELL;

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

  CYMap *map;
  if (!indexPath.section) {
    map = [CYUser user].activeMap;
  } else {
    map = (CYMap*)self.maps[indexPath.row];
  }
  cell.textLabel.text = map.name;
  [cell.textLabel setFont:[UIFont fontWithName:@"CODE Light" size:17]];
//  float hoursSinceEdit = - ([map.updatedAt timeIntervalSinceNow] / (60.0*60));
//  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f hr", hoursSinceEdit];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!indexPath.section) {
    [CYUser user].activeMap = nil;
//    int index = [self.maps indexOfObject:[CYUser user].activeMap];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
//    cell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    CYMap *newActiveMap = self.maps[indexPath.row];
    [CYUser user].activeMap = newActiveMap;
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }

  [self.mapsTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"CYMapDetailViewController_Segue" sender:self.maps[indexPath.row]];
}


#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.mapsTableView.dataSource = self;
  self.mapsTableView.delegate = self;
  self.mapActionSheet = [[UIActionSheet alloc] initWithTitle:@"Maps" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:CREATE_NEW, SEARCH, nil];
  
  [self.headerLabel setFont:[UIFont fontWithName:@"CODE Bold" size:22]];

}

//implemented in dumbest way possible. for simplification.

//- (void)viewWillAppear:(BOOL)animated
//{
//  [super viewWillAppear:animated];
//  [self setMaps:[[CYUser user].maps mutableCopy]]; //these are all user following maps (- activeMap)
//  [self.maps removeObject:[CYUser user].activeMap];
//  [self.mapsTableView reloadData];
//}

- (void)viewWillAppear:(BOOL)animated
{
  [self.navigationController setNavigationBarHidden:YES animated:animated];
  [super viewWillAppear:animated];
  self.maps = [CYUser user].maps;
  [self.mapsTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self.navigationController setNavigationBarHidden:NO animated:animated];
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self setMapActionSheet:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"CYMapDetailViewController_Segue"]) {
    CYMapDetailViewController *vc = (CYMapDetailViewController *)segue.destinationViewController;
    vc.map = (CYMap*)sender;
  }
}
@end
