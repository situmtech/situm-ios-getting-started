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
@property (nonatomic, strong) NSMutableDictionary<NSString*, GMSMarker *> *realTimeMarkers;

@property (nonatomic) BOOL ready;
@property (nonatomic) BOOL locationEnabled;
@property (nonatomic) BOOL realtimeEnabled;
@property (weak, nonatomic) IBOutlet UIButton *realtimeActionButton;
@property (weak, nonatomic) IBOutlet UIButton *locationActionButton;

@property (nonatomic, strong) SITFloor *selectedFloor;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

@end

@implementation SGSLocationAndRealtimeVC

@synthesize mapView = _mapView, floorMapOverlay = _floorMapOverlay, ready = _ready, realtimeEnabled = _realtimeEnabled;

# pragma mark - ViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeNavigationBarWithTitle:@"Location and real time"];
    [SITLocationManager sharedInstance].delegate = self;
    [SITRealTimeManager sharedManager].delegate = self;
    self.ready = NO;
    self.realTimeMarkers = [NSMutableDictionary new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.errorLabel setHidden:YES];
    [self.reloadButton setHidden:YES];
    [self showMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopPositioning];
    [self stopRealtime];
}

#pragma mark - Google Maps methods

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
    
    [self.mapView setCamera:cameraPosition];

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

#pragma mark - Location methods

- (void)startPositioning {
    SITLocationRequest *request = [[SITLocationRequest alloc]initWithBuildingId:self.selectedBuildingInfo.building.identifier];
    
    // Configure here custom beacons if neccessary (through property beaconFilters of request object).
    
    [[SITLocationManager sharedInstance] requestLocationUpdates:request];
    
    self.locationEnabled = YES;
}

- (void)stopPositioning {
    [[SITLocationManager sharedInstance] removeUpdates];
    _userLocationMarker.map = nil;
    self.locationEnabled = NO;
}

- (void)changeLocationStatus {
    if (self.locationEnabled) {
        [self stopPositioning];
    } else {
        [self startPositioning];
    }
}

- (void)showUserMarker:(SITLocation *)location {
    _userLocationMarker = [self userLocationMarkerInMapView:self.mapView];
    
    // Update location
    if ([self.selectedFloor.identifier isEqualToString:location.position.floorIdentifier]) {
        _userLocationMarker.position = location.position.coordinate;
        _userLocationMarker.map = self.mapView;
        
        if (location.quality == kSITHigh && location.bearingQuality == kSITHigh) {
            _userLocationMarker.icon = [UIImage imageNamed:@"location-pointer"];
            _userLocationMarker.rotation = [location.bearing degrees];
            
            
            // Animate camera movement
            GMSCameraPosition *newCameraPosition = [[GMSCameraPosition alloc]initWithTarget:location.position.coordinate
                                                                                       zoom:self.mapView.camera.zoom
                                                                                    bearing:[location.bearing degrees]// new bearing
                                                                               viewingAngle:0];
            
            [self.mapView animateToCameraPosition:newCameraPosition];
        } else {
            _userLocationMarker.icon = [UIImage imageNamed:@"location"];
        }
        
    } else {
        _userLocationMarker.map = nil; //
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
    [self showUserMarker:location];
}

#pragma mark - Realtime methods

- (void)startRealtime {
    SITRealTimeRequest *request = [[SITRealTimeRequest alloc]init];
    request.buildingIdentifier = self.selectedBuildingInfo.building.identifier;
    [[SITRealTimeManager sharedManager] requestRealTimeUpdates:request];
    self.realtimeEnabled = YES;
}

- (void)changeRealtimeStatus {
    if (self.realtimeEnabled) {
        [self stopRealtime];
    } else {
        [self startRealtime];
    }
}

- (void)stopRealtime {
    [[SITRealTimeManager sharedManager] removeRealTimeUpdates];
    for(id key in _realTimeMarkers) {
        _realTimeMarkers[key].map = nil;
    }
    _realTimeMarkers = [NSMutableDictionary new];
    self.realtimeEnabled = NO;
}

- (void)showRealtimeMarkers:(SITRealTimeData *)data
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

            GMSMarker *userMarker = [self.realTimeMarkers valueForKey:location.deviceId];
            if (userMarker == nil) {
                userMarker = [[GMSMarker alloc]init];
                userMarker.map = self.mapView;
                userMarker.snippet = location.deviceId;
                [self.realTimeMarkers setObject:userMarker
                                         forKey:location.deviceId];
            }
            if (location.quality == kSITHigh) {
                userMarker.icon = [UIImage imageNamed:@"realtime-pointer"];
                userMarker.rotation = [location.bearing degrees];
            } else {
                userMarker.icon = [UIImage imageNamed:@"realtime"];
            }
            [userMarker setPosition:location.position.coordinate];
        }
    }
}

#pragma mark - SITRealTimeDelegate Methods

- (void)realTimeManager:(id<SITRealTimeInterface>)realTimeManager
       didFailWithError:(NSError *)error
{
    NSLog(@"error while updating real time data");
}

- (void)realTimeManager:(id<SITRealTimeInterface>)realTimeManager
 didUpdateUserLocations:(SITRealTimeData *)realTimeData
{
    [self showRealtimeMarkers:realTimeData];
}

#pragma mark - Actions
- (IBAction)reloadButtonPressed:(id)sender {
    [self.errorLabel setHidden:YES];
    [self.reloadButton setHidden:YES];
    
}

- (IBAction)locationButtonPressed:(id)sender {
    if (!self.ready) {
        return; // Wait until information is loaded
    }
    
    [self changeLocationStatus];
}

- (IBAction)realtimeButtonPressed:(id)sender {
    if (!self.ready) {
        return; // Wait until information is loaded
    }
    
    [self changeRealtimeStatus];
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
