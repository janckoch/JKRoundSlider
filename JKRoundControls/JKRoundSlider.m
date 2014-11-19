//
//  JKRoundSlider.m
//
//  Created by Jan Koch on 07/11/14.
//

#import "JKRoundSlider.h"
#import "UIImage+JKAdditions.h"

#pragma mark - Helper Functions

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

#pragma mark - Defines

#define HANDLE_SIZE_INACTIVE 50.0
#define HANDLE_SIZE_ACTIVE 70.0
#define SLIDER_BODY_INNER_OUTER_GAP 15.0

@interface JKRoundSlider ()

@property (assign, nonatomic) float handleSize;
@property (assign, nonatomic) int angle;
@property (strong, nonatomic) UIBezierPath *innerTogglePath;
@property (assign, nonatomic) BOOL toggleTouch;

@end

@implementation JKRoundSlider

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super init]) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setDefaults];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setDefaults
{
    self.backgroundColor = [UIColor clearColor];
    _angle = 0.0;
    _handleSize = HANDLE_SIZE_INACTIVE;
    _primaryColor = [UIColor whiteColor];
    _secondaryColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    _title = @"";
    _font = [UIFont fontWithName:@"HelveticaNeue-Light" size:80];
    _toggleTouch = NO;
}

- (CGPoint)pointFromAngle:(int)angleInt
{
    CGFloat radius = (self.frame.size.width / 2 - HANDLE_SIZE_ACTIVE / 2) - 5;
    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - self.handleSize/2, self.frame.size.height/2 - self.handleSize/2);

    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));

    return result;
}

- (float)valueFromAngle
{
    float value;
    float fixedAngle = self.angle - 90;
    if(fixedAngle < 0) {
        value = -fixedAngle;
    } else {
        value = 270 - fixedAngle + 90;
    }
    value = (value * (0.0 - 100.0))/360.0f;
    return fabs(value);
}

- (float)angleFromValue {
    self.angle = 90 - (360.0f*_value/100.0);

    if(self.angle==360) self.angle=0;

    return self.angle;
}

// Taken from the Apple Clock example
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

#pragma mark - Draw Methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    [self clipHandle:context];

    float alphaValue = 0.5 + (0.3           * (self.value/100.0));
    self.secondaryColor = [self.secondaryColor colorWithAlphaComponent:alphaValue];

    // SliderBody Outer Drawing
    CGFloat sliderBodyOuterPathOffset = HANDLE_SIZE_ACTIVE / 2;
    CGFloat sliderBodyOuterPathSizeOffset = HANDLE_SIZE_ACTIVE;
    UIBezierPath* sliderBodyOuterPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(sliderBodyOuterPathOffset, sliderBodyOuterPathOffset, self.frame.size.width - sliderBodyOuterPathSizeOffset, self.frame.size.height - sliderBodyOuterPathSizeOffset  )];
    [[UIColor clearColor] setFill];
    [sliderBodyOuterPath fill];
    [self.primaryColor setStroke];
    sliderBodyOuterPath.lineWidth = 2;
    [sliderBodyOuterPath stroke];

    // SliderBody Inner Drawing
    CGFloat sliderBodyInnerPathOffset = sliderBodyOuterPathOffset + SLIDER_BODY_INNER_OUTER_GAP;
    CGFloat sliderBodyInnerPathSizeOffset = sliderBodyInnerPathOffset * 2;
    CGRect sliderBodyInnerRect = CGRectMake(sliderBodyInnerPathOffset, sliderBodyInnerPathOffset, self.frame.size.width - sliderBodyInnerPathSizeOffset, self.frame.size.height - sliderBodyInnerPathSizeOffset);
    UIBezierPath *sliderBodyInnerPath = [UIBezierPath bezierPathWithOvalInRect: sliderBodyInnerRect];
    [self.secondaryColor setFill];
    [sliderBodyInnerPath fill];
    [self.secondaryColor setStroke];
    sliderBodyInnerPath.lineWidth = 0;
    [sliderBodyInnerPath stroke];
    NSMutableParagraphStyle* ovalStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    ovalStyle.alignment = NSTextAlignmentCenter;
    CGContextRestoreGState(context);
    if (!self.image) {
        [self drawSubtractedText:self.title inRect:sliderBodyInnerRect inContext:context];
    } else {
        // Draw Image
        self.image = [self.image resizeImageToRectIfNeeded:sliderBodyInnerRect];
        CGContextSaveGState(context);
        [sliderBodyInnerPath addClip];
        [self.image drawInRect:sliderBodyInnerRect blendMode:kCGBlendModeNormal alpha:alphaValue];
        CGContextRestoreGState(context);
    }


    [self drawHandle:context];

    CGRect innerToggleRect = CGRectMake(sliderBodyInnerPathOffset + 20.0, sliderBodyInnerPathOffset + 20.0, self.frame.size.width - sliderBodyInnerPathSizeOffset - 40.0, self.frame.size.height - sliderBodyInnerPathSizeOffset - 40.0);
    self.innerTogglePath = [UIBezierPath bezierPathWithOvalInRect:innerToggleRect];

}

