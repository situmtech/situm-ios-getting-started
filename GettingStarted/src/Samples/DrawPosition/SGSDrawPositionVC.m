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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Has to be done after the view has appeared otherwise the alert wont last enough
    [self requestLocationAuthorization];
}

#pragma mark -- Request Location Authorization
-(void)requestLocationAuthorization{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:{
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusDenied:{
            //If the user has denied location authorization for this app,
            //[self.locationManager requestWhenInUseAuthorization] wouldnt
            //request authorization again
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:PermissionDeniedAlertTitle
                                         message:PermissionDeniedAlertBody
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:PermissionDeniedOk
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                       }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        default:
            break;
    }
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
    //Allow Google Maps to show user position
    self.googleMapView.myLocationEnabled = YES;
    [self observeChangesOnGoogleMapMyLocation];
}

#pragma mark - Move camera to synced with user location changes
-(void)observeChangesOnGoogleMapMyLocation{
    //Add observer on myLocation property of googleMapView to detect user movements and sync camera
    [self.googleMapView addObserver:self forKeyPath:@"myLocation" options:(NSKeyValueObservingOptionNew) context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    CLLocation *location = change[NSKeyValueChangeNewKey];
    //Make camera follor user
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:16];
    [self.googleMapView animateToCameraPosition:camera];
}

@end
