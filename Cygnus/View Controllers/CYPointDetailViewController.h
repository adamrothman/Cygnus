//
//  CYPointDetailViewController.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPoint+Additions.h"

@interface CYPointDetailViewController : UIViewController

@property (nonatomic, strong) CYPoint *point;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UITextView *summaryTextView;

@end
