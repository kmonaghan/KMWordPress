//
//  KMPostHelpView.m
//  KMWordPress
//
//  Created by Karl Monaghan on 13/02/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMPostHelpView.h"

@interface KMPostHelpView()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *helpView;

- (IBAction)didTapAction:(id)sender;
@end

@implementation KMPostHelpView
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
    CGFloat height = 460.0f;
    if ([UIScreen mainScreen].bounds.size.height == 568.0f)
    {
        height = 504.0f;
        
        self.helpView.$y += 44.0f;
        self.pageControl.$y = 504.0f - self.pageControl.$height - 10.0f;
        self.scrollView.$height = height;
    }
    
    self.scrollView.contentSize = CGSizeMake(960.0f, height);
}

- (IBAction)didTapAction:(id)sender
{
    if (self.pageControl.currentPage != 2)
    {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + 320.0f, 0) animated:YES];
    }
    else
    {
        [self closeAction:nil];
    }
}

- (IBAction)closeAction:(id)sender
{
    [UIView animateWithDuration:0.3f
                     animations:^() {
                         [self setAlpha:0];
                     }
                     completion:^(BOOL finsihed) {
                         [self removeFromSuperview];
                     }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = (int)floorf(scrollView.contentOffset.x / 320);
}

@end
