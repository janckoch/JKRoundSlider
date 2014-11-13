//
//  UIImage+JKAdditions.h
//  Example
//
//  Created by Jan Koch on 13/11/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (JKAdditions)

- (UIImage *)resizeImageToRectIfNeeded:(CGRect)rect;
- (UIImage *)invertAlpha;

@end
