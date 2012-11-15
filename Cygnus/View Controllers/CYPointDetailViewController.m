//
//  CYPointDetailViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointDetailViewController.h"

@interface CYPointDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *pointImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceValueLabel;
@end

@implementation CYPointDetailViewController


#pragma mark - Accessors

- (void)setPoint:(CYPoint *)point
{
  _point = point;

  [self.pointImageView cancelImageRequestOperation];
  [self.pointImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.point.imageURLString]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    [UIView transitionWithView:self.pointImageView
                      duration:0.22
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                      [self.pointImageView setImage:image];
                    } completion:NULL];
  } failure:NULL];
  
  self.pointNameLabel.text = _point.name;
  float distance = [[CYUser currentUser].location distanceFromLocation:point.location];
  self.distanceValueLabel.text = [NSString stringWithFormat:@"%.2f km", distance/1000];
}

#pragma mark - VC Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
