//
//  CYPointDetailViewController.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYPoint+Additions.h"
#import "CYMapView.h"

@interface CYPointDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *pointImageView;

@property (nonatomic, strong) CYPoint *point;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet CYMapView *mapView;

@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UITextView *summaryTextView;

@end
