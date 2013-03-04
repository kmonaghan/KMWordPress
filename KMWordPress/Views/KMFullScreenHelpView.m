//
//  KMFullScreenHelpView.m
//  KMWordPress
//
//  Created by Karl Monaghan on 20/02/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMFullScreenHelpView.h"

@interface KMFullScreenHelpView()
@property (strong, nonatomic) IBOutlet UIImageView *backButton;
@property (strong, nonatomic) IBOutlet UILabel *backButtonLabel;

@end

@implementation KMFullScreenHelpView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    if ([UIScreen mainScreen].bounds.size.height == 568.0f)
    {
        self.$height = 568.0f;
        
        self.backButton.$y = 558.0f - self.backButton.$height;
        self.backButtonLabel.$y = 558.0f - self.backButtonLabel.$height;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)dismiss:(id)sender
{
    [UIView animateWithDuration:0.3f
                     animations:^() {
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finsihed) {
                         [self removeFromSuperview];
                     }];
}

- (IBAction)dismissTap:(id)sender
{
    [self dismiss:nil];
}
@end
