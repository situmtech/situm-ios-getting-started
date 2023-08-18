//
//  ViewController.m
//  GettingStarted
//
//  Created by A Barros on 21/9/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "ViewController.h"
#import "SGSBuildingsListViewController.h"
#import "SGSSampleSegueData.h"
@import CoreLocation;
static NSString *SampleCellIdentifier = @"SampleCell";

// Samples static strings
static NSString *PositioningSample = @"Positioning";
static NSString *DrawBuildingSample = @"Draw Building";
static NSString *DrawPositionSample = @"Draw Position";
static NSString *LocationAndRealTimeOnMapSample = @"Location and real time";
static NSString *RouteAndIndicationsOnMapSample = @"Route on map";
static NSString *GeofencingSample = @"Draw geofences and calculate intersection";
static NSString *MapViewSample = @"Load Mapview";

// Segues static strings
static NSString *PositioningSampleSegue = @"PositioningSampleSegue";
static NSString *DrawBuildingSampleSegue = @"DrawBuildingSampleSegue";
static NSString *DrawPositionSampleSegue = @"DrawPositionSampleSegue";
static NSString *LocationAndRealTimeOnMapSampleSegue = @"LocationAndRealTimeOnTopOfMapSampleSegue";
static NSString *RouteAndIndicationsOnMapSampleSegue = @"RouteAndIndicationsOnMapSampleSegue";
static NSString *GeofencingSampleSegue = @"GeofencingSampleSegue";
static NSString *MapViewSampleSegue = @"MapViewSampleSegue";

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

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<SGSSampleSegueData *> *samples;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSamples];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
}

-(void)initSamples{
    SGSSampleSegueData *positioningSegue = [[SGSSampleSegueData alloc] initWithSampleName:PositioningSample segueId:PositioningSampleSegue];
    SGSSampleSegueData *drawBuildingSegue = [[SGSSampleSegueData alloc] initWithSampleName:DrawBuildingSample segueId:DrawBuildingSampleSegue];
    SGSSampleSegueData *drawPositionSegue = [[SGSSampleSegueData alloc] initWithSampleName:DrawPositionSample segueId:DrawPositionSampleSegue];
    SGSSampleSegueData *locationSegue = [[SGSSampleSegueData alloc] initWithSampleName:LocationAndRealTimeOnMapSample segueId:LocationAndRealTimeOnMapSampleSegue];
    SGSSampleSegueData *routeSegue = [[SGSSampleSegueData alloc] initWithSampleName:RouteAndIndicationsOnMapSample segueId:RouteAndIndicationsOnMapSampleSegue];
    SGSSampleSegueData *geofencingSegue = [[SGSSampleSegueData alloc] initWithSampleName: GeofencingSample segueId: GeofencingSampleSegue];
    SGSSampleSegueData *mapViewSegue = [[SGSSampleSegueData alloc] initWithSampleName: MapViewSample segueId: MapViewSampleSegue];
    self.samples=@[positioningSegue, drawBuildingSegue, drawPositionSegue, locationSegue, routeSegue, geofencingSegue, mapViewSegue];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.locationManager requestWhenInUseAuthorization];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)detectedSample:(SGSSampleSegueData *)sampleSegueData
{
    NSString *segueId = sampleSegueData.segueId;
    [self performSegueWithIdentifier:segueId
                              sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationVC = segue.destinationViewController;
    
    if ([destinationVC isMemberOfClass:[SGSBuildingsListViewController class]]) {
        ((SGSBuildingsListViewController*) destinationVC).segueIdentifier = segue.identifier;
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    // Nothing to do for now
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.samples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SampleCellIdentifier];
    
    NSString *cellText = self.samples[indexPath.row].sampleName;
    
    [cell.textLabel setText:cellText];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Perform segue
    SGSSampleSegueData *sampleSegueData = self.samples[indexPath.row];
    [self detectedSample:sampleSegueData];
    
}

@end
