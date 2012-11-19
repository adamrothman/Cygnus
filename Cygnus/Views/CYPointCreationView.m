//
//  CYPointCreationView.m
//  Cygnus
//
//  Created by Adam Rothman on 11/18/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointCreationView.h"

@implementation CYPointCreationView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self setUp];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)coder {
  if ((self = [super initWithCoder:coder])) {
    [self setUp];
  }
  return self;
}

- (void)setUp {
  self.summaryTextView.placeholder = @"Summary";
}

- (void)summonAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
  NSTimeInterval duration = animated ? 0.75 : 0;
  [UIView animateWithDuration:duration delay:0 options:0 animations:^{
    self.frame = self.onscreenFrame;
  } completion:^(BOOL finished) {
    if (completion) completion(finished);
  }];
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
  NSTimeInterval duration = animated ? 0.75 : 0;
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
