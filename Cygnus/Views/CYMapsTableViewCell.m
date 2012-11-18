//
//  CYMapsTableViewCell.m
//  Cygnus
//
//  Created by Adam Rothman on 11/16/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapsTableViewCell.h"

@implementation CYMapsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    // replace imageview with a button so we can change its image
    UIButton *button = [[UIButton alloc] initWithFrame:self.imageView.frame];
    [self.imageView removeFromSuperview];
    [self.contentView addSubview:button];

    // set fonts
    self.textLabel.font = [UIFont fontWithName:@"CODE Light" size:17];
    self.detailTextLabel.font = [UIFont fontWithName:@"CODE Bold" size:9];
  }
  return self;
}

#pragma mark - Properties

- (void)setMap:(CYMap *)map {
  _map = map;
  if (_map) {
    self.textLabel.text = _map.name;
    self.detailTextLabel.text = _map.summary;
  }
}

#pragma mark - Interactions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  // Configure the view for the selected state
}

@end
