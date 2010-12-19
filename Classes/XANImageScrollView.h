//
//  XANImageScrollView.h
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/18/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XANImageScrollView : UIScrollView <UIScrollViewDelegate> {
  UIImageView *imageView;
  UIImage *image;
  NSUInteger index;
}

@property (nonatomic, retain, readonly) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic) NSUInteger index;

@end
