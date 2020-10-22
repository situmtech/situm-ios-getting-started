//
//  SGSPositioningVC.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 28/03/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSPositioningVC.h"
@import CoreLocation;

@interface SGSPositioningVC () <SITLocationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startPositioningButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL isPositioning;
@property (nonatomic, strong) NSDictionary *locationStatesTranslator;

@end

// Request user permission strings
static NSString *PermissionDeniedAlertTitle = @"Location Authorization Needed";
static NSString *PermissionDeniedAlertBody = @"This app needs location authorization to work properly. Please go to settings and enable it.";

static NSString *PermissionRestrictedAlertTitle = @"Location Authorization Needed";
static NSString *PermissionRestrictedAlertBody = @"This app needs location authorization to work properly. You have restricted authorization so it wont work properly on your device";

static NSString *UnknonwLocationAuthorizationAlertTitle = @"Location Authorization Needed";
static NSString *UnknonwLocationAuthorizationAlertBody = @"There has been an unknown error when checking your location authorization. Please go to settings and enable it.";

static NSString *PermissionReducedAccuracyAlertTitle = @"Location Full Accuracy Needed";
static NSString *PermissionReducedAccuracyAlertBody = @"This app needs full accuracy location authorization to work properly. Please go to settings and enable it.";

static NSString *UnknonwLocationAccuracyAuthorizationAlertTitle = @"Location Full Accuracy Needed";
static NSString *UnknonwLocationAccuracyAuthorizationAlertBody = @"There has been an unknown error when checking your location accuracy authorization. Please go to settings and enable it.";

static NSString *okButtonText = @"Ok";

@implementation SGSPositioningVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithTitle:@"Positioning"];
    self.isPositioning = NO;
    self.locationStatesTranslator = @{@(kSITLocationStopped):@"Stopped",
                                  @(kSITLocationCalculating):@"Calculating",
                                  @(kSITLocationUserNotInBuilding):@"Not In Building",
                                  @(kSITLocationStarted):@"Started",
                                  @(kSITLocationCompassNeedsCalibration):@"Needs Calibration"
                                  };
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
    [SITLocationManager sharedInstance].delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Has to be done after the view has appeared otherwise the alert wont last enough
    [self.locationManager requestWhenInUseAuthorization];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopPositioning];
}

#pragma mark -- CLocationManager delegates
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager{
    [self alertUserIfIncorrectCoreLocationAuthorization:manager];
}

- (void) locationManager: (CLLocationManager*) manager
didChangeAuthorizationStatus: (CLAuthorizationStatus) status {
   if ([manager respondsToSelector:@selector(accuracyAuthorization)]) {
        //In iOS14 this method was deprecated and now locationManagerDidChangeAuthorization:(CLLocationManager *)manager would be called too
    }else{
        [self alertUserIfIncorrectCoreLocationAuthorization:manager];
    }
}

-(void)alertUserIfIncorrectCoreLocationAuthorization:(CLLocationManager *)manager{
    BOOL properAuthStatus = [self alertUserIfIncorrectLocationAuthorizationStatus:manager];
    if (properAuthStatus){
        [self alertUserIfIncorrectLocationAccuracyAuthorizationStatus:manager];
    }
}

-(BOOL)alertUserIfIncorrectLocationAuthorizationStatus:(CLLocationManager *)manager{
    CLAuthorizationStatus authStatus;
        if ([manager respondsToSelector:@selector(authorizationStatus)]) {
            //If iOS 14
            authStatus = manager.authorizationStatus;
        } else {
            //If iOS <14
            authStatus = [CLLocationManager authorizationStatus];
        }
    switch (authStatus) {
        case kCLAuthorizationStatusDenied:
            [self showAlertWithTitle:PermissionDeniedAlertTitle message:PermissionDeniedAlertBody];
            return NO;
        case kCLAuthorizationStatusRestricted:
            [self showAlertWithTitle:PermissionRestrictedAlertTitle message:PermissionRestrictedAlertBody];
            return NO;
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YES;
        default:
            [self showAlertWithTitle:UnknonwLocationAuthorizationAlertTitle message:UnknonwLocationAuthorizationAlertBody];
            return NO;
    }
}

-(BOOL)alertUserIfIncorrectLocationAccuracyAuthorizationStatus:(CLLocationManager *)manager{
    if ([manager respondsToSelector:@selector(accuracyAuthorization)]){
        //Only in iOS 14
        switch (manager.accuracyAuthorization) {
            case CLAccuracyAuthorizationReducedAccuracy:
                [self showAlertWithTitle:PermissionReducedAccuracyAlertTitle message:PermissionReducedAccuracyAlertBody];
                return NO;
        case CLAccuracyAuthorizationFullAccuracy:
                return YES;
        default:
                [self showAlertWithTitle:UnknonwLocationAccuracyAuthorizationAlertTitle message:UnknonwLocationAccuracyAuthorizationAlertBody];
                return NO;
            }
    }
    return YES;
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:okButtonText
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)startPositioningButtonPressed:(id)sender {
    if (self.isPositioning){
        [self stopPositioning];
    }else{
        [self startPositioning];
    }
}

#pragma mark - Start/Stop Positioning
-(void)startPositioning{
    SITLocationRequest *request = [[SITLocationRequest alloc] initWithBuildingId:self.selectedBuildingInfo.building.identifier];
    // Configure here custom beacons if neccessary (through property beaconFilters of request object).
    [[SITLocationManager sharedInstance] requestLocationUpdates:request];
    self.isPositioning = YES;
}

-(void)stopPositioning{
    [[SITLocationManager sharedInstance] removeUpdates];
    self.isPositioning = NO;
}

#pragma mark - SITLocationDelegate Methods

- (void)locationManager:(id<SITLocationInterface>)locationManager
         didUpdateState:(SITLocationState)state
{
    NSString *stateString = self.locationStatesTranslator[@(state)];
    self.statusLabel.text = stateString;
    NSLog(@"location manager changed to state: %@", stateString);
    if (state == kSITLocationUserNotInBuilding) {
        NSLog(@"Unable to find user on building. Please verify this building has been configured (calibrated) correctly");
    }
}

- (void)locationManager:(id<SITLocationInterface>)locationManager
       didFailWithError:(NSError *)error
{
    NSLog(@"An error happened: %@", error);
}

- (void)locationManager:(id<SITLocationInterface>)locationManager
      didUpdateLocation:(SITLocation *)location
{
    NSLog(@"New location update available: :%@", location);
    self.statusLabel.text = @"";
    self.positionLabel.text = [NSString stringWithFormat:@" building: %@\n floor: %@\n x:%f\n y:%f\n yaw:%@ radians\n accuracy:%f\n", location.position.buildingIdentifier, location.position.floorIdentifier,location.position.cartesianCoordinate.x, location.position.cartesianCoordinate.y,location.bearing, location.accuracy];
}

#pragma mark -- is positioning setter / Screen state customization
-(void)setIsPositioning:(BOOL)isPositioning{
    _isPositioning=isPositioning;
    //Change positioning title
    NSString *positioningButtonTitle = isPositioning?@"Stop Positioning":@"Start Positioning";
    [self.startPositioningButton setTitle:positioningButtonTitle forState:UIControlStateNormal];
    //If no positioning change label text
    if(!isPositioning){
        self.statusLabel.text = @"";
        self.positionLabel.text = @"";
    }
}
@end
