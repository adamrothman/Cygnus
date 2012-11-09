//
//  CYMapView.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/8/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapView.h"
#import "CYUser.h"

@interface CYMapView () <MKMapViewDelegate>

@property (strong, nonatomic)        id<MKAnnotation> beaconAnnotation;

@end

@implementation CYMapView

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
  MKCoordinateSpan span = MKCoordinateSpanMake(ONE_MILE_RADIUS, ONE_MILE_RADIUS);
  MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
  if (!self.userDidInteract) {
    if (isnan(region.center.latitude) || !CLLocationCoordinate2DIsValid(userLocation.coordinate)) return;
    [mapView setRegion:region animated:NO];
  }
  
  [CYUser currentUser].location.longitude = self.userLocation.location.coordinate.longitude;
  [CYUser currentUser].location.latitude = self.userLocation.location.coordinate.latitude;
  
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
  if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
  MKPinAnnotationView *pinView = nil;
  static NSString*defaultPin=@"default-pin";
  pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPin];
  if (annotation == self.beaconAnnotation) {
    pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.canShowCallout = NO;
    pinView.draggable = YES;

  } else { //Map point annotation
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    pinView.animatesDrop = YES;
  }
  
  return pinView;
}










- (void)setUp
{
  self.showsUserLocation = YES;
  _userDidInteract = NO;
  _canEdit = NO;
  self.delegate = self;
  UILongPressGestureRecognizer *lpr = [[UILongPressGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handleLongPress:)];
  [lpr setMinimumPressDuration:0.15f];
  lpr.cancelsTouchesInView = NO;
  [self addGestureRecognizer:lpr];
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self setUp];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setUp];
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
  self.userDidInteract = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
}


@end
