//
//  UIImage+JKAdditions.m
//  Example
//
//  Created by Jan Koch on 13/11/14.
//
//

#import "UIImage+JKAdditions.h"

@implementation UIImage (JKAdditions)

// Taken from http://stackoverflow.com/questions/603907/uiimage-resize-then-crop & edited
- (UIImage *)resizeImageToRectIfNeeded:(CGRect)rect
{
    if (!CGSizeEqualToSize(self.size, rect.size)) {
        UIImage *newImage = nil;
        CGSize imageSize = self.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        CGFloat targetWidth = rect.size.width;
        CGFloat targetHeight = rect.size.height;
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }

        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else {
            if (widthFactor < heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }

        UIGraphicsBeginImageContext(rect.size);

        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;

        [self drawInRect:thumbnailRect];

        newImage = UIGraphicsGetImageFromCurrentImageContext();

        if(newImage == nil) {
            NSLog(@"could not scale image");
        }

        UIGraphicsEndImageContext();
        
        return newImage;
    }
    return self;
}


// Taken from https://github.com/robinsenior/RSMaskedLabel
- (UIImage *)invertAlpha
{
    CGFloat scale = [self scale];
    CGSize size = self.size;
    int width = size.width * scale;
    int height = size.height * scale;

    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();

    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);

    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);

    CGColorSpaceRelease(colourSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);

    for(int y = 0; y < height; y++)
    {
        unsigned char *linePointer = &memoryPool[y * width * 4];

        for(int x = 0; x < width; x++)
        {
            linePointer[3] = 255-linePointer[3];
            linePointer += 4;
        }
    }

    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];

    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);

    return returnImage;
}

@end
