//
//  CYConsoleViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYConsoleViewController.h"
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

#define MAP_CELL                @"mapsTableViewCell"
#define GROUP_CELL              @"groupsTableViewCell"


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
    float hoursSinceEdit = ([map.updatedAt timeIntervalSinceNow] / (60.0*60));
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%2f hr", hoursSinceEdit];
  } else {
    CYGroup *group = (CYGroup *)self.groups[indexPath.row];
    cell.textLabel.text = group.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group.members count]];
  }
  return cell;
}


#pragma mark - UITableViewDelegate




#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.groups = [[CYUser currentUser] groups];
  self.maps = [[CYUser currentUser] maps];
  [self.mapsTableView reloadData];
  [self.groupsTableView reloadData];
    
  self.mapActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add New Map" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:CREATE_NEW, SEARCH, nil];
  self.groupActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add New Group" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:CREATE_NEW, SEARCH, nil];
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
@end
