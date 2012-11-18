//
//  CYMapViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "AwesomeMenu.h"
#import "CYMapView.h"

@interface CYMapViewController : UIViewController <MKMapViewDelegate, AwesomeMenuDelegate>

@property (nonatomic, weak) IBOutlet CYMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *activeMapLabel;
//@property (nonatomic, strong) AwesomeMenu *menu;

+ (CYMapViewController *)currentVC;

@end
