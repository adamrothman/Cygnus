//
//  CYUI.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYUI.h"

@implementation CYUI


static const CGFloat offset = 10.0;
static const CGFloat curve = 1.3;
+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect {

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



+ (BOOL)isiPhone5
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
      CGFloat height = [[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale];
      return height == 1136;

    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

+ (NSString *)ordinalSuffixFromNumber:(NSUInteger)n
{
  if (n == 11 || n == 12 || n == 13)
  {
    return @"th";
  }

  n = n % 10;

  switch (n) {
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

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
{
  // Create a graphics image context
  UIGraphicsBeginImageContext(newSize);

  // Tell the old image to draw in this new context, with the desired
  // new size
  [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];

  // Get the new image from the context
  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

  // End the context
  UIGraphicsEndImageContext();

  // Return the new image.
  return newImage;
}


@end
