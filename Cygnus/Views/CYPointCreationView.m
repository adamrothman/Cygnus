//
//  CYPointCreationView.m
//  Cygnus
//
//  Created by Adam Rothman on 11/18/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointCreationView.h"

@interface CYPointCreationView ()

@property (nonatomic) NSTimeInterval animationDuration;

@end

@implementation CYPointCreationView

- (void)setUp {
  self.layer.borderWidth = 1.f;
  self.layer.borderColor = [UIColor whiteColor].CGColor;
  self.layer.cornerRadius = 8.f;
  self.layer.shadowOpacity = 0.5f;
  self.layer.shadowOffset = CGSizeMake(0.f, 2.5f);
  self.contentMode = UIViewContentModeScaleToFill;

  self.animationDuration = 0.5;

  self.summaryTextView.placeholder = @"Summary";
}

- (void)summonAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
  if (!self.framesSet) return;
  NSTimeInterval duration = animated ? self.animationDuration : 0;
  [UIView animateWithDuration:duration delay:0 options:0 animations:^{
    self.frame = self.onscreenFrame;
  } completion:^(BOOL finished) {
    if (completion) completion(finished);
  }];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
  if (!self.framesSet) return;
  NSTimeInterval duration = animated ? self.animationDuration : 0;
  [UIView animateWithDuration:duration delay:0 options:0 animations:^{
    self.frame = self.offscreenFrame;
  } completion:^(BOOL finished) {
    if (completion) completion(finished);
  }];
}

- (IBAction)save:(UIButton *)sender {
  [self.delegate pointCreationView:self didSave:sender];
}

- (IBAction)cancel:(UIButton *)sender {
  [self.delegate pointCreationView:self didCancel:sender];
}

@end
