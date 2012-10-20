//
//  HPUI.m
//  100+
//
//  Created by Elisha Cook on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HPUI.h"
#import "HPImageSprite.h"

@implementation HPUI

static NSMutableDictionary *fontByClass = nil;
static NSMutableDictionary *fontsByNameAndSize = nil;
static NSMutableDictionary *colorsByHex = nil;
static HPImageSprite *buttonIconSprite = nil;
static HPImageSprite *subscoreIconSprite = nil;
static HPImageSprite *subscoreSmallIconSprite = nil;
static NSArray *subscoreTypes = nil;


+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
    if (!fontsByNameAndSize)
    {
        fontsByNameAndSize = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [NSString stringWithFormat:@"%@-%f", fontName, fontSize];
    UIFont *font = [fontsByNameAndSize objectForKey:key];
    
    if (font == nil)
    {
        font = [UIFont fontWithName:fontName size:fontSize];
        [fontsByNameAndSize setObject:font forKey:key];
    }
    
    return font;
}

+ (UIFont *)fontWithClass:(NSString *)className
{
    if (!fontByClass)
    {
        fontByClass = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [HPUI fontWithName:@"TrebuchetMS-Bold" size:13], @"episodeColumnTitle",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:13], @"newContentCardTitle",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:15], @"newContentCardNumber",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"newContentCardDescrtiption",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"episodeCardTitle",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:15], @"episodeCardNumber",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"episodeCardDescription",
                       [HPUI fontWithName:@"Ronnia-Light" size:52], @"lifescore",
                       [HPUI fontWithName:@"TrebuchetMS" size:12], @"lifescoreLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:18], @"lifescoreChange",
                       [HPUI fontWithName:@"Ronnia-Light" size:26], @"lifescoreSmall",
                       [HPUI fontWithName:@"TrebuchetMS" size:8], @"lifescoreSmallLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:11], @"lifescoreChangeSmall",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"episodeDetailTitle",
                       [HPUI fontWithName:@"TrebuchetMS-Bold" size:18], @"dialWidget",
                       [HPUI fontWithName:@"Ronnia-Regular" size:30], @"rotaryDialWidget",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"rotaryDialWidgetValue",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"labelWidget",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:20], @"labelHeaderWidget",
                       [HPUI fontWithName:@"Ronnia-Regular" size:20], @"labelLargeWidget",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:13], @"sliderTitle",
                       [HPUI fontWithName:@"Ronnia-Regular" size:11], @"sliderLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:23], @"dashboardModuleTitle",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:19], @"statsModuleUsername",
                       [HPUI fontWithName:@"Ronnia-Regular" size:19], @"statsModuleStat",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:19], @"statsModuleStatValue",
                       [HPUI fontWithName:@"Ronnia-Light" size:19], @"statsModuleStatUnits",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:21], @"statsModuleConfidenceNumber",
                       [HPUI fontWithName:@"Ronnia-Light" size:21], @"statsModuleConfidenceNumberPercent",
                       [HPUI fontWithName:@"Ronnia-Regular" size:9], @"statsModuleConfidenceLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:12], @"statsModuleThenIfLabels",
                       [HPUI fontWithName:@"Ronnia-Regular" size:16], @"leaderboardModuleRank",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"leaderboardModuleUsername",
                       [HPUI fontWithName:@"Ronnia-Light" size:13], @"leaderboardModuleLifescoreChange",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:13], @"leaderboardModuleRankChange",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:12], @"leaderboardFilterOptionSmall",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:18], @"leaderboardFilterOptionLarge",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"gameplanModuleEntryDescription",
                       [HPUI fontWithName:@"Ronnia-Regular" size:16], @"gameplanDetailEntryDescription",
                       [HPUI fontWithName:@"Ronnia-Regular" size:24], @"verticalSpinner",
                       [HPUI fontWithName:@"Ronnia-Regular" size:17], @"unitsSpinner",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:15], @"buttonWidget",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:18], @"intuitiveTouchTitle",
                       [HPUI fontWithName:@"Ronnia-Regular" size:15], @"intuitiveTouchLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:12], @"intuitiveTouchNote",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:12], @"intuitiveTouchResultsLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"noteLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:13], @"sectionProgressTitle",
                       [HPUI fontWithName:@"Ronnia-Regular" size:11], @"segmentedButtonLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:18], @"ratingThankYou",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:20], @"helpOverlayHeader",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"helpOverlayBody",
                       [HPUI fontWithName:@"Ronnia-Regular" size:12], @"predictionGraphLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:12], @"navigationLink",
                       [HPUI fontWithName:@"Ronnia-Light" size:12], @"shareImageDescription",
                       [HPUI fontWithName:@"Ronnia-Regular" size:20], @"questionLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"questionOptionLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"questionResponseAmountLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:12], @"shareDescription",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"photoCaption",
                       [HPUI fontWithName:@"Ronnia-Regular" size:22], @"photoCommentsHeader",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"photoCommentsUsername",
                       [HPUI fontWithName:@"Ronnia-Regular" size:12], @"photoCommentsDate",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"photoCommentsBody",
                       [HPUI fontWithName:@"Ronnia-Regular" size:13], @"photoCancelButton",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"subscoreLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"subscoreCaption",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:60], @"subscorePercentile",
                       [HPUI fontWithName:@"Ronnia-Light" size:30], @"subscorePercentileSuffix",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"subscorePercentileCaption",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"statsSectionHeader",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"statsFieldLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:18], @"statsFieldData",
                       [HPUI fontWithName:@"Ronnia-Light" size:14], @"improveLabel",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:20], @"improveLifeScoreNumber",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:14], @"improveLifeScoreUnit",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:12], @"histogramLabel",
                       [HPUI fontWithName:@"Ronnia-Regular" size:14], @"pieSliceName",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:16], @"pieSliceValue",
                       [HPUI fontWithName:@"Ronnia-SemiBold" size:12], @"pieTitle",
                       nil];
    }
    
    return [fontByClass objectForKey:className];
}

