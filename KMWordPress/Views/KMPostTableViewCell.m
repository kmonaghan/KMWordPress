//
//  KMPostTableViewCell.m
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"
#import "NSString+HTML.h"
#import "TTTAttributedLabel.h"

#import "KMPostListViewController.h"
#import "KMPostTableViewCell.h"

#import "KMWordPressPost.h"

//NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];

@interface KMPostTableViewCell()
@property (strong, nonatomic) IBOutlet UIImageView *storyImage;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *storyTitle;
@property (strong, nonatomic) IBOutlet UILabel *storyDate;
@property (strong, nonatomic) IBOutlet UILabel *storyComments;

@end

@implementation KMPostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.storyImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.storyImage.layer.borderWidth = 1.0f;
    self.storyImage.layer.cornerRadius = 4.0f;
    self.storyImage.clipsToBounds = YES;
    
    self.storyTitle.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    UISwipeGestureRecognizer *leftswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(viewPost)];
    
    leftswipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftswipe];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.storyTitle.text = nil;
    self.storyTitle.frame = CGRectMake(10.0f, 10.0f, 300.0f, 42.0f);
    self.storyDate.text = nil;
    self.storyComments.text = nil;
    self.storyImage.image = [UIImage imageNamed:@"default-post-image.png"];
    self.storyDate.$y = self.storyTitle.$bottom;
    self.storyComments.$y = self.storyTitle.$bottom;
    self.storyImage.$y = self.storyDate.$bottom + 5.0f;;
}

- (void)showPost:(KMWordPressPost *)post
{
    self.storyTitle.text = [post.titlePlain stringByReplacingHTMLEntities];
    
    if ([post.postDate earlierDate:self.yesterday] == post.postDate)
    {
        self.storyDate.text = [post formattedDate];
    }
    else
    {
        self.storyDate.text = [post relativeDate];
    }
    
    if ([post getThumbnailUrl])
    {
        [self.storyImage setImageWithURL:[NSURL URLWithString:[post getThumbnailUrl]]
                        placeholderImage:[UIImage imageNamed:@"default-post-image.png"]];
    }
    
    if ([post.commentCount intValue])
    {
        NSMutableString *commentText = [[NSString stringWithFormat:NSLocalizedString(@"%@ comment", nil), post.commentCount] mutableCopy];
        
        if ([post.commentCount intValue] > 1)
        {
            [commentText appendString:@"s"];
        }
        
        self.storyComments.text = commentText;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.storyTitle sizeToFit];

    self.storyDate.$y = self.storyTitle.$bottom;
    self.storyComments.$y = self.storyTitle.$bottom;
    self.storyImage.$y = self.storyDate.$bottom + 5.0f;
}

- (void)viewPost
{
    [self.parentViewController viewPost:self];
}
@end
