//
//  ARTextView.h
//
//  Created by Adam Rothman on 7/15/12.
//  Copyright (c) 2012 Adam Rothman. All rights reserved.
//
//  A UITextView that supports placeholder text.
//

#import <UIKit/UIKit.h>

@interface ARTextView : UITextView

@property (nonatomic, copy) NSString *placeholderText;

@end
