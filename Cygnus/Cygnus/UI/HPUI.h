//
//  HPUI.h
//  100+
//
//  Created by Elisha Cook on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SSToolkit/SSCategories.h>
#import "UIView+Animations.h"
#import "UIView+Layout.h"
#import "UIImage+ImageFromDiskNamed.h"
#import "NSObject+SBJson.h"
#import "NSString+UUID.h"
#import "NSAttributedString+Attributes.h"

#define RGB(r,g,b) ([UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:1.0])
#define RGBA(r,g,b,a) ([UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:(a)/255.])i


static NSString *kHPSubscoreTypeActivity = @"activity";
static NSString *kHPSubscoreTypeDiet = @"diet";
static NSString *kHPSubscoreTypeStress = @"stress";
static NSString *kHPSubscoreTypeWellness = @"wellness";


@interface HPUI : NSObject

    

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize;

+ (UIFont *)fontWithClass:(NSString *)className;

+ (void)clearFontCache;

+ (UIColor *)colorFromHex:(int)colorInHex;

+ (UIColor *)colorFromHex:(int)colorInHex alpha:(CGFloat)alpha;

+ (void)clearColorCache;

+ (UIImage *)buttonIconForName:(NSString *)name;

+ (UIImage *)subscoreIconForType:(NSString *)type;
+ (UIImage *)subscoreSmallIconForType:(NSString *)type;
+ (NSArray *)subscoreTypes;

+ (NSString *)ordinalSuffixFromNumber:(NSUInteger)n;

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
+ (void)giveDropShadowWithCornerRadius:(UIView *)view;


@end
