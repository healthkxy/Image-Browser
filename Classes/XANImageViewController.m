//
//  XANImageViewController.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/18/PAGE_GAP/2.
//  Copyright 20PAGE_GAP/2 lazyapps.com. All rights reserved.
//

#import "XANImageViewController.h"
#import "XANImageScrollView.h"

#define PAGE_GAP 20.0

@interface XANImageViewController()
- (void)updatePagingScrollViewLayout;
- (void)updatePagingScrollViewBounds;
- (void)updatePage:(XANImageScrollView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)tilePages;
- (XANImageScrollView *)dequeueRecycledPage;
- (CGRect)pageBounds;
@end

@implementation XANImageViewController

- (id)initWithImagePaths:(NSArray *)theImagePaths 
       initialImageIndex:(NSUInteger)theInitialImageIndex
{
  if (self = [super initWithNibName:nil bundle:nil]){
    imagePaths = [theImagePaths retain];
    currentImageIndex = theInitialImageIndex;
    self.wantsFullScreenLayout = YES;
    
    visiblePages = [[NSMutableSet alloc] initWithCapacity:0];
    recycledPages = [[NSMutableSet alloc] initWithCapacity:0];
  }
  
  return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  pagingScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  pagingScrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
  pagingScrollView.contentInset = UIEdgeInsetsZero;
  pagingScrollView.alwaysBounceVertical = NO;
  pagingScrollView.autoresizesSubviews = YES;
  pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  pagingScrollView.pagingEnabled = YES;
  pagingScrollView.delegate = self;
  pagingScrollView.showsHorizontalScrollIndicator = NO;
  pagingScrollView.showsVerticalScrollIndicator = NO;
  pagingScrollView.backgroundColor = [UIColor blackColor];
  [self updatePagingScrollViewLayout];
  [self tilePages];

  UIView *view = [[UIView alloc] initWithFrame:[self pageBounds]];
  [view addSubview:pagingScrollView];
  [pagingScrollView release];
  self.view = view;
  [view release];

  prevItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left"] style:UIBarButtonItemStylePlain target:self action:@selector(prevImage:)];
  nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_right"] style:UIBarButtonItemStylePlain target:self action:@selector(nextImage:)];
  prevItem.enabled = currentImageIndex > 0;
  nextItem.enabled = currentImageIndex < [imagePaths count] - 1;
  UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  NSArray *items = [[NSArray alloc] initWithObjects:flexibleItem, prevItem, flexibleItem, nextItem, flexibleItem, nil];
  [prevItem release];
  [nextItem release];
  [flexibleItem release];

  self.toolbarItems = items;
  [items release];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.toolbarHidden = NO;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
  fromInterfaceOrientation = self.interfaceOrientation;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
  if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) == UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) return;
      
  [self updatePagingScrollViewLayout];
  [self tilePages];
  for (XANImageScrollView *page in visiblePages){
    [self updatePage:page forIndex:page.index];
  }
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
  [imagePaths release];
  [visiblePages release];
  [recycledPages release];

  [super dealloc];
}

#pragma mark - 
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  [self tilePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  CGRect visibleBounds = pagingScrollView.bounds;
  currentImageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
  currentImageIndex = MAX(currentImageIndex, 0);
}

#pragma mark privates
- (void)updatePagingScrollViewLayout
{
  CGRect frame = [self pageBounds];
  frame.origin.x -= PAGE_GAP/2;
  frame.size.width += PAGE_GAP;
  pagingScrollView.frame = frame;
  pagingScrollView.contentSize = CGSizeMake(frame.size.width * [imagePaths count], frame.size.height);
  [self updatePagingScrollViewBounds];
}

- (void)updatePagingScrollViewBounds
{
  CGRect bounds = pagingScrollView.bounds;
  bounds.origin.x = pagingScrollView.frame.size.width * currentImageIndex;
  pagingScrollView.bounds = bounds;
}

- (void)updatePage:(XANImageScrollView *)page
          forIndex:(NSUInteger)index
{
  page.index = index;
  CGRect frame = [self pageBounds];
  frame.origin.x = (frame.size.width + PAGE_GAP) * page.index + PAGE_GAP/2;
  page.frame = frame;
  UIImage *image = [[UIImage alloc] initWithContentsOfFile:[imagePaths objectAtIndex:index]];
  page.image = image;
  [image release];
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
  for (XANImageScrollView *page in visiblePages){
    if (page.index == index)
      return YES;
  }
  
  return NO;
}

- (void)tilePages
{
  CGRect visibleBounds = pagingScrollView.bounds;
  NSUInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
  NSUInteger lastNeededPageIndex = floorf(CGRectGetMaxX(visibleBounds) / CGRectGetWidth(visibleBounds));
  firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
  lastNeededPageIndex = MIN(lastNeededPageIndex, [imagePaths count]-1);

  for (XANImageScrollView *page in visiblePages){
    if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex){
      [recycledPages addObject:page];
      [page removeFromSuperview];
      page.image = nil;
    }
  }

  [visiblePages minusSet:recycledPages];

  for (NSUInteger index=firstNeededPageIndex; index<=lastNeededPageIndex; index++){
    if (![self isDisplayingPageForIndex:index]){
      XANImageScrollView *page = [self dequeueRecycledPage];
      if (page == nil){
        page = [[[XANImageScrollView alloc] initWithFrame:CGRectZero] autorelease];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [page addGestureRecognizer:singleTap];
        [page addGestureRecognizer:doubleTap];
        [singleTap release];
        [doubleTap release];
      }
      [visiblePages addObject:page];
      [pagingScrollView addSubview:page];
      [self updatePage:page forIndex:index];
    }
  }
}

- (XANImageScrollView *)dequeueRecycledPage
{
  XANImageScrollView *page = [recycledPages anyObject];
  if (page){
    [[page retain] autorelease];
    [recycledPages removeObject:page];
  }

  return page;
}

- (CGRect)pageBounds
{
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }

  return bounds;
}

#pragma mark UITapGestureRecognizer actions
- (void)handleSingleTap:(UITapGestureRecognizer *)tgr
{
  BOOL hidden = [UIApplication sharedApplication].statusBarHidden;
  [[UIApplication sharedApplication] setStatusBarHidden:!hidden withAnimation:UIStatusBarAnimationFade];
  [self.navigationController setNavigationBarHidden:!hidden animated:YES];
  [self.navigationController setToolbarHidden:!hidden animated:YES];  
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tgr
{
  XANImageScrollView *page = (XANImageScrollView *)tgr.view;
  float scale = page.zoomScale > page.minimumZoomScale ? page.minimumZoomScale : page.maximumZoomScale;
  CGPoint center = [tgr locationInView:page];
  CGRect zoomRect;
  zoomRect.size.height = [page bounds].size.height / scale;
  zoomRect.size.width = [page bounds].size.width  / scale;  
  zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
  zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);

  [page zoomToRect:zoomRect animated:YES];
}

#pragma mark UIBarButtonItem actions
- (void)prevImage:(UIBarButtonItem *)sender
{
  currentImageIndex--;
  if (currentImageIndex == 0) prevItem.enabled = NO;
  if ([imagePaths count] > 1) nextItem.enabled = YES;

  [self updatePagingScrollViewBounds];
  [self tilePages];
}

- (void)nextImage:(UIBarButtonItem *)sender
{
  currentImageIndex++;
  if (currentImageIndex == [imagePaths count] - 1) nextItem.enabled = NO;
  if ([imagePaths count] > 1) prevItem.enabled = YES;

  [self updatePagingScrollViewBounds];
  [self tilePages];
}

@end
