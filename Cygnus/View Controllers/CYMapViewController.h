//
//  CYMapViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *map;

@end
