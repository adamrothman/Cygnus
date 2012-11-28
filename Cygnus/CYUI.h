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

+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect withCurve:(CGFloat)curve;

+ (NSString *)ordinalSuffixFromNumber:(NSUInteger)n;

+ (UIImage *)image:(UIImage*)image scaledToSize:(CGSize)size;

+ (UILabel *)navigationBarTitleViewWithString:(NSString*)string;

@end
