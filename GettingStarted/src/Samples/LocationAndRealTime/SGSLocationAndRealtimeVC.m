//
//  SGSLocationAndRealtimeVC.m
//  GettingStarted
//
//  Created by A Barros on 21/9/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "SGSLocationAndRealtimeVC.h"

#import <SitumSDK/SitumSDK.h>

#import <GoogleMaps/GoogleMaps.h>

static NSString *ResultsKey = @"results";

@interface SGSLocationAndRealtimeVC () <SITLocationDelegate, SITRealTimeDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) GMSGroundOverlay *floorMapOverlay;
@property (nonatomic, strong) GMSMarker *userLocationMarker;

@property (nonatomic) BOOL ready;
@property (nonatomic) BOOL locationEnabled;
@property (nonatomic) BOOL realtimeEnabled;
@property (weak, nonatomic) IBOutlet UIButton *realtimeActionButton;
@property (weak, nonatomic) IBOutlet UIButton *locationActionButton;

@property (nonatomic, strong) SITFloor *selectedFloor;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

@property (nonatomic, strong) NSMutableDictionary *usersLocations;

@end

@implementation SGSLocationAndRealtimeVC

@synthesize mapView = _mapView, floorMapOverlay = _floorMapOverlay, ready = _ready, realtimeEnabled = _realtimeEnabled;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [SITLocationManager sharedInstance].delegate = self;
    [SITRealTimeManager sharedManager].delegate = self;
    
    self.ready = NO;
    
    [self.errorLabel setHidden:YES];
    [self.reloadButton setHidden:YES];

    self.usersLocations = [[NSMutableDictionary alloc]init];
    
    [self showMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showMap
{
    // Display image on top of Google Maps
    if (self.selectedBuildingInfo.floors.count == 0) {
        NSLog(@"The selected building: %@ does not have floors. Correct that on http://dashboard.situm.es", self.selectedBuildingInfo.building.name);
        return;
    }
    
    // Move the map to the coordinates of the building
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.selectedBuildingInfo.building.center
                                                                       zoom:19];
    
    [self.mapView animateToCameraPosition:cameraPosition];

    // Display map
    SITFloor *selectedFloor = self.selectedBuildingInfo.floors[0];
    self.selectedFloor = selectedFloor;
    
    __weak typeof(self) welf = self;
    SITImageFetchHandler fetchingMapFloorHandler = ^(NSData *imageData) {
        // On image data we have loaded the image contents of the floor
        
        // Display map
        SITBounds bounds = [welf.selectedBuildingInfo.building bounds];
        
        GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc]initWithCoordinate:bounds.southWest
                                                                                    coordinate:bounds.northEast];
        GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds
                                                                            icon:[UIImage imageWithData:imageData]];
        
        mapOverlay.bearing = [welf.selectedBuildingInfo.building.rotation degrees];
        
        mapOverlay.map = welf.mapView;
        welf.floorMapOverlay = mapOverlay;
        
        // Display POIs (indoors and outdoors)
        NSMutableArray *listOfPois = [welf filterPoisOnLevel:selectedFloor];
        if (welf.selectedBuildingInfo.outdoorPois.count > 0) {
            [listOfPois addObjectsFromArray:welf.selectedBuildingInfo.outdoorPois];
        }
        for (SITPOI *indoorPoi in listOfPois) {
            
            GMSMarker *poiMarker = [GMSMarker markerWithPosition:indoorPoi.position.coordinate];
            poiMarker.map = welf.mapView;
            
            
        }
        
        self.ready = YES;
        [self setRealtimeEnabled: NO];
        [self setLocationEnabled: NO];
    };
    
    [[SITCommunicationManager sharedManager] fetchMapFromFloor:selectedFloor
                                                withCompletion:fetchingMapFloorHandler];
}

- (NSMutableArray *)filterPoisOnLevel:(SITFloor *)floor
{
    NSMutableArray *filteredPOIs = [[NSMutableArray alloc]init];
    
    for (SITPOI *poi in self.selectedBuildingInfo.indoorPois) {
        if ([poi.position.floorIdentifier isEqualToString:floor.identifier]) {
            [filteredPOIs addObject:poi];
        }
    }
    
    return filteredPOIs;
}

- (void)updateLocation:(SITLocation *)location {
    GMSMarker *userLocationMarker = [self userLocationMarkerInMapView:self.mapView];
    
    // Update location
    if ([self.selectedFloor.identifier isEqualToString:location.position.floorIdentifier]) {
        userLocationMarker.position = location.position.coordinate;
        userLocationMarker.map = self.mapView;
        
        if (location.quality == kSITHigh) {
            userLocationMarker.icon = [UIImage imageNamed:@"location-pointer"];
            userLocationMarker.rotation = [location.bearing degrees];
            
            
            // Animate camera movement
            GMSCameraPosition *newCameraPosition = [[GMSCameraPosition alloc]initWithTarget:location.position.coordinate
                                                                                       zoom:self.mapView.camera.zoom
                                                                                    bearing:[location.bearing degrees]// new bearing
                                                                               viewingAngle:0];
            
            [self.mapView animateToCameraPosition:newCameraPosition];
        } else {
            userLocationMarker.icon = [UIImage imageNamed:@"location"];
        }
        
    } else {
        userLocationMarker.map = nil; //
        NSLog(@"Found user on a different floor than selected");
    }
    
    
    
    
    
    
}

