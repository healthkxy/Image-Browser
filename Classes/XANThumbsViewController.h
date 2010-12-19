//
//  XANThumbsViewController.h
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XANThumbsCell.h"

@interface XANThumbsViewController : UITableViewController <XANThumbsCellDelegate>{
  NSArray *imagePaths;
@private
  NSMutableArray *thumbImages;
}

@property (nonatomic, retain) NSArray *imagePaths;

- (id)initWithimagePaths:(NSArray *)imagePaths;

@end
