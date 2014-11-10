//
//  ViewController.h
//  Example
//
//  Created by Jan Koch on 10/11/14.
//
//

#import <UIKit/UIKit.h>
#import "JKRoundSlider.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet JKRoundSlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

- (IBAction)valueChanged:(id)sender;

@end

