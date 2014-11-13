//
//  JKRoundButton.h
//  Example
//
//  Created by Jan Koch on 13/11/14.
//
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE
@interface JKRoundButton : UIButton

@property (strong, nonatomic) IBInspectable NSString *title;
@property (strong, nonatomic) IBInspectable UIImage *image;
@property (assign, nonatomic) IBInspectable CGFloat innerBorderWidth;
@property (strong, nonatomic) IBInspectable UIColor *normalStateColor;

@end
