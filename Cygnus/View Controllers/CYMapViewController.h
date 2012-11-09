//
//  CYMapViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "AwesomeMenu.h"
//@property (nonatomic, strong) AwesomeMenu *menu;

@class CYMapView;

@interface CYMapViewController : UIViewController <MKMapViewDelegate, AwesomeMenuDelegate>

@property (nonatomic, weak) IBOutlet CYMapView *mapView;

- (void)toggleBeaconHUD;
+ (CYMapViewController *)currentVC;

@end