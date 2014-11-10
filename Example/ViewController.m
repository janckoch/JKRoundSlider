//
//  ViewController.m
//  Example
//
//  Created by Jan Koch on 10/11/14.
//
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) CAGradientLayer *gradient;

@end

@implementation ViewController

#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLabel];
    [self addGradient];
}

#pragma mark - Private Methods

- (void)addGradient
{
    UIColor *topColor = [UIColor colorWithRed:4.0/255.0 green:4.0/255.0 blue:45.0/255.0 alpha:1.0];
    UIColor *bottomColor = [UIColor colorWithRed:4.0/255.0 green:86.0/255.0 blue:155.0/255.0 alpha:1.0];

    self.gradient = [CAGradientLayer layer];
    self.gradient.startPoint = CGPointZero;
    self.gradient.endPoint = CGPointMake(1, 1);
    self.gradient.frame = self.view.bounds;
    self.gradient.colors = @[topColor, bottomColor];
    self.gradient.locations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.7]];
    [self.view.layer addSublayer:self.gradient];
}

- (void)updateLabel
{
    self.percentLabel.text = [NSString stringWithFormat:@"Value %.0f%%", self.slider.value];
}

- (IBAction)valueChanged:(id)sender
{
    [self updateLabel];
}

@end
