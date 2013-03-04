//
//  KMSwitchCell.m
//  KMWordPress
//
//  Created by Karl Monaghan on 13/02/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMSwitchCell.h"

@implementation KMSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.switchLabel.text = nil;
    self.itemSwitch.on = YES;
}

#pragma mark UIView
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.switchLabel.$y = 13.0f;
    self.switchLabel.$width = 175.0f;
    [self.switchLabel sizeToFit];
    
    if (self.contentView.$height > 44)
    {
        self.itemSwitch.$y = floorf((self.contentView.$height - self.itemSwitch.$height) / 2);
    }
    else
    {
        self.itemSwitch.$y = 8.0f;
    }
}

@end
