//
//  UIView+KMWordPress.m
//  KMWordPress
//
//  Created by Karl Monaghan on 11/02/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "UIView+KMWordPress.h"

@implementation UIView (KMWordPress)
+ (instancetype)viewFromNib
{
    UIView *customView = nil;
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                      owner:nil
                                                    options:nil];
    
    for (id anObject in elements)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            customView = anObject;
            break;
        }
    }
    
    return customView;
}

- (void)circleTheSquare:(UIColor *)edgeColor
{
    self.layer.borderColor = edgeColor.CGColor;
    self.layer.borderWidth = 2.0f;
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
}
@end
