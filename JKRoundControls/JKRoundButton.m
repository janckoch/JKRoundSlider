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
@property (strong, nonatomic) UILabel *titleRenderLabel;

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
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    [self addTarget:self action:@selector(startPushAnimation:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(stopPushAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(stopPushAnimation:) forControlEvents:UIControlEventTouchUpOutside];
    self.clipsToBounds = YES;
    _innerBorderWidth = 10.0;
    _normalStateColor = [UIColor whiteColor];
    _selectedColor = [_normalStateColor colorWithAlphaComponent:0.8];
    _titleRenderLabel = [[UILabel alloc] init];
}

- (void)addLayers
{
    [self setDefaults];

    _outerBody = [CAShapeLayer layer];
    [self.layer addSublayer:_outerBody];

    _innerBody = [CAShapeLayer layer];
    [self.layer addSublayer:_innerBody];

    _imageLayer = [CALayer layer];
    _imageLayer.contentsGravity = kCAGravityResizeAspect;
    _imageLayer.contentsScale = [UIScreen mainScreen].scale;

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
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width * [UIScreen mainScreen].scale, self.bounds.size.height * [UIScreen mainScreen].scale);
    [_titleRenderLabel setFrame:frame];
    [_titleRenderLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleRenderLabel setFont:[UIFont systemFontOfSize:490.0]];
    [_titleRenderLabel setAdjustsFontSizeToFitWidth:YES];
    [_titleRenderLabel setMinimumScaleFactor:0.1];
    [_titleRenderLabel setNumberOfLines:1];
    [_titleRenderLabel setBackgroundColor:[UIColor clearColor]];
    [_titleRenderLabel setTextColor:[UIColor whiteColor]];
    NSNumber *baselineModifier = @(_titleRenderLabel.font.lineHeight / 16.0);
    [_titleRenderLabel setAttributedText:[[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{ NSBaselineOffsetAttributeName : baselineModifier }]];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    UIGraphicsBeginImageContext(_titleRenderLabel.bounds.size);
    [_titleRenderLabel.layer drawInContext:UIGraphicsGetCurrentContext()];
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
