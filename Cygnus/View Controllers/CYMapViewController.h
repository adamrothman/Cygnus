//
//  CYMapViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "AwesomeMenu.h"

@interface CYMapViewController : UIViewController <MKMapViewDelegate, AwesomeMenuDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, strong) AwesomeMenu *menu;

- (void)toggleBeaconHUD;
+ (CYMapViewController *)currentVC;

@end
