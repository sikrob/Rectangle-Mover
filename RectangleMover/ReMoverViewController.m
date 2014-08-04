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
    _touchAboveCenter = YES;
    _anchorOffset = 900;
    _bounceOffset = 10;
    _bounceBackOffset = -5;
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
                                                           withAnchorBelow:_touchAboveCenter];
            break;
        }
        case UIGestureRecognizerStateBegan: {
            _initialTouch = [sender locationOfTouch:0 inView:[_RectangleImage superview]];
            CGPoint touch = [sender locationOfTouch:0 inView:_RectangleImage];
            _touchAboveCenter = (touch.y < _RectangleImage.bounds.size.height/2);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self doPostGestureAnimations];
            break;
        }
        default:
            // Nothing special for other states, just default to catch them.
            break;
    }

}

#pragma mark -
#pragma mark Angles and Anchors
-(float) getOffsetY:(BOOL)anchorBelow {
    float offsetY = _anchorOffset;
    if (!anchorBelow) {
        offsetY = -offsetY;
    }
    return offsetY;
}

-(float) getAnchorY:(BOOL)anchorBelow {
    // Anchor value chosen based on what most closely creates the angles we
    // want in our rectangle, based on testing.
    float adjacentY = _imageOriginalCenter.y;
    if (anchorBelow) {
        adjacentY += _anchorOffset;
    } else {
        adjacentY -= _anchorOffset;
    }
    return adjacentY;
}

-(float) getATanAngleFromX:(float) x andY:(float)y {
    float theta = 0.0;
    if (y != 0) {
        theta = atanf(x/y);
    } else if (x > 0) {
        theta = M_PI/2;
    } else  if (x < 0) {
        theta = M_PI*1.5;
    }
    return theta;
}


#pragma mark -
#pragma mark Translation and Rotation

-(CGPoint) getNewCenterForPanTranslation:(UIPanGestureRecognizer*) sender {
    float dxTouch = ([sender locationOfTouch:0 inView:[_RectangleImage superview]].x - _initialTouch.x);
    float offsetY = [self getOffsetY:_touchAboveCenter];
    float angle = [self getATanAngleFromX:dxTouch andY:offsetY]; // only X affects angle, but the actual image center will slide up and down on the hypotenuse
    float dyTouch = ([sender locationOfTouch:0 inView:[_RectangleImage superview]].y - _initialTouch.y);

    CGPoint center = _imageOriginalCenter;
    center.x += tanf(angle)*(offsetY-dyTouch);
    center.y = [self getAnchorY:_touchAboveCenter]-(offsetY-dyTouch);
    return center;
}

-(CGAffineTransform) getRotationForPanTranslation:(CGPoint) velocity withAnchorBelow:(BOOL)anchorBelow {
    CGAffineTransform transform = _RectangleImage.transform;
    float y = (_RectangleImage.center.y - [self getAnchorY:anchorBelow]); // never 0 thanks to sizes chosen
    float x = (_imageOriginalCenter.x-_RectangleImage.center.x);
    float theta = [self getATanAngleFromX:x andY:y];

    transform.a =  cosf(theta);
    transform.b =  sinf(theta);
    transform.c = -sinf(theta);
    transform.d =  cosf(theta);

    return transform;
}

#pragma mark -
#pragma mark Final Animation Methods

-(CGPoint) getBounceTargetFromAngle:(float) angle andOffset:(float)offset {
    CGPoint target = _imageOriginalCenter;
    if (_imageOriginalCenter.x < _RectangleImage.center.x) {
        if (_imageOriginalCenter.y < _RectangleImage.center.y) {
            target.x -= sinf(angle)*offset;
            target.y -= cosf(angle)*offset;
        } else {
            target.x += sinf(angle)*offset;
            target.y += cosf(angle)*offset;
        }
    } else {
        if (_imageOriginalCenter.y < _RectangleImage.center.y) {
            target.x -= sinf(angle)*offset;
            target.y -= cosf(angle)*offset;
        } else {
            target.x += sinf(angle)*offset;
            target.y += cosf(angle)*offset;
        }
    }

    return target;
}

-(void) doPostGestureAnimations {
    float x = _imageOriginalCenter.x - _RectangleImage.center.x;
    float y = _imageOriginalCenter.y - _RectangleImage.center.y;
    if (!(y == 0 && x == 0)) {
        float angle = [self getATanAngleFromX:x andY:y];
        CGPoint bounceTarget = [self getBounceTargetFromAngle:angle andOffset:_bounceOffset];
        CGPoint negativeBounceTarget = [self getBounceTargetFromAngle:angle andOffset:_bounceBackOffset];

        if (_RectangleImage.center.x > _leftBound && _RectangleImage.center.x < _rightBound) {
            [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                _RectangleImage.center = bounceTarget;
                _RectangleImage.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (finished) {
                    [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        _RectangleImage.center = negativeBounceTarget;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [UIView animateWithDuration:.1 animations:^{
                                _RectangleImage.center = _imageOriginalCenter;
                            }];
                        }
                    }];
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
    }
}

@end