//
//  CYPointCreationView.h
//  Cygnus
//
//  Created by Adam Rothman on 11/18/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "ARTextField.h"
#import "ARTextView.h"

@class CYPointCreationView;

@protocol CYPointCreationDelegate

- (void)pointCreationView:(CYPointCreationView *)view didSave:(UIButton *)sender;

@end

@interface CYPointCreationView : UIView

@property (nonatomic, weak) id <CYPointCreationDelegate> delegate;

@property (nonatomic, weak) IBOutlet ARTextField *nameTextField;
@property (nonatomic, weak) IBOutlet ARTextView *summaryTextView;

@property (nonatomic) CGRect onscreenFrame;
@property (nonatomic) CGRect offscreenFrame;
@property (nonatomic) BOOL framesSet;

- (void)setUp;

- (void)summonWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;
- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion;

- (IBAction)save:(UIButton *)sender;

@end
