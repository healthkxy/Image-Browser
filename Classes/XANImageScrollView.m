//
//  XANImageScrollView.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/18/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import "XANImageScrollView.h"

@implementation XANImageScrollView
@synthesize imageView, image;
@synthesize index;

- (void)setImage:(UIImage *)theImage
{
  [theImage retain];
  [image release];
  image = theImage;

  if (image == nil){
    imageView.image = nil;
    return;
  }

  self.zoomScale = 1.0;

  CGSize imageSize = image.size;
  CGSize finalSize = self.bounds.size;
  if (imageSize.width > imageSize.height){
    finalSize.height = imageSize.height * (finalSize.width/imageSize.width);
    if (finalSize.height > self.frame.size.height){
      finalSize.width *= (self.frame.size.height/finalSize.height);
      finalSize.height = self.frame.size.height;
    }
  } else {
    finalSize.width = imageSize.width * (finalSize.height/imageSize.height);
    if (finalSize.width > self.frame.size.width){
      finalSize.height *= (self.frame.size.width/finalSize.width);
      finalSize.width = self.frame.size.width;
    }
  }
  
  imageView.image = image;
  imageView.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
  
  CGFloat maximumZoomScale = imageSize.height / finalSize.height;
  CGFloat minimumZoomScale = 1.0;
  if (maximumZoomScale < 1.5) maximumZoomScale = 1.5;
  if (imageSize.height < self.bounds.size.height && imageSize.width < self.bounds.size.width) minimumZoomScale = finalSize.width / imageSize.width;
  
  self.maximumZoomScale = maximumZoomScale;
  self.minimumZoomScale = minimumZoomScale;

  [self setNeedsLayout];
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]){
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.autoresizesSubviews = NO;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:imageView];
    [imageView release];
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
  }                                             
  
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGSize boundsSize = self.bounds.size;
  CGRect frameToCenter = imageView.frame;
  
  if (frameToCenter.size.width < boundsSize.width)
    frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
  else
    frameToCenter.origin.x = 0;
  
  if (frameToCenter.size.height < boundsSize.height)
    frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
  else 
    frameToCenter.origin.y = 0;

  imageView.frame = frameToCenter;
}

- (void)dealloc
{
  [super dealloc];
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return imageView;
}

@end
