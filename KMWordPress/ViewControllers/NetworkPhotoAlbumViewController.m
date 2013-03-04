//
// Copyright 2011 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NetworkPhotoAlbumViewController.h"

#import "AFNetworking.h"

#import "KMPostViewController.h"

#import "KMWordPressPost.h"
#import "KMWordPressPostAttachment.h"
#import "KMWordPressPostAttachmentImages.h"
#import "KMWordPressImage.h"

#import "KMWordPressPostControl.h"

@interface NetworkPhotoAlbumViewController()
@property (nonatomic, strong) KMWordPressPost *post;

@property (strong, nonatomic) KMWordPressPostControl *buttonControl;
@property (assign, nonatomic) NSInteger startIndex;

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NetworkPhotoAlbumViewController

- (id)initWithPost:(KMWordPressPost *)post
{
    self = [self initWithNibName:nil bundle:nil];
    
    if (self)
    {
        self.post = post;
        
        self.buttonControl = [KMWordPressPostControl new];
        self.buttonControl.post = post;
        self.startIndex = 0;
    }
    
    return self;
}

- (id)initWithPost:(KMWordPressPost *)post startAtIndex:(NSInteger)index
{
    self = [self initWithPost:post];
    
    if (self)
    {
        self.startIndex = index;
    }
    
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown_NetworkPhotoAlbumViewController {
    [_queue cancelAllOperations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [self shutdown_NetworkPhotoAlbumViewController];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
    return [NSString stringWithFormat:@"%d", photoIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)identifierWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                          photoIndex:(NSInteger)photoIndex {
    BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
    NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
    return identifier;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)identifierKeyFromIdentifier:(NSInteger)identifier {
    return [NSNumber numberWithInt:identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestImageFromSource:(NSString *)source
                     photoSize:(NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex:(NSInteger)photoIndex {
    BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
    NSInteger identifier = [self identifierWithPhotoSize:photoSize photoIndex:photoIndex];
    id identifierKey = [self identifierKeyFromIdentifier:identifier];
    
    // Avoid duplicating requests.
    if ([_activeRequests containsObject:identifierKey]) {
        return;
    }
    
    NSURL* url = [NSURL URLWithString:source];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 30;
    
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
    
    AFImageRequestOperation* readOp =
    [AFImageRequestOperation imageRequestOperationWithRequest:request
                                         imageProcessingBlock:nil success:
     ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         // Store the image in the correct image cache.
         if (isThumbnail) {
             [_thumbnailImageCache storeObject: image
                                      withName: photoIndexKey];
             
         } else {
             [_highQualityImageCache storeObject: image
                                        withName: photoIndexKey];
         }
         
         // If you decide to move this code around then ensure that this method is called from
         // the main thread. Calling it from any other thread will have undefined results.
         [self.photoAlbumView didLoadPhoto: image
                                   atIndex: photoIndex
                                 photoSize: photoSize];
         
         if (isThumbnail) {
             [self.photoScrubberView didLoadThumbnail:image atIndex:photoIndex];
         }
         
         [_activeRequests removeObject:identifierKey];
         
     } failure:
     ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
    
    readOp.imageScale = 1;
    
    // Set the operation priority level.
    
    if (NIPhotoScrollViewPhotoSizeThumbnail == photoSize) {
        // Thumbnail images should be lower priority than full-size images.
        [readOp setQueuePriority:NSOperationQueuePriorityLow];
        
    } else {
        [readOp setQueuePriority:NSOperationQueuePriorityNormal];
    }
    
    // Start the operation.
    [_activeRequests addObject:identifierKey];
    [_queue addOperation:readOp];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadThumbnails {
    for (NSInteger ix = 0; ix < [self.post.attachments count]; ++ix) {
        
        NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];
        
        // Don't load the thumbnail if it's already in memory.
        if (![self.thumbnailImageCache containsObjectWithName:photoIndexKey]) {
            KMWordPressPostAttachment* photo = [self.post.attachments objectAtIndex:ix];
            
            [self requestImageFromSource: photo.images.thumbnail.url
                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                              photoIndex: ix];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    self.scrubberIsEnabled = YES;
    
    _activeRequests = [[NSMutableSet alloc] init];
    
    _highQualityImageCache = [[NIImageMemoryCache alloc] init];
    _thumbnailImageCache = [[NIImageMemoryCache alloc] init];
    
    [_highQualityImageCache setMaxNumberOfPixels:1024L*1024L*10L];
    [_thumbnailImageCache setMaxNumberOfPixelsUnderStress:1024L*1024L*3L];
    
    _queue = [[NSOperationQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:5];
    
    // Set the default loading image.
    self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                        NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];
    
    
    self.photoAlbumView.dataSource = self;
    self.photoScrubberView.dataSource = self;

    self.photoAlbumView.zoomingAboveOriginalSizeIsEnabled = YES;
    
    
    // This title will be displayed until we get the results back for the album information.
    self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");
    
    [self loadThumbnails];
    [self.photoAlbumView reloadData];
    [self.photoScrubberView reloadData];
    
    [self refreshChromeState];
    
    [self.photoAlbumView setCenterPageIndex:self.startIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.buttonControl.delegate = self;
    [self.buttonControl attachButtonsToView];
    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 13, button.frame.size.height);
    
    [button addTarget:self action:@selector(fullPost) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = infoItem;
     */
    
    [[[GAI sharedInstance] defaultTracker] sendView:@"Photo Gallery"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([KMWordPress sharedInstance].fullScreen)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault
                                                animated: animated];
    
    UINavigationBar* navBar = self.navigationController.navigationBar;
    navBar.barStyle = UIBarStyleDefault;
    navBar.translucent = NO;
    
    if ([KMWordPress sharedInstance].fullScreen)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [self shutdown_NetworkPhotoAlbumViewController];
    
    [super viewDidUnload];
}

- (void)fullPost
{
    KMPostViewController *detailViewController = [[KMPostViewController alloc] initWithPost:self.post];
    [self.navigationController pushViewController:detailViewController animated:YES];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoScrubberViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView {
    return [self.post.attachments count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex {
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
    
    UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
    
    if (nil == image) {
        KMWordPressPostAttachment* photo = [self.post.attachments objectAtIndex:thumbnailIndex];
        
        [self requestImageFromSource: photo.images.thumbnail.url
                           photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                          photoIndex: thumbnailIndex];
    }
    
    return image;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInPagingScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
    return [self.post.attachments count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions {
    UIImage* image = nil;
    
    KMWordPressPostAttachment* photo = [self.post.attachments objectAtIndex:photoIndex];
    
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
        
    // Let the photo album view know how large the photo will be once it's fully loaded.
    *originalPhotoDimensions =  CGSizeMake(photo.images.full.width, photo.images.full.height);
    
    image = [self.highQualityImageCache objectWithName:photoIndexKey];
    if (nil != image) {
        *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
        
    } else {
        [self requestImageFromSource: photo.images.full.url
                           photoSize: NIPhotoScrollViewPhotoSizeOriginal
                          photoIndex: photoIndex];
        
        *isLoading = YES;
        
        // Try to return the thumbnail image if we can.
        image = [self.thumbnailImageCache objectWithName:photoIndexKey];
        if (nil != image) {
            *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;
            
        } else {
            // Load the thumbnail as well.
            [self requestImageFromSource: photo.images.thumbnail.url
                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                              photoIndex: photoIndex];
            
        }
    }
    
    return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
     stopLoadingPhotoAtIndex: (NSInteger)photoIndex {
    // TODO: Figure out how to implement this with AFNetworking.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
    return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}
@end