- (GMSMarker *)userLocationMarkerInMapView:(GMSMapView *)mapView
{
    if (!self.userLocationMarker) {
        GMSMarker *marker = [[GMSMarker alloc]init];
        
        marker.icon = [UIImage imageNamed:@"location-pointer"];
        marker.groundAnchor = CGPointMake(0.5, 0.5);
        
        [marker setTappable: NO];
        
        marker.zIndex = 2;
        
        [marker setFlat: YES];
        marker.map = mapView;
        
        self.userLocationMarker = marker;
    }
    
    return self.userLocationMarker;
}


- (void)showError
{
    [self.errorLabel setText:@"Error fetching contents"];
    
    [self.errorLabel setHidden:NO];
    [self.reloadButton setHidden:NO];
}

- (IBAction)reloadButtonPressed:(id)sender {
    [self.errorLabel setHidden:YES];
    [self.reloadButton setHidden:YES];

}

- (IBAction)locationButtonPressed:(id)sender {
    if (!self.ready) {
        return; // Wait until information is loaded
    }
    
    if (self.locationEnabled) {
        
        [[SITLocationManager sharedInstance] removeUpdates];
        
        self.locationEnabled = NO;
    } else {
    
        SITLocationRequest *request = [[SITLocationRequest alloc]initWithPriority:kSITHighAccuracy
                                                                         provider:kSITHybridProvider
                                                                   updateInterval:1
                                                                       buildingID:self.selectedBuildingInfo.building.identifier
                                                                   operationQueue:nil
                                                                          options:nil];
        
        // Configure here custom beacons if neccessary (through property beaconFilters of request object).
        
        [[SITLocationManager sharedInstance] requestLocationUpdates:request];
        
        self.locationEnabled = YES;
    }
}

- (IBAction)realtimeButtonPressed:(id)sender {
    if (!self.ready) {
        return; // Wait until information is loaded
    }
    
    if (self.realtimeEnabled) {
        [[SITRealTimeManager sharedManager] removeRealTimeUpdates];
        
        self.realtimeEnabled = NO;
    } else {
        SITRealTimeRequest *request = [[SITRealTimeRequest alloc]init];
        request.buildingIdentifier = self.selectedBuildingInfo.building.identifier;
        
        
        
        [[SITRealTimeManager sharedManager] requestRealTimeUpdates:request];
        self.realtimeEnabled = YES;
    }

}

- (void)displayRealtimeData:(SITRealTimeData *)data
{
    // Check there is a selected floor
    if (!self.selectedFloor) {
        return;
    }
    
    for (SITLocation *location in data.locations) {
        // Discarting the location of the device
        if ([location.deviceId isEqualToString:[SITServices deviceID]]) {
            continue;
        }
        
        // Filter positions based on floor
        if ([location.position.floorIdentifier isEqualToString:@"(null)"] ||  [location.position.floorIdentifier isEqualToString:self.selectedFloor.identifier]) { // Display indoor and outdoor locations
            
            GMSMarker *userMarker = [self.usersLocations valueForKey:location.deviceId];
            if (userMarker == nil) {
                userMarker = [[GMSMarker alloc]init];
                userMarker.snippet = location.deviceId;
                userMarker.map = self.mapView;
                userMarker.icon = [UIImage imageNamed:@"location"];
                [self.usersLocations setObject:userMarker
                                        forKey:location.deviceId];
            }
            
            [userMarker setPosition:location.position.coordinate];
        }
    }
}

#pragma mark - RealtimeDelegate Methods

- (void)realTimeManager:(id<SITRealTimeInterface>)realTimeManager
       didFailWithError:(NSError *)error
{
    NSLog(@"error while updating real time data");
}

- (void)realTimeManager:(id<SITRealTimeInterface>)realTimeManager
 didUpdateUserLocations:(SITRealTimeData *)realTimeData
{
    [self displayRealtimeData:realTimeData];
}

#pragma mark - SITLocationDelegate Methods

- (void)locationManager:(id<SITLocationInterface>)locationManager
         didUpdateState:(SITLocationState)state
{
    NSLog(@"location manager changed to state: %d", state);
    if (state == kSITLocationUserNotInBuilding) {
        NSLog(@"Unable to find user on building. Please verify this building has been configured (calibrated) correctly");
    }
    
}

- (void)locationManager:(id<SITLocationInterface>)locationManager
       didFailWithError:(NSError *)error
{
    NSLog(@"an error happened: %@", error);
}

- (void)locationManager:(id<SITLocationInterface>)locationManager
      didUpdateLocation:(SITLocation *)location
{
    NSLog(@"new location update available: :%@", location);
    [self updateLocation:location];
    
    
}

#pragma mark - Setter Methods

- (void)setRealtimeEnabled:(BOOL)realtimeEnabled
{
    _realtimeEnabled = realtimeEnabled;
    
    [self.realtimeActionButton setTitle:realtimeEnabled?@"Stop realtime":@"Start realtime"
                                   forState:UIControlStateNormal];
}

- (void)setLocationEnabled:(BOOL)locationEnabled
{
    _locationEnabled = locationEnabled;
    
    [self.locationActionButton setTitle:locationEnabled?@"Stop Location":@"Start Location"
                                    forState:UIControlStateNormal];
}

- (void)setReady:(BOOL)ready
{
    _ready = ready;
    
    if (ready) {
        [self.realtimeActionButton setHidden:NO];
        [self.locationActionButton setHidden: NO];
    }
}

@end
