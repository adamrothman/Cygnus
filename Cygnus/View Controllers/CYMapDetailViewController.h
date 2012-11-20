//
//  CYMapDetailViewController.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/9/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap+Additions.h"
#import "CYMapView.h"

@interface CYMapDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) CYMap *map;

@property (nonatomic, weak) IBOutlet CYMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
