//
//  XANThumbsViewController.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import "XANThumbsViewController.h"
#import "XANImageViewController.h"

#define ROW_HEIGHT (kImageSize.height + kSpacing)

@interface XANThumbsViewController()
- (void)updateTableLayout;
- (NSUInteger)numberOfRows;
- (NSUInteger)capacityOfImagesInARow;
- (NSUInteger)numberOfimagePathsForRow:(NSUInteger)row;
- (void)updateImagesForCell:(XANThumbsCell *)cell;
@end

@implementation XANThumbsViewController
@synthesize imagePaths;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithimagePaths:(NSArray *)theimagePaths
{
  if (self = [super initWithStyle:UITableViewStylePlain]){
    imagePaths = [theimagePaths retain];
    thumbImages = [[NSMutableArray alloc] initWithCapacity:[imagePaths count]];
    for (NSInteger i=0; i<[imagePaths count]; i++){
      [thumbImages addObject:[NSNull null]];
    }
    
    self.wantsFullScreenLayout = YES;
  }

  return self;
}

- (void)loadView
{
  [super loadView];

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self updateTableLayout];
  self.tableView.rowHeight = ROW_HEIGHT;

  self.navigationItem.title = @"XANImageBrowser";
  self.navigationController.navigationBar.barStyle
    = self.navigationController.toolbar.barStyle
    = UIBarStyleBlack;
  self.navigationController.navigationBar.translucent
    = self.navigationController.toolbar.translucent
    = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:YES];
  [self.tableView reloadData];
  [self updateTableLayout];
  self.navigationController.toolbarHidden = YES;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
  [self updateTableLayout];
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [self numberOfRows];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  XANThumbsCell *cell = (XANThumbsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[XANThumbsCell alloc] initWithReuseIdentifier:CellIdentifier thumbDelegate:self] autorelease];
  }
  
  cell.capacityOfImages = [self capacityOfImagesInARow];
  cell.numberOfImages = [self numberOfimagePathsForRow:indexPath.row];
  cell.rowIndex = indexPath.row;
  [self updateImagesForCell:cell];
  
  return cell;
}

#pragma mark Table view delegate

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
    
  // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
  [imagePaths release];
  [super dealloc];
}

#pragma mark privates

- (CGFloat)rowHeight
{
  return kImageSize.height + kSpacing;
}

- (void)updateTableLayout
{
  CGFloat barsHeight = 0;
  if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent && self.wantsFullScreenLayout) barsHeight += 20;
  if (self.navigationController.navigationBar.translucent) barsHeight += self.navigationController.navigationBar.bounds.size.height;
  self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
  barsHeight += kSpacing;
  self.tableView.contentInset = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
}

- (NSUInteger)numberOfRows
{
  return [imagePaths count] / [self capacityOfImagesInARow] + 1;
}

- (NSUInteger)capacityOfImagesInARow
{
  return UIInterfaceOrientationIsPortrait(self.interfaceOrientation) 
    ? kCapacityOfImagesInARowPortrait
    : kCapacityOfImagesInARowLandscape;
}

- (NSUInteger)numberOfimagePathsForRow:(NSUInteger)row
{  
  if (row == [self numberOfRows]-1)
    return [imagePaths count] % [self capacityOfImagesInARow];
  
  return [self capacityOfImagesInARow];
}

- (void)updateImagesForCell:(XANThumbsCell *)cell
{
  for (NSUInteger column=0; column<cell.numberOfImages; column++){
    NSUInteger realIndex = [self capacityOfImagesInARow]*cell.rowIndex + column;
    NSObject *thumb = [thumbImages objectAtIndex:realIndex];
  
    if ([thumb isEqual:[NSNull null]]){
      dispatch_queue_t queue = dispatch_queue_create("name.xianan.chen.imagebrowser", NULL);
      dispatch_async(queue, ^{
          UIImage *image = [[UIImage alloc] initWithContentsOfFile:[imagePaths objectAtIndex:realIndex]];
          CGSize size = kImageSize;
    
          if (image.size.width > image.size.height)
            size.width = size.height * (image.size.width/image.size.height);
          else 
            size.height = size.width * (image.size.height/image.size.width);
    
          CGRect rect = CGRectZero;
          rect.origin = CGPointZero;
          rect.size = size;
          UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
          [image drawInRect:rect];
          UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();
          [thumbImages replaceObjectAtIndex:realIndex withObject:thumbImage];
    
          dispatch_async(dispatch_get_main_queue(), ^{
              [cell updateImage:thumbImage forColumn:column];
            });

          [image release];
        });
    } else {
      [cell updateImage:(UIImage *)thumb forColumn:column];
    }
  }
}

#pragma mark XANThumbsCellDelegate
- (void)didSelectPhotoAtIndex:(NSUInteger)index
                        inRow:(NSUInteger)rowIndex
{
  NSUInteger realIndex = [self capacityOfImagesInARow]*rowIndex + index;
  XANImageViewController *ivc = [[XANImageViewController alloc] initWithImagePaths:imagePaths initialImageIndex:realIndex];
  [self.navigationController pushViewController:ivc animated:YES];
  [ivc release];
}

@end

