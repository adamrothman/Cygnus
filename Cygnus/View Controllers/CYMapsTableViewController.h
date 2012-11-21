//
//  CYMapsTableViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYMapsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate>

- (IBAction)mapCreationDidSave:(UIStoryboardSegue *)segue;

@end
