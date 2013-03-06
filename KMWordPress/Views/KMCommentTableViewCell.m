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

@property (nonatomic, strong) NSAttributedString *attributedString;
@property (strong, nonatomic) IBOutlet DTAttributedTextContentView *commentBody;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;

@property (strong, nonatomic) KMWordPressPostComment* comment;

@property (assign, nonatomic) CGFloat neededHeight;

- (IBAction)replyAction:(id)sender;

@end

@implementation KMCommentTableViewCell

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

- (void)awakeFromNib
{
    self.avatar.layer.borderColor = [UIColor grayColor].CGColor;
    self.avatar.layer.borderWidth = 1.0f;
    self.avatar.layer.cornerRadius = 4.0f;
    self.avatar.clipsToBounds = YES;
    
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
    self.commentBody.frame = CGRectMake(10.0f, 58.0f, 300.0f, 25.0f);
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
    
    self.commentBody.delegate = self;

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
    
	//CGFloat neededContentHeight = [self requiredRowHeightInTableView:(UITableView *)self.superview];
	CGSize neededSize = [self.commentBody suggestedFrameSizeToFitEntireStringConstraintedToWidth:allowedContentSize - offset];
	// after the first call here the content view size is correct
	CGRect frame = CGRectMake(10.0f + offset, 58.0f, allowedContentSize - offset, neededSize.height);
	
	if ((self.commentBody.frame.size.height != frame.size.height)
        || (self.commentBody.frame.size.width != frame.size.width))
	{
		self.commentBody.frame = frame;
	}
}

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
	CGFloat contentWidth = tableView.frame.size.width;

	// reduce width for accessories
	switch (self.accessoryType)
	{
		case UITableViewCellAccessoryDisclosureIndicator:
            //break;
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
		contentWidth -= 20.0f;
	}
	
    contentWidth -= 20.0f;
    
    if ([self.comment.parent intValue])
    {
        CGFloat offset = ([self.comment.parent intValue]) ? childIndent : 0;
        
        offset = (self.comment.childLevel == 1) ? offset : offset * 2;
        
        contentWidth -= offset;
    }
    
	CGSize neededSize = [self.commentBody suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth];
    
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
    
    NSDictionary *options = @{NSTextSizeMultiplierDocumentOption : @1.3, DTDefaultFontFamily : @"Helvetica"}; //[NSDictionary dictionaryWithObjectsAndKeys:@1.7, NSTextSizeMultiplierDocumentOption, nil];
    
	NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];

	self.attributedString = string;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (_attributedString != attributedString)
	{
		_attributedString = attributedString;
		
		// passthrough
		self.commentBody.attributedString = _attributedString;
	}
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
	
	// we draw the contents ourselves
	button.attributedString = string;
	
	// make a version with different text color
	NSMutableAttributedString *highlightedString = [string mutableCopy];
	
	NSRange range = NSMakeRange(0, highlightedString.length);
	
	NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:(__bridge id)[UIColor redColor].CGColor forKey:(id)kCTForegroundColorAttributeName];
	
	
	[highlightedString addAttributes:highlightedAttributes range:range];
	
	button.highlightedAttributedString = highlightedString;
	
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
