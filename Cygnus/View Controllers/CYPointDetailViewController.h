//
//  CYPointDetailViewController.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYPoint.h"

@interface CYPointDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *pointImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceValueLabel;
@property (strong, nonatomic)       NSString *distanceString;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic)       CYPoint *point;
@end
