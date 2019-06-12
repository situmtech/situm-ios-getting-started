//
//  SGSDrawPositionVC.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 02/06/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSDrawPositionVC.h"
@import CoreLocation;
@import GoogleMaps;

@interface SGSDrawPositionVC ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,strong) GMSMapView *googleMapView;
@end

// Request user permission strings
static NSString *PermissionDeniedAlertTitle = @"Location Authorization Needed";
static NSString *PermissionDeniedAlertBody = @"This app needs location authorization to work properly. Please go to settings and enable it.";
static NSString *PermissionDeniedOk = @"Ok";
//Show user position button
static NSString *ShowUserPositionButtonText = @"Show User Position";

@implementation SGSDrawPositionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawGoogleMap];
    [self addShowUserPositionButton];
    [self initLocationManager];
}

-(void)initLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
}

#pragma mark - Draw Google Map
-(void)drawGoogleMap{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
    self.googleMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view=self.googleMapView;
}

#pragma mark - Show User position
-(void)addShowUserPositionButton{
    UIBarButtonItem *showUserPositionButton = [[UIBarButtonItem alloc] initWithTitle:ShowUserPositionButtonText style:UIBarButtonItemStylePlain target:self
                                                                          action:@selector(showUserPosition)];
    self.navigationItem.rightBarButtonItem=showUserPositionButton;
}

-(void)showUserPosition{
    //Allow Google Maps to show user position, it will ask for location permission so we dont have to manage it
    self.googleMapView.myLocationEnabled = YES;
    //Ask CLLocationManager to start updating user location
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Move camera to synced with user location changes
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = [locations lastObject];
    //Animate camera to user location when a change is detected
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude  zoom:16];
    [self.googleMapView animateToCameraPosition:camera];
}

@end
