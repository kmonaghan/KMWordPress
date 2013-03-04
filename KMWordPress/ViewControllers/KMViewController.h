//
//  KMViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 09/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMViewController : UIViewController
@property (nonatomic, strong) UIButton *fullScreen;
@property (nonatomic, strong) UIButton *backButton;

- (void)fullScreenToggle:(id)sender;
- (void)makeFullscreen:(BOOL)fullscreen;
- (void)attachBackSwipe:(UIView *)view;
- (void)back;
@end
