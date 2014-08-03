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
    _anchorOffset = 1000;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)NewRectButtonPressed:(UIButton *)sender {
    _RectangleImage.transform = CGAffineTransformIdentity;
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

            _RectangleImage.center = [self getNewCenterForPanTranslation:sender];
            _RectangleImage.transform = [self getRotationForPanTranslation:[sender velocityInView:[_RectangleImage superview]]
                                                           withAnchorBelow:_touchOnTop];

            break;
        }
        case UIGestureRecognizerStateBegan: {
            NSLog(@"\n\nNew pan event.");
            CGPoint touch = [sender locationOfTouch:0 inView:_RectangleImage];
            _touchOnTop = (touch.y < _RectangleImage.bounds.size.height/2);
            

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

-(CGPoint) getNewCenterForPanTranslation:(UIPanGestureRecognizer*)panGestureRecognizer {
    CGPoint delta;
    delta = [panGestureRecognizer translationInView:[_RectangleImage superview]];
    delta.x = _imageOriginalCenter.x+delta.x;
    delta.y = _imageOriginalCenter.y+delta.y;
    return delta;
}

-(CGAffineTransform) getRotationForPanTranslation:(CGPoint) velocity withAnchorBelow:(BOOL)anchorBelow {
    CGAffineTransform transform = _RectangleImage.transform;
    // get y
    float y = ([self getAnchorY:anchorBelow] -_RectangleImage.center.y); // never 0 thanks to sizes chosen

    // get x
    float x = (_imageOriginalCenter.x-_RectangleImage.center.x);

    // get theta
    float theta = atanf(x/y);

    // apply
    transform.a =  cosf(theta);
    transform.b =  sinf(theta);
    transform.c = -sinf(theta);
    transform.d =  cosf(theta);

    return transform;
}

-(float) getAnchorY:(BOOL)anchorBelow {
    // Anchor value chosen based on what most closely creates the angles we
    // want in our rectangle, based on testing.

    // Bonus: As long as our anchor value is longer than 233+568, we never
    // have to worry about /0 errors in the angle calculation (see getRotationforPanTranslation)
    // • 233 is longest path to center of the rectangle
    // • 568 is bottom of screen
    // • 233+568 = the farthest the rect center can go.

    float adjacentY = _imageOriginalCenter.y;
    if (anchorBelow) {
        adjacentY -= _anchorOffset;
    } else {
        adjacentY += _anchorOffset;
    }
    return adjacentY;
}

@end
