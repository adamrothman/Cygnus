//
//  CYUI.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import <SSToolkit/SSCategories.h>
#import "UIView+Layout.h"
#import "UIImage+ImageFromDiskNamed.h"
#import "NSAttributedString+Attributes.h"

@interface CYUI : NSObject

+ (NSString *)ordinalSuffixFromNumber:(NSUInteger)n;
+ (BOOL)isiPhone5;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect;

@end
