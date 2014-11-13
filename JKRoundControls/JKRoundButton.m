//
//  JKRoundButton.m
//  Example
//
//  Created by Jan Koch on 13/11/14.
//
//

#import "JKRoundButton.h"
#import "UIImage+JKAdditions.h"
@import QuartzCore;

@interface JKRoundButton ()

@property (strong, nonatomic) CAShapeLayer *innerBody;
@property (strong, nonatomic) CAShapeLayer *outerBody;
@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) CALayer *imageLayer;

@end

@implementation JKRoundButton

- (instancetype)init
{
    if (self = [super init]) {
        [self addLayers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addLayers];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setDefaults
{
    [self addTarget:self action:@selector(startPushAnimation:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(stopPushAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(stopPushAnimation:) forControlEvents:UIControlEventTouchUpOutside];
    self.clipsToBounds = YES;
    _innerBorderWidth = 10.0;
    _normalStateColor = [UIColor whiteColor];
    _selectedColor = [_normalStateColor colorWithAlphaComponent:0.8];
}

- (void)addLayers
{
    [self setDefaults];

    _outerBody = [CAShapeLayer layer];
    [self.layer addSublayer:_outerBody];

    _innerBody = [CAShapeLayer layer];
    [self.layer addSublayer:_innerBody];

    _imageLayer =[CALayer layer];

    [self setLayerProperties];
}

- (void)setLayerProperties
{
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2.0, 2.0, CGRectGetWidth(self.bounds) - 4.0, CGRectGetHeight(self.bounds) - 4.0)];
    _outerBody.fillColor = [UIColor clearColor].CGColor;
    if (self.isEnabled) {
        _outerBody.strokeColor = _normalStateColor.CGColor;
    } else {
        _outerBody.strokeColor = _selectedColor.CGColor;
    }
    _outerBody.lineWidth = 3.0;
    _outerBody.frame = self.bounds;
    _outerBody.path = outerPath.CGPath;

    UIBezierPath *innerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_innerBorderWidth + 2.0, _innerBorderWidth + 2.0, CGRectGetWidth(self.bounds) - ((_innerBorderWidth + 2.0) * 2.0), CGRectGetHeight(self.bounds) - ((_innerBorderWidth + 2.0) * 2.0))];
    if (self.isEnabled) {
        _innerBody.fillColor = _normalStateColor.CGColor;
    } else {
        _innerBody.fillColor = _selectedColor.CGColor;
    }
    _innerBody.frame = self.bounds;
    _innerBody.path = innerPath.CGPath;



    if (_image) {
        [self drawImage];
    } else if (_title) {
        [self drawSubtractedText:_title];
    }

    [_outerBody setNeedsDisplay];
    [_innerBody setNeedsDisplay];
}

- (void)drawImage
{
    _image = [_image resizeImageToRectIfNeeded:self.innerBody.bounds];
    _imageLayer.mask = _innerBody;
    _imageLayer.frame = self.innerBody.bounds;
    [_imageLayer setContents:(id)_image.CGImage];
    [self.layer addSublayer:_imageLayer];

}

- (void)drawSubtractedText:(NSString *)text
{

    UILabel *textLabel = [[UILabel alloc] initWithFrame:[self bounds]];
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    [textLabel setFont:[UIFont systemFontOfSize:90.0]];
    [textLabel setAdjustsFontSizeToFitWidth:YES];
    [textLabel setMinimumScaleFactor:0.1];
    [textLabel setNumberOfLines:1];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextColor:[UIColor whiteColor]];
    NSNumber *baselineModifier = @(textLabel.font.lineHeight / 16.0);
    [textLabel setAttributedText:[[NSAttributedString alloc] initWithString:text
                                                                 attributes:@{ NSBaselineOffsetAttributeName : baselineModifier }]];
    UIGraphicsBeginImageContext(textLabel.bounds.size);
    [textLabel drawViewHierarchyInRect:textLabel.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [image invertAlpha];
    _imageLayer.frame = self.bounds;
    [_imageLayer setContents:(id)image.CGImage];
    _innerBody.mask = _imageLayer;
}

- (IBAction)startPushAnimation:(id)sender
{
    _innerBody.fillColor = _selectedColor.CGColor;
    _outerBody.strokeColor = _selectedColor.CGColor;
    [_outerBody setNeedsDisplay];
    [_innerBody setNeedsDisplay];
    CABasicAnimation* shrink = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    shrink.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shrink.toValue = [NSNumber numberWithDouble:0.95];
    shrink.duration = 0.3;
    shrink.delegate = self;
    shrink.fillMode = kCAFillModeForwards;
    shrink.removedOnCompletion = NO;
    [[self layer] addAnimation:shrink forKey:@"shrink"];
}

- (IBAction)stopPushAnimation:(id)sender
{
    _innerBody.fillColor = _normalStateColor.CGColor;
    _outerBody.strokeColor = _normalStateColor.CGColor;
    [_outerBody setNeedsDisplay];
    [_innerBody setNeedsDisplay];
    CATransform3D scaleTransform = [(CALayer *)[self.layer presentationLayer] transform];
    float scale = scaleTransform.m11;
    CABasicAnimation* shrink = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    shrink.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shrink.toValue = [NSNumber numberWithDouble:1.0];
    shrink.fromValue = @(scale);
    shrink.duration = 0.3;
    shrink.delegate = self;
    [[self layer] addAnimation:shrink forKey:@"shrink"];
}

#pragma mark - Accessor Methods

- (void)setInnerBorderWidth:(CGFloat)innerBorderWidth
{
    if (_innerBorderWidth != innerBorderWidth) {
        _innerBorderWidth = innerBorderWidth;
        [self setLayerProperties];
    }
}

- (void)setNormalStateColor:(UIColor *)normalStateColor
{
    _normalStateColor = normalStateColor;
    _selectedColor = [_normalStateColor colorWithAlphaComponent:0.8];
    [self setLayerProperties];
}

- (void)setTitle:(NSString *)title
{
    if (![_title isEqualToString:title]) {
        _title = title;
        [self setLayerProperties];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setLayerProperties];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setLayerProperties];
}

@end
