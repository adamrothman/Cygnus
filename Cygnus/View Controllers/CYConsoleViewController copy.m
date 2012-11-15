//
//  CYConsoleViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYConsoleViewController.h"
#import "CYMapDetailViewController.h"

#import "CYUser.h"
#import "CYMap.h"
#import "CYGroup.h"
#import "CYUI.h"


#define CANCEL          @"Cancel"
#define JOIN            @"Join"
#define CREATE_NEW      @"Create"
#define SEARCH          @"Search"

@interface CYConsoleViewController () <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mapsAddButton;

@property (weak, nonatomic) IBOutlet UIButton *groupsAddButton;

@property (weak, nonatomic) IBOutlet UITableView *mapsTableView;

@property (weak, nonatomic) IBOutlet UITableView *groupsTableView;

@property (strong, nonatomic)        UIActionSheet *mapActionSheet;

@property (strong, nonatomic)        UIActionSheet *groupActionSheet;

@property (strong, nonatomic)        NSArray *groups;
@property (strong, nonatomic)        NSArray *maps;

@end

@implementation CYConsoleViewController

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.mapActionSheet) {
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            // do horrible things
        } else if ([choice isEqualToString:CANCEL]) {
//
        } else if ([choice isEqualToString:CANCEL]) {
//
        } else if ([choice isEqualToString:CANCEL]) {
//
        } else if ([choice isEqualToString:CANCEL]) {
//
        }
    }
}

#pragma mark - Actions, Gestures, Notification Handlers

- (IBAction)addMapSelected:(id)sender {
    [self.mapActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)addGroupSelected:(id)sender {
    [self.groupActionSheet showFromTabBar:self.tabBarController.tabBar];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView == self.mapsTableView) return [self.maps count];
  if (tableView == self.groupsTableView) return [self.groups count];
  return 0;
}

#define MAP_CELL                @"CYMapTableViewCell"
#define GROUP_CELL              @"CYGroupTableViewCell"


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier;
  if (tableView == self.mapsTableView)    identifier = MAP_CELL;
  if (tableView == self.groupsTableView)  identifier = GROUP_CELL;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
  if (tableView == self.mapsTableView) {
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
  //
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == self.mapsTableView) {
    [self performSegueWithIdentifier:@"CYMapDetailViewController_Segue" sender:self.maps[indexPath.row]];
  }
}


#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.mapsTableView.dataSource = self;
  self.groupsTableView.dataSource = self;
  self.mapsTableView.delegate = self;
  self.groupsTableView.delegate = self;
  self.mapActionSheet = [[UIActionSheet alloc] initWithTitle:@"Maps" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:CREATE_NEW, SEARCH, nil];
  self.groupActionSheet = [[UIActionSheet alloc] initWithTitle:@"Groups" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:CREATE_NEW, SEARCH, nil];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.groups = [[[CYUser currentUser] groups] allObjects];
  self.maps = [[[CYUser currentUser] maps] allObjects];
  [self.mapsTableView reloadData];
  [self.groupsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self setGroupActionSheet:nil];
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