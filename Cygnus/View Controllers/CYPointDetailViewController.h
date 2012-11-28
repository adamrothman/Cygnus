//
//  CYPointDetailViewController.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYPoint+Additions.h"

@interface CYPointDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *pointImageView;
@property (strong, nonatomic)       CYPoint *point;
@end
