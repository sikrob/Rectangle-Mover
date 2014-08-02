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

    _RectangleImage.userInteractionEnabled = YES;
    _NewRectangleButton.enabled = NO;
    
    _imageOriginalCenter = _RectangleImage.center;
    
    _leftBound = 90;
    _rightBound = 220;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)NewRectButtonPressed:(UIButton *)sender {
    _RectangleImage.transform = CGAffineTransformIdentity;
//    _imageOriginalCenter = CGPointApplyAffineTransform(_imageOriginalCenter, _RectangleImage.transform);
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
            CGPoint newOrigin = _imageOriginalCenter;
//            newOrigin = CGPointApplyAffineTransform(newOrigin, _RectangleImage.transform);
            
            CGPoint delta;

            delta = [sender translationInView:[_RectangleImage superview]];
//            delta = CGPointApplyAffineTransform(delta, _RectangleImage.transform);
            delta.x = newOrigin.x+delta.x;
            delta.y = newOrigin.y+delta.y;
            
            
            
            _RectangleImage.center = delta;
            
            // if pan below center, anchor is above and vice versa
//            _RectangleImage.transform = CGAffineTransformRotate(_RectangleImage.transform, .1);//atanf((50)/(100)));

            _RectangleImage.transform = CGAffineTransformRotate(_RectangleImage.transform, atanf((_imageOriginalCenter.x-_RectangleImage.center.x)/(_imageOriginalCenter.y*2-_RectangleImage.center.y)));
            

            break;
        }
        case UIGestureRecognizerStateBegan: {
            // set top or bottom zone recognition?
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (_RectangleImage.center.x > _leftBound && _RectangleImage.center.x < _rightBound) {
                [UIView animateWithDuration:.2 animations:^{
                    _RectangleImage.center = _imageOriginalCenter;
                    _RectangleImage.transform = CGAffineTransformIdentity;

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
                    if (_RectangleImage.center.x > _rightBound) {
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
