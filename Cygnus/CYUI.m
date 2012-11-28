//
//  CYUI.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUI.h"

@implementation CYUI


static const CGFloat offset = 1.5;
+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect withCurve:(CGFloat)curve {

	UIBezierPath *path = [UIBezierPath bezierPath];

	CGPoint topLeft		 = rect.origin;
	CGPoint bottomLeft	 = CGPointMake(0.0, CGRectGetHeight(rect) + offset);
	CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect) - curve);
	CGPoint bottomRight	 = CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) + offset);
	CGPoint topRight	 = CGPointMake(CGRectGetWidth(rect), 0.0);

	[path moveToPoint:topLeft];
	[path addLineToPoint:bottomLeft];
	[path addQuadCurveToPoint:bottomRight controlPoint:bottomMiddle];
	[path addLineToPoint:topRight];
	[path addLineToPoint:topLeft];
	[path closePath];
	return path;
}

+ (NSString *)ordinalSuffixFromNumber:(NSUInteger)n {
  if (n == 11 || n == 12 || n == 13) {
    return @"th";
  }

  switch (n % 10) {
    case 1:
      return @"st";
    case 2:
      return @"nd";
    case 3:
      return @"rd";
    default:
      return @"th";
  }
}

+ (UIImage *)image:(UIImage*)image scaledToSize:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
