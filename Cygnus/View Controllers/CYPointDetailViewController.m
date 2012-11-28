//
//  CYPointDetailViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYPointDetailViewController.h"
#import "CYUser+Additions.h"
#import "DLCImagePickerController.h"
#import <SSToolkit/SSCollectionView.h>
#import "CYUI.h"

@interface CYPointDetailViewController () <SSCollectionViewDataSource, SSCollectionViewDelegate,DLCImagePickerDelegate>

@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (strong, nonatomic)       SSCollectionView *collectionView;
@property (strong, nonatomic)       UIGestureRecognizer *photoAddGestureRecognizer;
@property (nonatomic)               BOOL photoUploading;
@property (strong, nonatomic)       UIActivityIndicatorView *uploadActivityIndicator;
@property (strong, nonatomic)       NSArray *images;
@property (weak, nonatomic) IBOutlet UILabel *emptyImageLabel;

@end

@implementation CYPointDetailViewController


#pragma mark - SSCollectionViewDataSource

- (NSUInteger)numberOfSectionsInCollectionView:(SSCollectionView *)aCollectionView {
	return 1;
}

- (NSUInteger)collectionView:(SSCollectionView *)aCollectionView numberOfItemsInSection:(NSUInteger)section {
	NSUInteger count = [self.images count];
  return count + 1;
}

- (SSCollectionViewItem *)collectionView:(SSCollectionView *)aCollectionView itemForIndexPath:(NSIndexPath *)indexPath {
	static NSString *const itemIdentifier = @"itemIdentifier";
	SSCollectionViewItem *item = [aCollectionView dequeueReusableItemWithIdentifier:itemIdentifier];
	if (!item) {
    item = [[SSCollectionViewItem alloc] initWithStyle:SSCollectionViewItemStyleBlank reuseIdentifier:itemIdentifier];
    item.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 92, 92)];
    [item addSubview:item.imageView];
   }
  item.clipsToBounds = NO;
  item.backgroundColor = [UIColor whiteColor];
  item.layer.shadowColor = [UIColor grayColor].CGColor;
  item.layer.shadowOffset = CGSizeMake(0.5, 1.5);
  item.layer.shadowOpacity = 1.0f;
  item.layer.shadowRadius = 1.0f;
  item.layer.shadowPath = [CYUI bezierPathWithCurvedShadowForRect:item.bounds withCurve:3.0f].CGPath;
  [item.layer setMasksToBounds:NO];
  [item.imageView cancelImageRequestOperation];
  item.imageView.image = nil;
  
	NSInteger i = ([self numberOfSectionsInCollectionView:self.collectionView] * indexPath.section) + indexPath.row;
  if (i == 0) {
    if (self.photoUploading) {
      [self.uploadActivityIndicator startAnimating];
      [item.imageView addSubview:self.uploadActivityIndicator];
      [self.uploadActivityIndicator alignHorizontally:UIViewHorizontalAlignmentCenter vertically:UIViewVerticalAlignmentMiddle];
      return item;
    } else {
      item.backgroundView.hidden = YES;
      item.imageView.image = [UIImage imageNamed:@"tap_to_add_photo.png"];
      return item;
    }
  }
  item.imageView.image = [self.images objectAtIndex:i - 1];
	return item;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForHeaderInSection:(NSUInteger)section {
	UIView *test = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,15)];
  return test;
}

- (UIView *)collectionView:(SSCollectionView *)aCollectionView viewForFooterInSection:(NSUInteger)section {
	UIView *test = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,15)];
  return test;
}

- (CGSize)collectionView:(SSCollectionView *)aCollectionView itemSizeForSection:(NSUInteger)section {
	return CGSizeMake(98.0f, 98.0f);
}

- (void)collectionView:(SSCollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self addImage];
  }
//  } else {
//    FGalleryViewController *galleryVC = [[FGalleryViewController alloc] initWithPhotoSource:self];
//    galleryVC.startingIndex = indexPath.row - 1;
//    galleryVC.useThumbnailView = NO;
//    galleryVC.beginsInThumbnailView = NO;
//    galleryVC.hideTitle = YES;
//    [galleryVC.toolBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
//    galleryVC.toolBar.translucent = YES;
//    galleryVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentModalViewController:galleryVC animated:YES];
//  }
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForHeaderInSection:(NSUInteger)section {
  return 15;
}

