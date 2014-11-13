//
//  JKRoundSlider.h
//
//  Created by Jan Koch on 07/11/14.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface JKRoundSlider : UIControl

@property (strong, nonatomic) IBInspectable UIColor *primaryColor;
@property (strong, nonatomic) IBInspectable UIColor *secondaryColor;
@property (strong, nonatomic) IBInspectable NSString *title;
@property (assign, nonatomic) IBInspectable float value;
@property (strong, nonatomic) IBInspectable UIImage *image;
@property (strong, nonatomic) UIFont *font;

@end
