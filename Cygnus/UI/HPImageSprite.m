//
//  HPImageSprite.m
//  OneHundredPlus
//
//  Created by Elisha Cook on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HPImageSprite.h"

@interface HPImageSprite ()

@property (nonatomic,strong) NSMutableDictionary *fragmentsByName;

@end

@implementation HPImageSprite

@synthesize
fragmentsByName;

- (id)initWithImageNamed:(NSString *)name 
                   rects:(NSDictionary *)rects
{
    if (self = [super init])
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        fragmentsByName = [NSMutableDictionary dictionaryWithCapacity:[rects count]];
        CGImageRef image = [UIImage imageNamed:name].CGImage;
        
        for (NSString *fragmentName in rects)
        {
            CGRect rect = [[rects objectForKey:fragmentName] CGRectValue];
            rect.origin.x *= scale;
            rect.origin.y *= scale;
            rect.size.width *= scale;
            rect.size.height *= scale;
            CGImageRef fragment = CGImageCreateWithImageInRect(image, rect);
            [fragmentsByName setObject:[UIImage imageWithCGImage:fragment scale:scale orientation:UIImageOrientationUp] forKey:fragmentName];
        }
    }
    return self;
}

- (UIImage *)fragmentNamed:(NSString *)name
{
    return [fragmentsByName objectForKey:name];
}

@end
