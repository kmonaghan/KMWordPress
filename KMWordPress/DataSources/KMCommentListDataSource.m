//
//  KMCommentListDataSource.m
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMCommentListDataSource.h"

#import "KMWordPressPost.h"
#import "KMWordPressPostComment.h"

#import "KMCommentTableViewCell.h"

@interface KMCommentListDataSource()

@end

@implementation KMCommentListDataSource
- (id)initWithPost:(KMWordPressPost *)post
{
    self = [super init];
    
    if (self)
    {
        self.items = post.comments;
    }
    
    return self;
}

- (void)loadItems:(BOOL)more
{

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	KMCommentTableViewCell *cell = (KMCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"KMCommentTableViewCell"];
    
    [cell showComment:[self.items objectAtIndex:indexPath.row]];
    cell.parentViewController = self.parentViewController;
    
    return cell;
}
@end
