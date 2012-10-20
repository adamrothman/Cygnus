//
//  HPImageSprite.h
//  OneHundredPlus
//
//  Created by Elisha Cook on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPImageSprite : NSObject

- (id)initWithImageNamed:(NSString *)name 
                   rects:(NSDictionary *)rects;

- (UIImage *)fragmentNamed:(NSString *)name;

@end
