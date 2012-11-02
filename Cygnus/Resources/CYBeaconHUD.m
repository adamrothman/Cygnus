//
//  CYBeaconHUD.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/2/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYBeaconHUD.h"
#import "CYUI.h"
#import "CYUser.h"

@implementation CYBeaconHUD

# pragma mark - Actions, Gestures, Notification Handlers

- (void)activitySwitchSet
{
  [CYUser currentUser].status = (self.activitySwitch.isOn) ? CYBeaconStatusActive : CYBeaconStatusManual;
  if (self.activitySwitch.isOn) {
    self.activityLabel.text = @"Active";
  } else {
    self.activityLabel.text = @"Manual";
    // Notify delegate (ie CYMap in mapviewController)
  }
  
}

- (void)rangeSegmentedControlSet
{
  [CYUser currentUser].range = [self getRangeForIndex:self.rangeSegmentedControl.selectedSegmentIndex];
  self.rangeValueLabel.text = [NSString stringWithFormat:@"%d km", [CYUser currentUser].range];
}


- (void)rangeLabelTapped
{
  if (self.yOrigin == self.superview.height - 55) { //partial mode
    [self showFull];
  } else {
    [self showPartial];
  }
}


# pragma mark - Display

- (void)showPartial
{
  [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.yOrigin = self.superview.height - 55;
  } completion:NULL];
}

- (void)showFull
{
  [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.yOrigin = self.superview.height - self.height;
  } completion:NULL];
}

- (void)hide
{
  [UIView animateWithDuration:0.22 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.yOrigin = self.superview.height;
  } completion:NULL];
}


#pragma mark - Initializatoin

- (void)setUp
{
  self.backgroundColor = [UIColor clearColor];
  self.containerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.64];
  self.yOrigin = [UIScreen mainScreen].bounds.size.height;
  [self.activitySwitch setOn:[CYUser currentUser].status];
  self.activityLabel.text = (self.activitySwitch.isOn) ? @"Active" : @"Manual";
  self.rangeValueLabel.text = [NSString stringWithFormat:@"%d km", [CYUser currentUser].range];
  self.rangeSegmentedControl.selectedSegmentIndex = [self getIndexForRange:[CYUser currentUser].range];
  
  [self.activitySwitch setTarget:self action:@selector(activitySwitchSet) forControlEvents:UIControlEventValueChanged];
  [self.rangeSegmentedControl addTarget:self
                       action:@selector(rangeSegmentedControlSet)
             forControlEvents:UIControlEventValueChanged];
  
  UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rangeLabelTapped)];
  [self.rangeLabel addGestureRecognizer:tgr];
  self.rangeLabel.userInteractionEnabled = YES;
}

- (NSInteger)getIndexForRange:(CYBeaconRange)range
{
  switch (range) {
    case CYBeaconRangeOff:
      return 0;
      break;
    case CYBeaconRangeLocal:
      return 1;
      break;
    case CYBeaconRangeCity:
      return 2;
      break;
    case CYBeaconRangeMetro:
      return 3;
      break;
    default:
      return 0;
  }
}


- (CYBeaconRange)getRangeForIndex:(NSInteger)index
{
  switch (index) {
    case 0:
      return CYBeaconRangeOff;
      break;
    case 1:
      return CYBeaconRangeLocal;
      break;
    case 2:
      return CYBeaconRangeCity;
      break;
    case 3:
      return CYBeaconRangeMetro;
      break;
    default:
      return CYBeaconRangeLocal;
      break;
  }
}

- (id)init
{
  return [self initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, 110)];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    [[NSBundle mainBundle] loadNibNamed:@"CYBeaconHUD" owner:self options:nil];
    [self addSubview:self.containerView];
    [self setUp];
  }
  return self;
}

- (void) awakeFromNib
{
  [super awakeFromNib];
  [[NSBundle mainBundle] loadNibNamed:@"CYBeaconHUD" owner:self options:nil];
  [self addSubview:self.containerView];
  [self setUp];
}@end
