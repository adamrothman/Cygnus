//
//  CYPointDetailViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointDetailViewController.h"
#import "CYUser+Additions.h"

@implementation CYPointDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.imageView cancelImageRequestOperation];
  [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.point.imageURLString]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    [UIView transitionWithView:self.imageView duration:0.22 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
      self.imageView.image = image;
    } completion:nil];
  } failure:nil];
  
  self.nameLabel.text = self.point.name;
  self.distanceLabel.text = @"distance";
  self.summaryTextView.text = self.point.summary;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYANALYTICS_EVENT_POINT_DETAIL_VISIT withParameters:nil];
}

@end
