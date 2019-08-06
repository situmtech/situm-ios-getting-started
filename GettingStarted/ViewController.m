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
static NSString *UserInsideEventSample = @"Calculate if the user is inside an event";
static NSString *GeofencingSample = @"Fetch geofences from a building";

// Segues static strings
static NSString *PositioningSampleSegue = @"PositioningSampleSegue";
static NSString *DrawBuildingSampleSegue = @"DrawBuildingSampleSegue";
static NSString *DrawPositionSampleSegue = @"DrawPositionSampleSegue";
static NSString *LocationAndRealTimeOnMapSampleSegue = @"LocationAndRealTimeOnTopOfMapSampleSegue";
static NSString *RouteAndIndicationsOnMapSampleSegue = @"RouteAndIndicationsOnMapSampleSegue";
static NSString *UserInsideEventSampleSegue = @"UserInsideEventSampleSegue";
static NSString *GeofencingSampleSegue = @"GeofencingSampleSegue";

// Request user permission strings
static NSString *PermissionDeniedAlertTitle = @"Location Authorization Needed";
static NSString *PermissionDeniedAlertBody = @"This app needs location authorization to work properly. Please go to settings and enable it.";
static NSString *PermissionDeniedOk = @"Ok";


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<SGSSampleSegueData *> *samples;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSamples];
    self.locationManager = [[CLLocationManager alloc] init];
}

-(void)initSamples{
    SGSSampleSegueData *positioningSegue = [[SGSSampleSegueData alloc] initWithSampleName:PositioningSample segueId:PositioningSampleSegue];
    SGSSampleSegueData *drawBuildingSegue = [[SGSSampleSegueData alloc] initWithSampleName:DrawBuildingSample segueId:DrawBuildingSampleSegue];
    SGSSampleSegueData *drawPositionSegue = [[SGSSampleSegueData alloc] initWithSampleName:DrawPositionSample segueId:DrawPositionSampleSegue];
    SGSSampleSegueData *locationSegue = [[SGSSampleSegueData alloc] initWithSampleName:LocationAndRealTimeOnMapSample segueId:LocationAndRealTimeOnMapSampleSegue];
    SGSSampleSegueData *routeSegue = [[SGSSampleSegueData alloc] initWithSampleName:RouteAndIndicationsOnMapSample segueId:RouteAndIndicationsOnMapSampleSegue];
    SGSSampleSegueData *eventSegue = [[SGSSampleSegueData alloc] initWithSampleName:UserInsideEventSample segueId:UserInsideEventSampleSegue];
    SGSSampleSegueData *geofencingSegue = [[SGSSampleSegueData alloc] initWithSampleName: GeofencingSample segueId: GeofencingSampleSegue];
    self.samples=@[positioningSegue, drawBuildingSegue, drawPositionSegue, locationSegue, routeSegue, eventSegue, geofencingSegue];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestLocationAuthorization];
}

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
