//
//  KMCommentTableViewCell.m
//  KMWordPress
//
//  Created by Karl Monaghan on 30/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMCommentListViewController.h"
#import "KMWebViewController.h"

#import "KMCommentTableViewCell.h"

#import "KMWordPressPostComment.h"

float const childIndent = 15.0f;

@interface KMCommentTableViewCell()
{
	NSUInteger _htmlHash; // preserved hash to avoid relayouting for same HTML
}

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *commentDate;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;

@property (strong, nonatomic) KMWordPressPostComment* comment;

- (IBAction)replyAction:(id)sender;

@end

@implementation KMCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.hasFixedRowHeight = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    self.avatar.layer.borderColor = [UIColor grayColor].CGColor;
    self.avatar.layer.borderWidth = 1.0f;
    self.avatar.layer.cornerRadius = 4.0f;
    self.avatar.clipsToBounds = YES;
    
    [self.contentView addSubview:self.attributedTextContextView];
    self.attributedTextContextView.delegate = self;
    
    UISwipeGestureRecognizer *leftswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(replyAction:)];
    
    leftswipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftswipe];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.username.text = nil;
    self.commentDate.text = nil;
    
    self.comment = nil;
    self.attributedTextContextView.frame = CGRectMake(10.0f, 58.0f, 300.0f, 25.0f);
}

- (void)showComment:(KMWordPressPostComment *)comment
{
    self.comment = comment;
    
    self.username.text = comment.name;
    self.commentDate.text = [comment formattedDate];
    
    if (comment.avatar)
    {
        [self.avatar setImageWithURL:[NSURL URLWithString:comment.avatar]
                    placeholderImage:[UIImage imageNamed:@"default-user.png"]];
    }

    [self setHTMLString:comment.content];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    CGFloat allowedContentSize = self.contentView.$width - 20.0f;
    
    CGFloat offset = ([self.comment.parent intValue]) ? childIndent : 0;
    
    offset = (self.comment.childLevel == 1) ? offset : offset * 2;
    
    self.avatar.frame = CGRectMake(10.0f + offset, 10.0f, 40.0f, 40.0f);
    self.username.frame = CGRectMake(60.0f + offset, 10.0f, 210.0f - offset, 21.0f);
    self.commentDate.frame = CGRectMake(60.0f + offset, 29.0f, 210.0f - offset, 21.0f);
    
	CGSize neededSize = [self.attributedTextContextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:allowedContentSize - offset];
	// after the first call here the content view size is correct
	CGRect frame = CGRectMake(10.0f + offset, 58.0f, allowedContentSize - offset, neededSize.height);
	
	if ((self.attributedTextContextView.frame.size.height != frame.size.height)
        || (self.attributedTextContextView.frame.size.width != frame.size.width))
	{
		self.attributedTextContextView.frame = frame;
	}
}

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
	if (self.hasFixedRowHeight)
	{
		NSLog(@"Warning: you are calling %s even though the cell is configured with fixed row height", (const char *)__PRETTY_FUNCTION__);
	}
	
	CGFloat contentWidth = tableView.frame.size.width;
	
	// reduce width for accessories
	switch (self.accessoryType)
	{
		case UITableViewCellAccessoryDisclosureIndicator:
		case UITableViewCellAccessoryCheckmark:
			contentWidth -= 20.0f;
			break;
		case UITableViewCellAccessoryDetailDisclosureButton:
			contentWidth -= 33.0f;
			break;
		case UITableViewCellAccessoryNone:
			break;
	}
	
	// reduce width for grouped table views
	if (tableView.style == UITableViewStyleGrouped)
	{
		// left and right 10 px margins on grouped table views
		contentWidth -= 20;
	}
	
    if ([self.comment.parent intValue])
    {
        CGFloat offset = ([self.comment.parent intValue]) ? childIndent : 0;
        
        offset = (self.comment.childLevel == 1) ? offset : offset * 2;
        
        contentWidth -= offset;
    }
    
    //Left and right indent
    contentWidth -= 20.0f;
    
	CGSize neededSize = [self.attributedTextContextView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
	
	// note: non-integer row heights caused trouble < iOS 5.0
    return 58.0f + neededSize.height + 10.0f;
}

- (void)setHTMLString:(NSString *)html
{
	// we don't preserve the html but compare it's hash
	NSUInteger newHash = [html hash];
	
	if (newHash == _htmlHash)
	{
		return;
	}
	
	_htmlHash = newHash;
	
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *options = @{NSTextSizeMultiplierDocumentOption : @1.3, DTDefaultFontFamily : @"Helvetica"}; 
    
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];

	self.attributedString = string;
    
    [self setNeedsLayout];
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
	
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25.0f, 25.0f); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
    
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (void)linkPushed:(DTLinkButton *)button
{
    [self.parentViewController showWebPage:button.URL];
}

- (IBAction)replyAction:(id)sender
{
    [self.parentViewController replyToComment:self.comment];
}
@end
