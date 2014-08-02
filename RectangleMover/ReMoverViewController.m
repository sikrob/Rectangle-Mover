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

    // Options for rotating:
    // Set anchor point, let them rotate... necessitates some oddities where doing the positioning is concerned...
    // OR
    // Calculate out how much to rotate the center on our own, pretending for a certain point of rotation out from center.
    // More mathy, probably.
    
    // let's just play with the anchor point here first...
    [_RectangleImage.layer setAnchorPoint:CGPointMake(0.5, 0)];
    [_RectangleImage.layer setPosition:CGPointMake(_RectangleImage.frame.origin.x+(_RectangleImage.frame.size.width/2),
                                                   _RectangleImage.frame.origin.y-(_RectangleImage.frame.size.width/2))];
    
    _imageOriginalCenter = _RectangleImage.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)NewRectButtonPressed:(UIButton *)sender {
    _RectangleImage.layer.opacity = 0;
    _RectangleImage.center = _imageOriginalCenter;

    [UIView animateWithDuration:.25 animations:^{
        _RectangleImage.layer.opacity = 1.0;
    }];
    
    _NewRectangleButton.enabled = NO;
}


- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:{
            CGPoint delta;
            delta = [sender translationInView:[_RectangleImage superview]];
            delta.x = _imageOriginalCenter.x+delta.x;
            delta.y = _imageOriginalCenter.y+delta.y;
            _RectangleImage.center = delta;

            // if pan below center, anchor is above and vice versa
            
            break;
        }
        case UIGestureRecognizerStateBegan: {

            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (_RectangleImage.center.x > 100 && _RectangleImage.center.x < 210) {
                [UIView animateWithDuration:.2 animations:^{
                    _RectangleImage.center = _imageOriginalCenter;
                    // this also need to unwrap the rotation
                } completion:^(BOOL finished){
                    if (finished) {
                        // Need to create a bounce animation... initial thoughts:
                        // determine vector of travel; over apply by a small amount past actual originalCenter,
                        // then do the same in the opposite direction, then go to center.
                    }
                }];

            } else {
                [UIView animateWithDuration:.2 animations:^{
                    CGPoint offScreenPoint;
                    offScreenPoint.y = _RectangleImage.center.y;
                    if (_RectangleImage.center.x > 210) {
                        offScreenPoint.x = _RectangleImage.frame.size.height*2;
                    } else {
                        offScreenPoint.x = -_RectangleImage.frame.size.height*2;
                    }
                    _RectangleImage.center = offScreenPoint;
                }];
                _NewRectangleButton.enabled = YES;
            }
            break;
        }
        default:
            // Nothing special for other states, just default to catch them.
            break;
    }

}

@end
