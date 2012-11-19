//
//  CYMapCreationTableViewController.h
//  Cygnus
//
//  Created by Adam Rothman on 11/19/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "ARTextField.h"
#import "ARTextView.h"

@interface CYMapCreationTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet ARTextField *nameTextField;
@property (nonatomic, weak) IBOutlet ARTextView *summaryTextView;

@end
