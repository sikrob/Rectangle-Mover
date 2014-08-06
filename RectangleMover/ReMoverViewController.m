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

    self.RectangleImage.userInteractionEnabled = YES;
    self.NewRectangleButton.enabled = NO;
    
    self.imageOriginalCenter = self.RectangleImage.center;
    
    self.leftBound = 90;
    self.rightBound = 220;
    self.anchorOffset = 1000;
    self.bounceOffset = 10;
    self.bounceBackOffset = -5;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)NewRectButtonPressed:(UIButton *)sender {
    self.RectangleImage.transform = CGAffineTransformIdentity;
    self.RectangleImage.layer.opacity = 0;
    self.RectangleImage.center = self.imageOriginalCenter;
    
    [UIView animateWithDuration:.25 animations:^{
        self.RectangleImage.layer.opacity = 1.0;
    }];
    
    self.NewRectangleButton.enabled = NO;
}

- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:{
            self.RectangleImage.center = [self getNewCenterForPanTranslation:sender];
            self.RectangleImage.transform = [self getRotationForPanTranslation:[sender velocityInView:[self.RectangleImage superview]]
                                                           withAnchorBelow:self.touchOnTop];
            break;
        }
        case UIGestureRecognizerStateBegan: {
            CGPoint touch = [sender locationOfTouch:0 inView:self.RectangleImage];
            self.touchOnTop = (touch.y < self.RectangleImage.bounds.size.height/2);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            float x = self.imageOriginalCenter.x - self.RectangleImage.center.x;
            float y = self.imageOriginalCenter.y - self.RectangleImage.center.y;
            if (!(y == 0 && x == 0)) {
                float angle = [self getATanAngleFromX:x andY:y];
                CGPoint bounceTarget = [self getBounceTargetFromAngle:angle andOffset:self.bounceOffset];
                CGPoint negativeBounceTarget = [self getBounceTargetFromAngle:angle andOffset:self.bounceBackOffset];

                if (self.RectangleImage.center.x > self.leftBound && self.RectangleImage.center.x < self.rightBound) {
                    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        self.RectangleImage.center = bounceTarget;
                        self.RectangleImage.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished){
                        if (finished) {
                            [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                self.RectangleImage.center = negativeBounceTarget;
                            } completion:^(BOOL finished) {
                                if (finished) {
                                    [UIView animateWithDuration:.1 animations:^{
                                        self.RectangleImage.center = self.imageOriginalCenter;
                                    }];
                                }
                            }];
                        }
                    }];
                } else {
                    [UIView animateWithDuration:.2 animations:^{
                        CGPoint offScreenPoint;
                        offScreenPoint.y = self.RectangleImage.center.y;
                        if (self.RectangleImage.center.x > self.rightBound) {
                            offScreenPoint.x = self.RectangleImage.frame.size.height*2;
                        } else {
                            offScreenPoint.x = -self.RectangleImage.frame.size.height*2;
                        }
                        self.RectangleImage.center = offScreenPoint;
                    }];
                    self.NewRectangleButton.enabled = YES;
                }
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
    delta = [panGestureRecognizer translationInView:[self.RectangleImage superview]];
    delta.x = self.imageOriginalCenter.x+delta.x;
    delta.y = self.imageOriginalCenter.y+delta.y;
    return delta;
}

-(CGAffineTransform) getRotationForPanTranslation:(CGPoint) velocity withAnchorBelow:(BOOL)anchorBelow {
    CGAffineTransform transform = self.RectangleImage.transform;
    float y = ([self getAnchorY:anchorBelow] -self.RectangleImage.center.y); // never 0 thanks to sizes chosen
    float x = (self.imageOriginalCenter.x-self.RectangleImage.center.x);
    float theta = [self getATanAngleFromX:x andY:y];

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
    float adjacentY = self.imageOriginalCenter.y;
    if (anchorBelow) {
        adjacentY -= self.anchorOffset;
    } else {
        adjacentY += self.anchorOffset;
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

-(CGPoint) getBounceTargetFromAngle:(float) angle andOffset:(float)offset {
    CGPoint target = self.imageOriginalCenter;
    if (self.imageOriginalCenter.x < self.RectangleImage.center.x) {
        if (self.imageOriginalCenter.y < self.RectangleImage.center.y) {
            target.x -= sinf(angle)*offset;
            target.y -= cosf(angle)*offset;
        } else {
            target.x += sinf(angle)*offset;
            target.y += cosf(angle)*offset;
        }
    } else {
        if (self.imageOriginalCenter.y < self.RectangleImage.center.y) {
            target.x -= sinf(angle)*offset;
            target.y -= cosf(angle)*offset;
        } else {
            target.x += sinf(angle)*offset;
            target.y += cosf(angle)*offset;
        }
    }

    return target;
}

@end
