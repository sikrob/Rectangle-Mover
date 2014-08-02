//
//  ReMoverViewController.m
//  RectangleMover
//
//  Created by Robert Sikorski on 8/1/14.
//  Copyright (c) 2014 Sikorski. All rights reserved.
//

#import "ReMoverViewController.h"

@interface ReMoverViewController ()

@end

@implementation ReMoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
/*  // If we wanted to do it programatically, we could use the following commented code; we'd need to create a method titled imageTapped as well.
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [_RectangleImage addGestureRecognizer:tapGestureRecognizer];*/

    _RectangleImage.userInteractionEnabled = YES; // Need despite "User Interaction Enabled" checked for UIImageView
    _NewRectangleButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)NewRectButtonPressed:(UIButton *)sender {
    _RectangleImage.transform = CGAffineTransformIdentity;
    // fade in animation
}


- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:{
            CGPoint delta;
            delta = [sender translationInView:[_RectangleImage superview]];
            delta.x = _initialPanPoint.x+delta.x;
            delta.y = _initialPanPoint.y+delta.y;
            _RectangleImage.center = delta;
            break;
        }
        case UIGestureRecognizerStateBegan: {
            _initialPanPoint = _RectangleImage.center;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // if out of bound
            //  shift to side, 'remove'(hide)
            // if in bound
            [UIView animateWithDuration:.2 animations:^{
                _RectangleImage.center = _initialPanPoint;
            }];
            break;
        }
        default:
            // Nothing special for other states, just default to catch them.
            break;
    }

}

@end