- (void)clipHandle:(CGContextRef)context
{
    CGPoint handleCenter =  [self pointFromAngle: self.angle];
    CGContextAddRect(context, self.bounds);
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(handleCenter.x, handleCenter.y, self.handleSize, self.handleSize), NULL);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextEOClip(context);
}

- (void)drawSubtractedText:(NSString *)text inRect:(CGRect)rect inContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    label.font = self.font;
    label.adjustsFontSizeToFitWidth = YES;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label.layer drawInContext:context];
    CGContextRestoreGState(context);
}

- (void)drawHandle:(CGContextRef)context
{
    CGPoint handleCenter =  [self pointFromAngle:self.angle];
    CGContextSaveGState(context);

    // Inner Circle
    [self.secondaryColor set];
    CGContextFillEllipseInRect(context, CGRectMake(handleCenter.x + (SLIDER_BODY_INNER_OUTER_GAP / 2.0), handleCenter.y + (SLIDER_BODY_INNER_OUTER_GAP / 2.0), self.handleSize - SLIDER_BODY_INNER_OUTER_GAP, self.handleSize - SLIDER_BODY_INNER_OUTER_GAP));

    // Outer Circle
    [self.primaryColor set];
    CGContextSetLineWidth(context, 2);
    CGContextStrokeEllipseInRect(context, CGRectMake(handleCenter.x, handleCenter.y, self.handleSize, self.handleSize));

    CGContextRestoreGState(context);
}

- (void)moveHandle:(CGPoint)lastPoint
{
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);

    self.angle = 360 - angleInt;
    float newValue = [self valueFromAngle];
    // Boundary
    if (self.value > 90.0 && newValue < 80.0) {
        self.value = 100.0;
        self.angle = [self angleFromValue];
    } else if (self.value < 10.0 && newValue > 20.0) {
        self.value = 0.0;
        self.angle = [self angleFromValue];
    } else {
        self.value = newValue;
    }
    //Redraw
    [self setNeedsDisplay];
}

#pragma mark - UIControl Methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];

    if ([self.innerTogglePath containsPoint:[touch locationInView:self]]) {
        self.toggleTouch = YES;
        // TODO: Set Highlighted
    } else {
        self.toggleTouch = NO;
        CGPoint lastPoint = [touch locationInView:self];
        [self moveHandle:lastPoint];
        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
        //        [self sendActionsForControlEvents:UIControlEventValueChanged];
        self.handleSize = HANDLE_SIZE_ACTIVE;
        [self setNeedsDisplay];
    }

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];

    if (self.toggleTouch) {
        // TODO: Check if still in toggle box
    } else {
        CGPoint lastPoint = [touch locationInView:self];
        int oldValue = round(self.value);
        [self moveHandle:lastPoint];
        int newValue = round(self.value);
        if (oldValue != newValue) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.toggleTouch) {
        // TODO: Check if still in toggle box
        if (self.value > 0.0) {
            [self setValue:0.0];
        } else {
            [self setValue:100.0];
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        self.handleSize = HANDLE_SIZE_INACTIVE;
        [self setNeedsDisplay];
    }
}

#pragma mark - Accessor Methods

- (void)setValue:(float)value
{
    _value = value;

    if (_value > 100.0) {
        _value = 100.0;
    } else if(_value < 0.0) {
        _value = 0.0;
    }

    self.angle = [self angleFromValue];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

@end
