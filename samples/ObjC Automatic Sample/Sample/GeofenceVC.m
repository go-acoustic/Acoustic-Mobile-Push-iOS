/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "GeofenceVC.h"
#import "UIColor+Sample.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif


@interface GeofenceVC ()
@property CLLocationManager * locationManager;
@property CLLocation * lastLocation;
@property BOOL followGPS;
@property NSMutableSet * overlayIds;
@property dispatch_queue_t queue;
@property NSMutableDictionary * circleToIdentifier;
@end

@implementation GeofenceVC
-(void)awakeFromNib {
    [super awakeFromNib];
    self.queue = dispatch_queue_create("background", nil);
    self.status.accessibilityIdentifier=@"status";
}

-(IBAction)enable:(id)sender {
    [MCESdk.sharedInstance manualLocationInitialization];
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateStatus];
}

-(void)updateStatus {
    MCEConfig* config = [[MCESdk sharedInstance] config];
    if(config.geofenceEnabled) {
        switch(CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusDenied:
            [self.status setTitle:@"DENIED" forState:UIControlStateNormal];
            [self.status setTitleColor:[UIColor failureColor] forState:UIControlStateNormal];
            break;
            case kCLAuthorizationStatusNotDetermined:
            [self.status setTitle:@"DELAYED (Touch to enable)" forState:UIControlStateNormal];
            [self.status setTitleColor:[UIColor disabledColor] forState:UIControlStateNormal];
            break;
            case kCLAuthorizationStatusAuthorizedAlways:
            [self.status setTitle:@"ENABLED" forState:UIControlStateNormal];
            [self.status setTitleColor:[UIColor successColor] forState:UIControlStateNormal];
            break;
            case kCLAuthorizationStatusRestricted:
            [self.status setTitle:@"RESTRICTED?" forState:UIControlStateNormal];
            [self.status setTitleColor:[UIColor disabledColor] forState:UIControlStateNormal];
            
            break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.status setTitle:@"ENABLED WHEN IN USE" forState:UIControlStateNormal];
            [self.status setTitleColor:[UIColor disabledColor] forState:UIControlStateNormal];
            break;
        }
    } else {
        [self.status setTitle:@"DISABLED" forState:UIControlStateNormal];
        [self.status setTitleColor:[UIColor failureColor] forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createMonitor];
    [self updateStatus];
}

-(void)createMonitor {
    self.overlayIds = [NSMutableSet set];
    self.circleToIdentifier = [NSMutableDictionary dictionary];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    });
}

-(void)viewDidDisappear:(BOOL)animated {
    [self destroyMonitor];
}

-(void)destroyMonitor {
    [self.mapView removeOverlays: self.mapView.overlays];
    self.overlayIds = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

-(IBAction)refresh:(id)sender {
    [[[MCELocationClient alloc] init] scheduleSync];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    self.followGPS=TRUE;
    [self updateGpsButton];
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate=self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RefreshActiveGeofences" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self addGeofenceOverlaysNearCoordinate:self.lastLocation.coordinate radius:100000];
        NSArray * overlays = self.mapView.overlays;
        [self.mapView removeOverlays:overlays];
        [self.mapView addOverlays:overlays];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DownloadedLocations" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        [self addGeofenceOverlaysNearCoordinate: self.lastLocation.coordinate radius:100000];
    }];
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.followGPS=FALSE;
        [self updateGpsButton];
        
        MKCoordinateRegion region = self.mapView.region;
        CLLocation * location = [[CLLocation alloc]initWithLatitude: region.center.latitude longitude: region.center.longitude];
        CLLocation * north = [[CLLocation alloc]initWithLatitude: region.center.latitude - region.span.latitudeDelta * 0.5 longitude: region.center.longitude];
        CLLocation * south = [[CLLocation alloc]initWithLatitude: region.center.latitude + region.span.latitudeDelta * 0.5 longitude: region.center.longitude];
        CLLocationDistance metersLatitude = [north distanceFromLocation:south];
        
        CLLocation * east = [[CLLocation alloc]initWithLatitude: region.center.latitude longitude: region.center.longitude - region.span.longitudeDelta * 0.5];
        CLLocation * west = [[CLLocation alloc]initWithLatitude: region.center.latitude longitude: region.center.longitude + region.span.longitudeDelta * 0.5];
        CLLocationDistance metersLongitude = [east distanceFromLocation:west];

        CLLocationDistance maxMeters = MAX(metersLatitude, metersLongitude);
        [self addGeofenceOverlaysNearCoordinate: location.coordinate radius:maxMeters];
        self.lastLocation = location;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(IBAction)clickGpsButton:(id)sender {
    self.followGPS = !self.followGPS;
    [self updateGpsButton];
}

-(void)updateGpsButton {
    UIColor * color = UIColor.tintColor;
    if(!self.followGPS) {
        color = [color colorWithAlphaComponent:0.2];
    }
    
    self.gpsButton.tintColor = color;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation * location = locations.lastObject;
    if(self.followGPS)
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:TRUE];

        if(self.lastLocation==nil || [self.lastLocation distanceFromLocation:location] > 10)
        {
            [self addGeofenceOverlaysNearCoordinate:location.coordinate radius:10000];
            self.lastLocation = location;
        }
    }
}

-(void)addGeofenceOverlaysNearCoordinate: (CLLocationCoordinate2D) coordinate radius: (double) radius {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSMutableArray * additionalOverlays = [NSMutableArray array];
        NSMutableArray * removeOverlays = [NSMutableArray array];
        NSMutableSet * geofences = [[MCELocationDatabase sharedInstance] geofencesNearCoordinate:coordinate radius:radius];
        
        NSMutableSet * currentlyDisplayedIds = [NSMutableSet set];
        for(MKCircle * overlay in self.mapView.overlays) {
            [currentlyDisplayedIds addObject:overlay.title];
        }
        
        NSMutableSet * currentGeofenceIds = [NSMutableSet set];
        for (MCEGeofence * geofence in geofences) {
            [currentGeofenceIds addObject: geofence.locationId];
            if( ![currentlyDisplayedIds containsObject: geofence.locationId] ) {
                MKCircle * circle = [MKCircle circleWithCenterCoordinate:geofence.coordinate radius:geofence.radius];
                circle.title = geofence.locationId;
                [additionalOverlays addObject: circle];
            }
        }
        
        for(MKCircle * overlay in self.mapView.overlays) {
            if(![currentGeofenceIds containsObject:overlay.title]) {
                [removeOverlays addObject:overlay];
            }
        }
        
        [self.mapView removeOverlays: removeOverlays];
        [self.mapView addOverlays: additionalOverlays];
    });
}

-(BOOL)overlayActive:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle * circle = (MKCircle *)overlay;
        NSString * identifier = circle.title;
        
        if(identifier) {
            for (CLRegion * region in self.locationManager.monitoredRegions) {
                if([region.identifier isEqual: identifier]) {
                    return true;
                }
            }
        }
    }
    return false;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    BOOL active = [self overlayActive: overlay];
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle: overlay];
    
    if(active) {
        renderer.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
        renderer.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    } else {
        renderer.fillColor = [UIColor colorWithRed:0 green:0.4784313725 blue:1 alpha:0.1];
        renderer.strokeColor = [UIColor colorWithRed:0 green:0.4784313725 blue:1 alpha:1.0];
    }
    renderer.lineWidth = 1;
    renderer.lineDashPattern = @[ @(2), @(2) ];
    return renderer;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self updateStatus];
}

@end

