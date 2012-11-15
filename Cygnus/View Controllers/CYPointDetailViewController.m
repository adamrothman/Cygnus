//
//  CYPointDetailViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointDetailViewController.h"
#import "CYUser+Additions.h"

@interface CYPointDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerContainer;

@end

@implementation CYPointDetailViewController


#pragma mark - Accessors

- (void)setPoint:(CYPoint *)point
{
  _point = point;


  

}

#pragma mark - VC Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
  self.distanceValueLabel.text = self.distanceString;
  self.summaryLabel.text = self.point.summary;
  [self.summaryLabel sizeToFit];
  self.headerContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
