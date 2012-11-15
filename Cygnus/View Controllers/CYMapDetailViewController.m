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
#import "CYPoint.h"

#import "CYUI.h"
#import "CYMapView.h"



#define POINT_CELL              @"CYPointTableViewCell"

@interface CYMapDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CYMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *headerContainer;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedValueLabel;
@end

@implementation CYMapDetailViewController


#pragma mark - Actions, Gestures, Notification Handlers

- (IBAction)followButtonSelected:(id)sender {
  if ([[CYUser currentUser].maps containsObject:self.map]) {
    [[CYUser currentUser] removeMap:self.map];
    self.followLabel.text = @"Follow";

  } else {
    [[CYUser currentUser] addMap:self.map];
    self.followLabel.text = @"Following";

  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.map.size integerValue];
}

#define MAP_CELL                @"CYMapTableViewCell"
#define GROUP_CELL              @"CYGroupTableViewCell"


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = POINT_CELL;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  
  CYPoint *point = (CYPoint *)self.map.points[indexPath.row];
  cell.textLabel.text = point.name;
  float distance = [[CYUser currentUser].location distanceFromLocation:point.location];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km", distance/1000];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"CYPointDetailViewController_Segue" sender:self.map.points[indexPath.row]];
}

#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.mapView.scrollEnabled = NO;
  self.mapView.zoomEnabled = NO;  
  
  self.headerContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
  self.nameLabel.text = [NSString stringWithFormat:@"%@ (%d)", self.map.name, [self.map.size integerValue]];
  self.lastUpdatedValueLabel.text = [NSString stringWithFormat:@"%.2f hr", -([self.map.updatedAt timeIntervalSinceNow] / (60.0*60))];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.followLabel.text = ([[CYUser currentUser].maps containsObject:self.map]) ? @"Following" : @"Follow";
  [self.mapView updatePointsForMap:self.map animated:NO];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"CYPointDetailViewController_Segue"]) {
    CYPointDetailViewController *vc = (CYPointDetailViewController *)segue.destinationViewController;
    vc.point = (CYPoint*)sender;
  }
}

@end
