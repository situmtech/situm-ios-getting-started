//
//  ViewController.m
//  GettingStarted
//
//  Created by A Barros on 21/9/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "ViewController.h"
#import "SGSBuildingsListViewController.h"
#import "SampleSegueData.h"
@import CoreLocation;
static NSString *SampleCellIdentifier = @"SampleCell";

// Samples static strings
static NSString *PositioningSample = @"Positioning";
static NSString *LocationAndRealTimeOnMapSample = @"Location and real time";
static NSString *RouteAndIndicationsOnMapSample = @"Route on map";
static NSString *UserInsideEventSample = @"Calculate if the user is inside an event";

// Request user permission strings

static NSString *PermissionDeniedAlertTitle = @"Location Authorization Needed";
static NSString *PermissionDeniedAlertBody = @"This app needs location authorization to work properly. Please go to settings and enable it.";
static NSString *PermissionDeniedOk = @"Ok";

// Segues static strings
static NSString *LocationAndRealTimeOnMapSampleSegue = @"LocationAndRealTimeOnTopOfMapSampleSegue";

static NSString *RouteAndIndicationsOnMapSampleSegue = @"RouteAndIndicationsOnMapSampleSegue";

static NSString *UserInsideEventSampleSegue = @"UserInsideEventSampleSegue";

static NSString *PositioningSampleSegue = @"PositioningSampleSegue";



@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<SampleSegueData *> *samples;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSamples];
    self.locationManager = [[CLLocationManager alloc] init];
}

-(void)initSamples{
    SampleSegueData *positioningSegue = [[SampleSegueData alloc] initWithSampleName:PositioningSample segueId:PositioningSampleSegue];
    SampleSegueData *locationSegue = [[SampleSegueData alloc] initWithSampleName:LocationAndRealTimeOnMapSample segueId:LocationAndRealTimeOnMapSampleSegue];
    SampleSegueData *routeSegue = [[SampleSegueData alloc] initWithSampleName:RouteAndIndicationsOnMapSample segueId:RouteAndIndicationsOnMapSampleSegue];
    SampleSegueData *eventSegue = [[SampleSegueData alloc] initWithSampleName:UserInsideEventSample segueId:UserInsideEventSampleSegue];
    self.samples=@[positioningSegue, locationSegue, routeSegue, eventSegue];
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

- (void)detectedSample:(SampleSegueData *)sampleSegueData
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
    SampleSegueData *sampleSegueData = self.samples[indexPath.row];
    [self detectedSample:sampleSegueData];
    
}

@end