+ (void)clearFontCache
{
    fontByClass = nil;
    fontsByNameAndSize = nil;
}

+ (UIColor *)colorFromHex:(int)colorInHex alpha:(CGFloat)alpha;
{
    if (!colorsByHex)
    {
        colorsByHex = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [NSString stringWithFormat:@"%x", colorInHex];
    UIColor *color = [colorsByHex objectForKey:key];
    
    if (!color)
    {
        float red = (float) ((colorInHex & 0xFF0000) >> 16) / 255.0f;
        float green = (float) ((colorInHex & 0x00FF00) >> 8) / 255.0f;
        float blue = (float) ((colorInHex & 0x000FF) >> 0) / 255.0f;
        
        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        [colorsByHex setObject:color forKey:key];
    }
    
    return color;
}

+ (UIColor *)colorFromHex:(int)colorInHex
{
    return [HPUI colorFromHex:colorInHex alpha:1.0];
}


+ (void)clearColorCache
{
    colorsByHex = nil;
}

+ (UIImage *)buttonIconForName:(NSString *)name
{
    if (!buttonIconSprite)
    {
        buttonIconSprite = [[HPImageSprite alloc] 
                            initWithImageNamed:@"gray_btn_icons.png" 
                            rects:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], @"bullhorn",
                                   [NSValue valueWithCGRect:CGRectMake(20, 0, 20, 20)], @"up_arrow",
                                   [NSValue valueWithCGRect:CGRectMake(40, 0, 20, 20)], @"star",
                                   [NSValue valueWithCGRect:CGRectMake(60, 0, 20, 20)], @"redo",
                                   [NSValue valueWithCGRect:CGRectMake(80, 0, 20, 20)], @"envelope",
                                   [NSValue valueWithCGRect:CGRectMake(100, 0, 20, 20)], @"twitter",
                                   [NSValue valueWithCGRect:CGRectMake(120, 0, 20, 20)], @"facebook",
                                   [NSValue valueWithCGRect:CGRectMake(140, 0, 20, 20)], @"diagram",
                                   [NSValue valueWithCGRect:CGRectMake(160, 0, 20, 20)], @"right_arrow",
                                   [NSValue valueWithCGRect:CGRectMake(180, 0, 20, 20)], @"flag",
                                   nil]];
    }
    
    return [buttonIconSprite fragmentNamed:name];
}


+ (UIImage *)subscoreIconForType:(NSString *)type
{
    if (!subscoreIconSprite)
    {
        subscoreIconSprite = [[HPImageSprite alloc] 
         initWithImageNamed:@"icons_sprite.png"
         rects:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSValue valueWithCGRect:CGRectMake(0, 0, 20, 20)], kHPSubscoreTypeActivity,
                [NSValue valueWithCGRect:CGRectMake(20, 0, 20, 20)], kHPSubscoreTypeDiet,
                [NSValue valueWithCGRect:CGRectMake(40, 0, 20, 20)], kHPSubscoreTypeStress,
                [NSValue valueWithCGRect:CGRectMake(60, 0, 20, 20)], kHPSubscoreTypeWellness,
                nil]];
    }
    
    return [subscoreIconSprite fragmentNamed:type];
}

+ (UIImage *)subscoreSmallIconForType:(NSString *)type
{
    if (!subscoreSmallIconSprite)
    {
        subscoreSmallIconSprite = [[HPImageSprite alloc] 
                              initWithImageNamed:@"gameplan_small_icons_sprite.png"
                              rects:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSValue valueWithCGRect:CGRectMake(0, 0, 16, 16)], kHPSubscoreTypeActivity,
                                     [NSValue valueWithCGRect:CGRectMake(16, 0, 16, 16)], kHPSubscoreTypeDiet,
                                     [NSValue valueWithCGRect:CGRectMake(32, 0, 16, 16)], kHPSubscoreTypeStress,
                                     [NSValue valueWithCGRect:CGRectMake(48, 0, 16, 16)], kHPSubscoreTypeWellness,
                                     nil]];
    }
    
    return [subscoreSmallIconSprite fragmentNamed:type];
}

+ (NSArray *)subscoreTypes
{
    if (!subscoreTypes)
    {
        subscoreTypes = [NSArray arrayWithObjects:
                         kHPSubscoreTypeActivity,
                         kHPSubscoreTypeDiet,
                         kHPSubscoreTypeStress,
                         kHPSubscoreTypeWellness,
                         nil];
    }
    
    return subscoreTypes;
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

+ (void)giveDropShadowWithCornerRadius:(UIView *)view
{
    view.layer.cornerRadius = 3.0f;
    [view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [view.layer setBorderWidth:0.5f];
    [view.layer setShadowPath:[[UIBezierPath bezierPathWithRect:view.bounds] CGPath]];
    view.layer.shadowOpacity = 0.68;
    view.layer.shadowRadius = 1.0;
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.5, 1.0);
}


@end
