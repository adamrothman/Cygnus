//
//  CYPointCreationView.m
//  Cygnus
//
//  Created by Adam Rothman on 11/18/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointCreationView.h"
#import "CYUI.h"

@interface CYPointCreationView ()

@property (nonatomic) UIViewAnimationOptions animationOptions;

@end

@implementation CYPointCreationView

- (void)setUp {
  self.layer.borderWidth = 1.f;
  self.layer.borderColor = [UIColor whiteColor].CGColor;
  self.layer.cornerRadius = 8.f;
  self.layer.shadowOpacity = 0.5f;
  self.layer.shadowOffset = CGSizeMake(0.f, 2.5f);
  self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageFromDiskNamed:@"gray_bg.png"]];

  //self.contentMode = UIViewContentModeScaleToFill;
  self.nameTextField.font = [UIFont fontWithName:@"Fabrica" size:15];
  self.summaryTextView.font = [UIFont fontWithName:@"Fabrica" size:15];
  self.nameTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
  self.summaryTextView.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
  self.animationOptions = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState;
  self.summaryTextView.placeholderText = @"Summary";
}

- (void)summonWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
  if (!self.framesSet) return;
  [UIView animateWithDuration:duration delay:0 options:self.animationOptions animations:^{
    self.frame = self.onscreenFrame;
    self.alpha = 1.f;
  } completion:^(BOOL finished) {
    if (completion) completion(finished);
  }];
}

- (void)dismissWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
  if (!self.framesSet) return;
  [UIView animateWithDuration:duration delay:0 options:self.animationOptions animations:^{
    self.frame = self.offscreenFrame;
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    if (completion) completion(finished);
  }];
}

- (IBAction)save:(UIButton *)sender {
  [self.delegate pointCreationView:self didSave:sender];
}

@end
