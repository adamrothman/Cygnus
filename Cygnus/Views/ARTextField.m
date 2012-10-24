//
//  ARTextView.m
//
//  Created by Adam Rothman on 7/15/12.
//  Copyright (c) 2012 Adam Rothman. All rights reserved.
//
//  A UITextField with padding.
//

#import "ARTextField.h"

@implementation ARTextField

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.origin.x + 7,
                    bounds.origin.y + 6,
                    bounds.size.width - 14,
                    bounds.size.height - 12);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

@end
