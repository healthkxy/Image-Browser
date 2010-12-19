//
//  XANImageViewController.h
//  XANImageBrowser
//
//  Created by Chen Xian'an on 12/18/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XANImageViewController : UIViewController<UIScrollViewDelegate> {
  NSArray *imagePaths;
  NSUInteger currentImageIndex;
  UIImage *selectedImage;
  UIScrollView *pagingScrollView;

  NSMutableSet *visiblePages;
  NSMutableSet *recycledPages;

  UIInterfaceOrientation fromInterfaceOrientation;

  UIBarButtonItem *prevItem;
  UIBarButtonItem *nextItem;
}

- (id)initWithImagePaths:(NSArray *)imagePaths initialImageIndex:(NSUInteger)initialImageIndex;

@end
