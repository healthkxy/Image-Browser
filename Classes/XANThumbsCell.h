//
//  XANThumbCell.h
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageSize (CGSizeMake(75.0, 75.0))
#define kSpacing 4.0
#define kCapacityOfImagesInARowPortrait 4
#define kCapacityOfImagesInARowLandscape 6

@protocol XANThumbsCellDelegate
- (void)didSelectPhotoAtIndex:(NSUInteger)index inRow:(NSUInteger)rowIndex;
@end

@interface XANThumbsCell : UITableViewCell {
  NSUInteger numberOfImages;
  NSUInteger capacityOfImages;
  NSUInteger rowIndex;
  __weak NSObject <XANThumbsCellDelegate> *thumbDelegate;
}

@property (nonatomic) NSUInteger numberOfImages;
@property (nonatomic) NSUInteger capacityOfImages;
@property (nonatomic) NSUInteger rowIndex;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier thumbDelegate:(NSObject <XANThumbsCellDelegate> *)thumbDelegate;
- (void)updateImage:(UIImage *)image forColumn:(NSUInteger)column;

@end
