//
//  KMCommentHelpView.m
//  KMWordPress
//
//  Created by Karl Monaghan on 06/03/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMCommentHelpView.h"

#import "KMWordPressPostControl.h"

@interface KMCommentHelpView()
- (IBAction)didTapAction:(id)sender;
@end

@implementation KMCommentHelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)didTapAction:(id)sender
{
    [UIView animateWithDuration:0.3f
                     animations:^() {
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finsihed) {
                         [self removeFromSuperview];
                         [self.buttonControl viewComments];
                     }];
}
@end
