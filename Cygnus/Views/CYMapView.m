//
//  CYMapView.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/8/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapView.h"
#import "CYUser+Additions.h"
#import "CYPoint.h"

@interface CYMapView () <MKMapViewDelegate>

@property (strong, nonatomic)        id<MKAnnotation> beaconAnnotation;
@property (strong, nonatomic)        NSMutableDictionary *mapAnnotations;

@end

@implementation CYMapView


#pragma mark - User Interaction

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
  if (gestureRecognizer.state != UIGestureRecognizerStateBegan || !self.canEdit || ![CYUser user].activeMap) return;
  CGPoint touchPoint = [gestureRecognizer locationInView:self];
  CLLocationCoordinate2D touchMapCoordinate = [self convertPoint:touchPoint toCoordinateFromView:self];
  self.userPointAnnotation = [[MKPointAnnotation alloc] init];
  self.userPointAnnotation.coordinate = touchMapCoordinate;
  [self addAnnotation:self.userPointAnnotation];
  [self.editorDelegate userDidDropPin:self.userPointAnnotation];
  [self zoomToFitAnnotation:self.userPointAnnotation animated:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
  MKCoordinateSpan span = MKCoordinateSpanMake(ONE_MILE_RADIUS, ONE_MILE_RADIUS);
  MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
  if (![CYUser user].activeMap) {
    if (isnan(region.center.latitude) || !CLLocationCoordinate2DIsValid(userLocation.coordinate)) return;
    [mapView setRegion:region animated:NO];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
  if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
  MKPinAnnotationView *pinView = nil;
  static NSString*defaultPin=@"default-pin";
  pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPin];
  if (annotation == self.beaconAnnotation || annotation == self.userPointAnnotation) {
    pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.canShowCallout = NO;
  } else { //Map point annotation
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    pinView.animatesDrop = NO;

//    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [rightButton addTarget:self
//                    action:@selector(showDetails:)
//          forControlEvents:UIControlEventTouchUpInside];
//    pinView.rightCalloutAccessoryView = rightButton;

//    UIImageView *sfIconView = [[UIImageView alloc] init];
//    pinView.leftCalloutAccessoryView = sfIconView;

  }
  return pinView;
}


- (void)updateBeacon:(CLLocationCoordinate2D)beaconCoordinate
{
  MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
  annot.coordinate = beaconCoordinate;
  if (self.beaconAnnotation) [self removeAnnotation:self.beaconAnnotation];
  self.beaconAnnotation = annot;
  [self addAnnotation:annot];
  //assumes that the beacon is being stored on User.
}

- (void)updatePointsForMap:(CYMap *)map animated:(BOOL)animated
{
  [self removeAnnotations:self.mapAnnotations[map.objectID]];
  if (!map.points) return;
  self.mapAnnotations[map.objectID] = map.points.array;
  [self addAnnotations:map.points.array];

}

- (void)removePointsForMap:(CYMap *)map
{
  [self removeAnnotations:self.mapAnnotations[map.objectID]];
  [self.mapAnnotations removeObjectForKey:map.objectID];
  [self zoomToFitAnnotationsWithUser:NO animated:NO];
}

- (void)setUp
{
  self.showsUserLocation = YES;
  _userDidInteract = YES;
  _canEdit = NO;
  self.delegate = self;

  self.mapAnnotations = [NSMutableDictionary dictionaryWithCapacity:5];
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
