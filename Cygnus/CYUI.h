//
//  CYUI.h
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

@interface CYUI : NSObject

+ (UIBezierPath *)bezierPathWithCurvedShadowForRect:(CGRect)rect;

+ (NSString *)ordinalSuffixFromNumber:(NSUInteger)n;

+ (UIImage *)image:(UIImage*)image scaledToSize:(CGSize)size;

@end
