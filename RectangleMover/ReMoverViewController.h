//
//  ReMoverViewController.h
//  RectangleMover
//
//  Created by Robert Sikorski on 8/1/14.
//  Copyright (c) 2014 Sikorski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReMoverViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *MainView;
@property (weak, nonatomic) IBOutlet UIImageView *RectangleImage;
@property (weak, nonatomic) IBOutlet UIButton *NewRectangleButton;

@end
