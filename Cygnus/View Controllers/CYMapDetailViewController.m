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

//- (IBAction)followButtonSelected:(id)sender {
//  if ([[CYUser user].maps containsObject:self.map]) {
//    [[CYUser user] removeMapsObject:self.map];
//    if ([CYUser user].activeMap == self.map) [CYUser user].activeMap = nil;
//    self.followLabel.text = @"Follow";
//    [UIView animateWithDuration:0.22 animations:^{
//      self.followButton.transform = CGAffineTransformIdentity;
//    }];
//
//  } else {
//    [[CYUser user] addMapsObject:self.map];
//    if ([CYUser user].activeMap == nil) [CYUser user].activeMap = self.map;
//
//    self.followLabel.text = @"Following";
//    [UIView animateWithDuration:0.22 animations:^{
//      self.followButton.transform = CGAffineTransformMakeRotation(M_PI/4);
//    }];
//  }
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.map.points.count;
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

  CLLocation *temp = [[CLLocation alloc] initWithCoordinate:point.coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
  float distance = [temp distanceFromLocation:self.mapView.userLocation.location];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", distance/1000];
  [cell.textLabel setFont:[UIFont fontWithName:@"CODE Light" size:17]];
  [cell.detailTextLabel setFont:[UIFont fontWithName:@"accent" size:9]];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//  [self performSegueWithIdentifier:@"CYPointDetailViewController_Segue" sender:indexPath];
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
  [self.mapView updatePointsForMap:self.map animated:NO];
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];

  self.headerContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
  self.nameLabel.text = [NSString stringWithFormat:@"%@ (%d)", self.map.name, self.map.points.count];
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"MM.dd.YY"];
  self.lastUpdatedValueLabel.text = [df stringFromDate:self.map.updatedAt];
  [self.lastUpdatedLabel setFont:[UIFont fontWithName:@"CODE Light" size:9]];
  [self.lastUpdatedValueLabel setFont:[UIFont fontWithName:@"accent" size:9]];
  [self.lastUpdatedLabel sizeToFit];
  [self.lastUpdatedValueLabel sizeToFit];

  [self.nameLabel setFont:[UIFont fontWithName:@"CODE Bold" size:17]];
  [self.nameLabel sizeToFit];
  self.followButton.transform = CGAffineTransformIdentity;

  self.navigationItem.title = self.map.name;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
//  if ([[CYUser user].maps containsObject:self.map]) {
//    self.followLabel.text = @"Following";
//    self.followButton.transform = CGAffineTransformMakeRotation(M_PI/4);
//  } else {
//    self.followLabel.text = @"Follow";
//    self.followButton.transform = CGAffineTransformIdentity;
//  }

  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_MAP_DETAIL_VISIT withParameters:nil];

}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"CYPointDetailViewController_Segue"]) {
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    CYPoint *point = self.map.points[indexPath.row];
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    CYPointDetailViewController *vc = (CYPointDetailViewController *)segue.destinationViewController;
    vc.point = point;
    vc.distanceString = cell.detailTextLabel.text;
  }
}

@end
