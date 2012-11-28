//
//  CYMapViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 10/24/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "AwesomeMenu.h"
#import "CYMapView.h"
#import "CYPointCreationView.h"

@interface CYMapViewController : UIViewController <MKMapViewDelegate, CYPointCreationDelegate, UITextFieldDelegate, UITextViewDelegate, AwesomeMenuDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet CYMapView *mapView;
@property (nonatomic, weak) IBOutlet CYPointCreationView *pointCreationView;
@property (nonatomic, strong) AwesomeMenu *menu;

- (IBAction)pointDetailDone:(UIStoryboardSegue *)segue;

@end