- (CGFloat)collectionView:(SSCollectionView *)aCollectionView heightForFooterInSection:(NSUInteger)section
{
  return 15;
}

#pragma mark - UIImagePickerControllerDelegate


- (void)addImage
{
  //    [self performSegueWithIdentifier:@"HPImagePickerController_Segue" sender:nil];
  DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
  picker.delegate = self;
  picker.outputJPEGQuality = 0.5;
  [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - HPImagePickerDelegate

-(void) imagePickerControllerDidCancel:(DLCImagePickerController *)picker{
  [self dismissViewControllerAnimated:YES completion:NULL];
  picker = nil;
}

-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [CYAnalytics logEvent:CYAnalyticsEventCameraVisited withParameters:nil];
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
  [self dismissModalViewControllerAnimated:YES];
  picker = nil;
  
  if (info) {
    self.photoUploading = YES;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    UIImage *image = [UIImage imageWithData:[info objectForKey:@"data"]];
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:[info objectForKey:@"data"]];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (!error) {
        PFObject *pfPoint = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.point.unique];
        PFObject *pointImage = [PFObject objectWithClassName:@"Image"];
        [pointImage setObject:imageFile forKey:@"imageFile"];
        [pointImage setObject:pfPoint forKey:@"parent"];
        
        [pointImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
          if (!error) {
            [self.uploadActivityIndicator stopAnimating];
            self.photoUploading = NO;
            self.images = [@[image] arrayByAddingObjectsFromArray:self.images];
            [self.collectionView reloadData];
              [UIView transitionWithView:self.pointImageView
                                duration:0.22
                                 options:UIViewAnimationOptionTransitionCrossDissolve
                              animations:^{
                                [self.pointImageView setImage:image];
                              } completion:NULL];
            [CYAnalytics logEvent:CYAnalyticsEventPhotoUploaded withParameters:nil];

          }
          else{
            [self reportUploadFailure];
          }
        }];
      }
      else{
        [self reportUploadFailure];
      }
    } progressBlock:NULL];
  }
}

- (void)reportUploadFailure
{
  [self.uploadActivityIndicator stopAnimating];
  self.photoUploading = NO;
  [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
  UIAlertView *alertView = [[UIAlertView alloc]
                            initWithTitle:@"Network Error"
                            message:@"Try that again later."
                            delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
  [alertView show];
}

#pragma mark - Accessors

#define PHOTO_PADDING 6.0f

- (SSCollectionView *)collectionView
{
  if (!_collectionView) {
    _collectionView = [[SSCollectionView alloc] initWithFrame:CGRectMake(-1, self.pointImageView.height - 6, 322, self.view.height - self.pointImageView.height - 51)];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.extremitiesStyle = SSCollectionViewExtremitiesStyleScrolling;
    _collectionView.rowSpacing = PHOTO_PADDING;
    _collectionView.minimumColumnSpacing = PHOTO_PADDING;
    _collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageFromDiskNamed:@"gray_bg.png"]];

  }
  return _collectionView;
}

