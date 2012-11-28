//
//  CYMapsTableViewCell.m
//  Cygnus
//
//  Created by Adam Rothman on 11/16/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapsTableViewCell.h"
#import "CYUser+Additions.h"

@implementation CYMapsTableViewCell

#pragma mark - Properties

- (void)setMap:(CYMap *)map {
  _map = map;
  if (_map) {
    self.textLabel.font = [UIFont fontWithName:@"Fabrica" size:15];
    self.textLabel.text = _map.name;
//    self.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:9];
//    self.detailTextLabel.text = _map.summary;
    self.accessoryType = _map == [CYUser activeMap] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryDisclosureIndicator;
  }
}

@end
