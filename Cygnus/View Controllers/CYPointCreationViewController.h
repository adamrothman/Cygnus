//
//  CYPointCreationViewController.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/15/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMap+Additions.h"
#import "CYMapView.h"
#import "ARTextField.h"

@interface CYPointCreationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ARTextField *titleTextField;
@property (weak, nonatomic) IBOutlet ARTextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) id<MKAnnotation> userPointAnnotation;
@property (weak, nonatomic) id<CYMapEditorDelegate> delegate;


@end