#pragma mark - VC Life cycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  int height = self.navigationController.navigationBar.frame.size.height;
  int width = self.navigationController.navigationBar.frame.size.width;
  UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  navLabel.text = _point.name;
  navLabel.backgroundColor = [UIColor clearColor];
  navLabel.textColor = [UIColor whiteColor];
  navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  navLabel.font = [UIFont fontWithName:@"Code Light" size:22];
  navLabel.textAlignment = UITextAlignmentCenter;
  self.navigationItem.titleView = navLabel;
  [navLabel sizeToFit];
  [navLabel alignHorizontally:UIViewHorizontalAlignmentCenter];
  
  self.images = [[NSMutableArray alloc] init];
  self.imageContainer.layer.cornerRadius = 3.0f;
  [self.view insertSubview:self.collectionView belowSubview:self.imageContainer];
  if ([self.point.imageURLString description]) {
    [self.emptyImageLabel hide];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    [self.pointImageView addSubview:activityIndicator];
    [activityIndicator alignHorizontally:UIViewHorizontalAlignmentCenter vertically:UIViewVerticalAlignmentMiddle];
    [self.pointImageView cancelImageRequestOperation];
    [self.pointImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.point.imageURLString]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
      [activityIndicator hide];
      [UIView transitionWithView:self.pointImageView
                        duration:0.22
                         options:UIViewAnimationOptionTransitionCrossDissolve
                      animations:^{
                        [self.pointImageView setImage:image];
                      } completion:NULL];
    } failure:NULL];
  } else {
    [self.emptyImageLabel setFont:[UIFont fontWithName:@"CODE Bold" size:17]];
    [self.emptyImageLabel sizeToFit];
    [self.emptyImageLabel alignHorizontally:UIViewHorizontalAlignmentCenter];
    self.emptyImageLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.emptyImageLabel.layer.shadowOffset = CGSizeMake(1.0, 1.5);
    self.emptyImageLabel.layer.shadowOpacity = 0.8f;
    self.emptyImageLabel.layer.shadowRadius = 1.0f;
  }

  self.pointImageView.layer.cornerRadius = 3.0f;
  self.pointImageView.height += 6;
  self.pointImageView.yOrigin -= 3;

  self.photoUploading = NO;
  self.uploadActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.uploadActivityIndicator.hidesWhenStopped = YES;
  
  //get photos from parse -> [self.collectionVew reloadData];
  PFQuery *query = [PFQuery queryWithClassName:@"Image"];
  PFObject *pfPoint = [PFObject objectWithoutDataWithClassName:PointClassName objectId:self.point.unique];
  [query whereKey:@"parent" equalTo:pfPoint];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (objects.count > 0) {
      NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:objects.count];
      for (PFObject *eachObject in objects) {
        PFFile *theImage = [eachObject objectForKey:@"imageFile"];
        NSData *imageData = [theImage getData];
        UIImage *image = [UIImage imageWithData:imageData];
        [images addObject:image];
      }
      self.images = images;
      [self.collectionView reloadData];
      [self.emptyImageLabel hide];
      [UIView transitionWithView:self.pointImageView
                        duration:0.22
                         options:UIViewAnimationOptionTransitionCrossDissolve
                      animations:^{
                        [self.pointImageView setImage:[self.images lastObject]];
                      } completion:NULL];
    }
  }];

  self.distanceLabel.layer.cornerRadius = 4.f;
  self.distanceLabel.layer.borderColor = [UIColor blackColor].CGColor;
  self.distanceLabel.layer.borderWidth = 1.f;

  self.summaryTextView.layer.cornerRadius = 4.f;
  self.summaryTextView.layer.borderColor = [UIColor blackColor].CGColor;
  self.summaryTextView.layer.borderWidth = 1.f;
}


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [CYAnalytics logEvent:CYAnalyticsEventPointDetailVisited withParameters:nil];
  for (SSCollectionViewItem *item in self.collectionView.visibleItems) {
      [UIView transitionWithView:item
                      duration:0.22
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                    animations:^{
                      item.clipsToBounds = NO;
                      item.backgroundColor = [UIColor whiteColor];
                      item.layer.shadowColor = [UIColor grayColor].CGColor;
                      item.layer.shadowOffset = CGSizeMake(0.5, 1.5);
                      item.layer.shadowOpacity = 1.0f;
                      item.layer.shadowRadius = 1.0f;
                      item.layer.shadowPath = [CYUI bezierPathWithCurvedShadowForRect:item.bounds withCurve:3.0f].CGPath;
                      [item.layer setMasksToBounds:NO];
                    } completion:NULL];
  }
  [self.mapView zoomToFitAnnotationsWithUser:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:self.point.coordinate.latitude longitude:self.point.coordinate.longitude];
  self.distanceLabel.text = [NSString stringWithFormat:@"%.0f m from you", [self.mapView.userLocation.location distanceFromLocation:pointLocation]];

  self.summaryTextView.text = self.point.summary;
}

@end
