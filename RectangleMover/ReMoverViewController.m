//
//  ReMoverViewController.m
//  RectangleMover
//
//  Created by Robert Sikorski on 8/1/14.
//  Copyright (c) 2014 Sikorski. All rights reserved.
//

#import "ReMoverViewController.h"

@interface ReMoverViewController ()

@property CGPoint imageOriginalCenter;
@property CGPoint initialTouch;
@property BOOL touchAboveCenter;
@property int leftBound;
@property int rightBound;
@property int anchorOffset;
@property float bounceOffset;
@property float bounceBackOffset;

- (IBAction)newRectButtonPressed:(UIButton *)sender;
- (IBAction)imagePanned:(UIPanGestureRecognizer *)sender;

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
    self.touchAboveCenter = YES;
    self.anchorOffset = 900;
    self.bounceOffset = 10;
    self.bounceBackOffset = -5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)newRectButtonPressed:(UIButton *)sender {
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
            self.RectangleImage.center = [self newCenterForPanTranslation:sender];
            self.RectangleImage.transform = [self rotationForPanTranslation:[sender velocityInView:[self.RectangleImage superview]]
                                                           withAnchorBelow:self.touchAboveCenter];
            break;
        }
        case UIGestureRecognizerStateBegan: {
            self.initialTouch = [sender locationOfTouch:0 inView:[self.RectangleImage superview]];
            CGPoint touch = [sender locationOfTouch:0 inView:self.RectangleImage];
            self.touchAboveCenter = (touch.y < self.RectangleImage.bounds.size.height/2);
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
-(float)offsetY:(BOOL)anchorBelow {
    float offsetY = self.anchorOffset;
    if (!anchorBelow) {
        offsetY = -offsetY;
    }
    return offsetY;
}

-(float)anchorY:(BOOL)anchorBelow {
    // Anchor value chosen based on what most closely creates the angles we
    // want in our rectangle, based on testing.
    float adjacentY = self.imageOriginalCenter.y;
    if (anchorBelow) {
        adjacentY += self.anchorOffset;
    } else {
        adjacentY -= self.anchorOffset;
    }
    return adjacentY;
}

-(float)tanAngleFromX:(float) x andY:(float)y {
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

-(CGPoint)newCenterForPanTranslation:(UIPanGestureRecognizer*) sender {
    float dxTouch = ([sender locationOfTouch:0 inView:[self.RectangleImage superview]].x - self.initialTouch.x);
    float offsetY = [self offsetY:self.touchAboveCenter];
    float angle = [self tanAngleFromX:dxTouch andY:offsetY]; // only X affects angle, but the actual image center will slide up and down on the hypotenuse
    float dyTouch = ([sender locationOfTouch:0 inView:[self.RectangleImage superview]].y - self.initialTouch.y);

    CGPoint center = self.imageOriginalCenter;
    center.x += tanf(angle)*(offsetY-dyTouch);
    center.y = [self anchorY:self.touchAboveCenter]-(offsetY-dyTouch);
    return center;
}

-(CGAffineTransform)rotationForPanTranslation:(CGPoint) velocity withAnchorBelow:(BOOL)anchorBelow {
    CGAffineTransform transform = self.RectangleImage.transform;
    float y = (self.RectangleImage.center.y - [self anchorY:anchorBelow]); // never 0 thanks to sizes chosen
    float x = (self.imageOriginalCenter.x-self.RectangleImage.center.x);
    float theta = [self tanAngleFromX:x andY:y];

    transform.a =  cosf(theta);
    transform.b =  sinf(theta);
    transform.c = -sinf(theta);
    transform.d =  cosf(theta);

    return transform;
}

#pragma mark -
#pragma mark Final Animation Methods

-(CGPoint)bounceTargetFromAngle:(float) angle andOffset:(float)offset {
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

-(void)doPostGestureAnimations {
    float x = self.imageOriginalCenter.x - self.RectangleImage.center.x;
    float y = self.imageOriginalCenter.y - self.RectangleImage.center.y;
    if (!(y == 0 && x == 0)) {
        float angle = [self tanAngleFromX:x andY:y];
        CGPoint bounceTarget = [self bounceTargetFromAngle:angle andOffset:self.bounceOffset];
        CGPoint negativeBounceTarget = [self bounceTargetFromAngle:angle andOffset:self.bounceBackOffset];

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
}

@end