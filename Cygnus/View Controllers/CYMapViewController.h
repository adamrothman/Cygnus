//
//  CYMapViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "AwesomeMenu.h"

@class CYMapView;

@interface CYMapViewController : UIViewController <MKMapViewDelegate, AwesomeMenuDelegate>

@property (weak, nonatomic) IBOutlet CYMapView *mapView;
//@property (nonatomic, strong) AwesomeMenu *menu;

+ (CYMapViewController *)currentVC;

@end
