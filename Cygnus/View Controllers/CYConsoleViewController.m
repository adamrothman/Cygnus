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
@property (weak, nonatomic) IBOutlet UITableView *mapsTableView;
@property (strong, nonatomic)        UIActionSheet *mapActionSheet;
@property (strong, nonatomic)        NSMutableOrderedSet *maps;

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
          [[CYTabBarViewController currentVC] setSelectedIndex:2];
        } else if ([choice isEqualToString:CREATE_NEW]) {
          QRootElement *root = [[QRootElement alloc] init];
          root.title = @"Create";
          root.controllerName = @"CYMapCreationViewController";
          root.grouped = YES;
          
          //Will load from JSON similar to point schema (eventually). But for now.          
          
          /* Title */
          QEntryElement *mapTitleElement = [[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:@"Map Title"];
          mapTitleElement.key = @"title";
          QSection *titleSection = [[QSection alloc] init];
          [titleSection addElement:mapTitleElement];
          
          /* Description (Summary) */
          QMultilineElement *mapSummary = [QMultilineElement new];
          mapSummary.title = @"Description";
          mapSummary.key = @"summary";
          QSection *descriptionSection = [[QSection alloc] init];
          [descriptionSection addElement:mapSummary];

          QSection *schemaSection = [[QSection alloc] initWithTitle:@"Map item requirements (demo)"];
          [schemaSection addElement:[[QLabelElement alloc] initWithTitle:@"Name" Value:@"Text"]];
          [schemaSection addElement:[[QLabelElement alloc] initWithTitle:@"Description" Value:@"Text"]];
          QPickerElement *requiredFieldCount = [[QPickerElement alloc]
                                                initWithTitle:@"Number of fields"
                                                items:@[[@"1 2 3 4 5" componentsSeparatedByString:@" "]]
                                                value:@"1"];
          [schemaSection addElement:requiredFieldCount];
          
          QSection *demoPinSection = [[QSection alloc] initWithTitle:@"Example field specification"];
          [demoPinSection addElement:[[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:@"Field name"]];
          [demoPinSection addElement:[[QRadioElement alloc] initWithDict:[NSDictionary dictionaryWithObjectsAndKeys:@"QElementClass", @"Text", @"QElementClass", @"YES/NO", @"QElementClass", @"Paragraph", @"QElementClass", @"Number", @"QElementClass", @"Date",@"QElementClass", @"URL",@"QElementClass", @"Number",@"QElementClass", @"Radio with options", nil] selected:0 title:@"With Dict"]];

          
          QSection *createSection = [[QSection alloc] init];
          QButtonElement *createButton = [[QButtonElement alloc] initWithTitle:@"Create Map"];
          createButton.onSelected = ^{
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [root fetchValueIntoObject:dict];
            
            //Create new CYMap object from values
            //  (store item requirements in nstring property
            //   which can be read to JSON and parsed by the JSON dialogue builder)
            
            //Add current user as owner (need to set ability to delete if owner on map detail)
            //Upload new CYMap object to parse
            //Add new CYMap object to local full map list (help on CYMap class?)
            //Add new CYMap object to current user's maps (ie auto follow it)
            
            //dismiss CYMapCreationViewController
            
            //For now read out values
            NSString *msg = @"Values:";
            for (NSString *aKey in dict){
              msg = [msg stringByAppendingFormat:@"\n- %@: %@", aKey, [dict valueForKey:aKey]];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello"
                                                            message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
          };
  
          [root addSection:titleSection];
          [root addSection:descriptionSection];
          [root addSection:schemaSection];
          [root addSection:createSection];
          
          CYMapCreationViewController *myDialogController = (CYMapCreationViewController *)[QuickDialogController controllerForRoot:root];
          myDialogController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
          [self presentViewController:myDialogController animated:YES completion:NULL];
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
    return 1;
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
    map = [CYUser currentUser].activeMap;
  } else {
    map = (CYMap*)self.maps[indexPath.row];
  }
  cell.textLabel.text = map.name;
  float hoursSinceEdit = - ([map.updatedAt timeIntervalSinceNow] / (60.0*60));
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f hr", hoursSinceEdit];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (!indexPath.section) {
    [self.maps addObject:[CYUser currentUser].activeMap]; // add active map to "following" maps list
    [CYUser currentUser].activeMap = nil;
  } else {
    CYMap *newActiveMap = self.maps[indexPath.row];
    [self.maps removeObject:newActiveMap];
    [CYUser currentUser].activeMap = newActiveMap;
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
}

//implemented in dumbest way possible. for simplification.

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self setMaps:[[CYUser currentUser].maps mutableCopy]]; //these are all user following maps (- activeMap)
  [self.maps removeObject:[CYUser currentUser].activeMap];
  [self.mapsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

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
