//
//  SGSRouteAndDirectionsVC.m
//  GettingStarted
//
//  Created by A Barros on 26/9/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "SGSRouteAndDirectionsVC.h"

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

#import <SitumSDK/SitumSDK.h>

static NSString *ResultsKey = @"results";

@interface SGSRouteAndDirectionsVC () <GMSMapViewDelegate, SITDirectionsDelegate>


@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

@property (weak, nonatomic) IBOutlet UIView *routeInfoView;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoLabel;


@property (nonatomic) BOOL ready;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) GMSGroundOverlay *floorMapOverlay;
@property (nonatomic, strong) GMSMutablePath *routePath;
@property (nonatomic, strong) GMSPolyline *polyline;
@property (nonatomic, strong) NSMutableArray *markers;


@property (nonatomic, strong) SITBuildingInfo *buildingInfo;
@property (nonatomic, strong) SITFloor *selectedFloor;

@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, strong) SITRoute *route;

@end

@implementation SGSRouteAndDirectionsVC

@synthesize errorLabel = _errorLabel, reloadButton =_reloadButton, routeInfoView = _routeInfoView, ready = _ready, mapView = _mapView, floorMapOverlay = _floorMapOverlay, routePath = _routePath, polyline = _polyline, markers = _markers, buildingInfo = _buildingInfo, selectedFloor = _selectedFloor, routeInfoLabel = _routeInfoLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ready = NO;
    
    self.points = [[NSMutableArray alloc]init];
    self.markers = [[NSMutableArray alloc]init];
    
    // Configure directions manager
    [SITDirectionsManager sharedInstance].delegate = self;

    
    // Configure mapView
    self.mapView.delegate = self;
    
    [self updateContents];
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

#pragma mark - Upload contents

- (void)updateContents
{
    __weak typeof(self) welf = self;
    
    // Forcing requests to go to the network instead of cache
    NSDictionary *options = @{
                              @"forceRequest":@YES,
                              };
    
    SITFailureCompletion fetchResourceFailureHandler = ^(NSError *error) {
        [welf showError:@"Error fetching contents"];
    };
    
    SITSuccessHandler fetchBuildingInfoSuccessHandler = ^(NSDictionary *mapping) {
        welf.buildingInfo = [mapping valueForKey:ResultsKey];
        
        [welf showMap];
    };
    
    
    SITSuccessHandler fetchingBuildingsSuccessHandler = ^(NSDictionary *mapping) {
        NSArray *buildings = [mapping valueForKey:ResultsKey];
        
        if (buildings.count == 0) {
            NSLog(@"There are no buildings on the account. Please go to dashboard http://dashboard.situm.es and learn more about the first step with Situm technology");
        } else {
            SITBuilding *building = buildings[0];
            NSError *invalidRequest = [[SITCommunicationManager sharedManager] fetchBuildingInfo:building.identifier
                                                                                     withOptions:options
                                                                                         success:fetchBuildingInfoSuccessHandler
                                                                                         failure:fetchResourceFailureHandler];
            if (invalidRequest) {
                NSLog(@"Attempt to invoque invalid request. Fix it before continuing");
            }
        }
    };
    
    NSError *invalidRequest = [[SITCommunicationManager sharedManager] fetchBuildingsWithOptions:options
                                                                                         success:fetchingBuildingsSuccessHandler
                                                                                         failure:fetchResourceFailureHandler];
    
    if (invalidRequest) {
        NSLog(@"Attempt to invoque invalid request. Fix it before continuing");
    }
}

- (void)showRoute
{
    // Configure UI elements to display the route
    
    // Map information
    GMSMutablePath *routePath = [GMSMutablePath path];
    
    // TODO: Filter route steps based on selected floor
    for (SITRouteStep *step in self.route.routeSteps) { //
        
        [routePath addCoordinate:step.from.coordinate];
    }
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:routePath];
    polyline.strokeWidth = 3;
    polyline.map = self.mapView;
    
    self.routePath = routePath;
    
    self.polyline = polyline;
    
    // Route info
    self.routeInfoLabel.text = [NSString stringWithFormat: @"distance: %.0f meters", ceil( self.route.distance) ];
    
    NSLog(@"List of indications");
    for (SITIndication *indication in self.route.indications) {
        NSLog(@"%@", [indication humanReadableMessage]);
    }

}

- (void)showError:(NSString *)error {
    [self.errorLabel setText:error];
    
    [self.errorLabel setHidden:NO];
    [self.reloadButton setHidden:NO];
    
}

- (void)showMap
{
    // Display image on top of Google Maps
    if (self.buildingInfo.floors.count == 0) {
        [self showError:@"No floors content"];
        NSLog(@"The selected building: %@ does not have floors. Correct that on http://dashboard.situm.es", self.buildingInfo.building.name);
        return;
    }
    
    // Move the map to the coordinates of the building
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.buildingInfo.building.center
                                                                       zoom:17];
    
    [self.mapView animateToCameraPosition:cameraPosition];
    
    // Display map
    SITFloor *selectedFloor = self.buildingInfo.floors[0];
    self.selectedFloor = selectedFloor;
    
    __weak typeof(self) welf = self;
    SITImageFetchHandler fetchingMapFloorHandler = ^(NSData *imageData) {
        // On image data we have loaded the image contents of the floor
        
        // Display map
        SITBounds bounds = [welf.buildingInfo.building bounds];
        
        GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc]initWithCoordinate:bounds.southWest
                                                                                    coordinate:bounds.northEast];
        GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds
                                                                            icon:[UIImage imageWithData:imageData]];
        
        mapOverlay.bearing = [welf.buildingInfo.building.rotation degrees];
        
        mapOverlay.map = welf.mapView;
        welf.floorMapOverlay = mapOverlay;
        
    };
    
    [[SITCommunicationManager sharedManager] fetchMapFromFloor:selectedFloor
                                                withCompletion:fetchingMapFloorHandler];
}

#pragma mark - IBActions

- (IBAction)computeRoutePressed:(id)sender {
    NSLog(@"compute route pressed");
    
    if (!self.ready) {
        NSLog(@"Please select two points on the map");
        return;
    }
    
    if (self.points.count != 2) {
        NSLog(@"Configure origin and destination before continuing");
        return;
    }
    
    // TODO: Validate the points are inside the map
    
    SITDirectionsRequest *request = [[SITDirectionsRequest alloc]initWithRequestID:0
                                                                            origin:self.points[0]
                                                                       destination:self.points[1]
                                                                           options:nil];
    
    [[SITDirectionsManager sharedInstance] requestDirections:request];
    
    
}

- (IBAction)clearButtonPressed:(id)sender {
    
    NSLog(@"clear button pressed");
    [self.errorLabel setHidden:YES];
    [self.reloadButton setHidden:YES];
    
    [self.routeInfoLabel setText:@"No computed route"];
    
    for (GMSMarker *marker in self.markers) {
        marker.map = nil;
    }
    
    self.polyline.map = nil;
    self.routePath = nil;
    
    self.markers = [[NSMutableArray alloc]init];
    
    self.points = [[NSMutableArray alloc]init];
    
    self.ready = NO; // This indicates the two points on the map are not configured (or even that the previous conditions are not met - not a building)
}

- (IBAction)reloadContents:(id)sender {
    [self clearButtonPressed:nil];
    
    [self updateContents];
}

#pragma mark - GMSMarpViewDelegate Methods

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    if (!self.selectedFloor) {
        NSLog(@"wait until the first floor map is visible");
        return;
    }

    NSLog(@"did pressed at coordinate: %@",[NSValue valueWithCGSize:CGSizeMake(coordinate.latitude, coordinate.longitude)]);
    
    // Configure the two dots
    SITCoordinateConverter *converter = [[SITCoordinateConverter alloc]initWithDimensions:self.buildingInfo.building.dimensions
                                                                                   center:self.buildingInfo.building.center
                                                                                 rotation:self.buildingInfo.building.rotation];
    
    
    SITPoint *point = [[SITPoint alloc]initWithCoordinate:coordinate
                                       buildingIdentifier:self.buildingInfo.building.identifier
                                          floorIdentifier:self.selectedFloor.identifier
                                      cartesianCoordinate:[converter toCartesianCoordinate:coordinate]];
    
    NSLog(@"building properties::: dimensions:: width: %f, height: %f", self.buildingInfo.building.dimensions.width, self.buildingInfo.building.dimensions.height);
    NSLog(@"building properties::: dimensions:: width: %f, height: %f; rotation: %@", self.buildingInfo.building.dimensions.width, self.buildingInfo.building.dimensions.height, self.buildingInfo.building.rotation);
    
    
    NSLog(@"point properties: %@, cartesian coordinate:: x: %f, y: %f, ", point, point.cartesianCoordinate.x, point.cartesianCoordinate.y);
    
    if (self.points.count == 0) {
        NSLog(@"Configured origin");
        
        GMSMarker *fromMarker = [GMSMarker markerWithPosition:coordinate];
        fromMarker.map = self.mapView;
        
        [self.markers addObject:fromMarker];
        [self.points addObject:point];
        
        
    } else if (self.points.count == 1) {
        NSLog(@"Configured destination");
        
        GMSMarker *destinationMarker= [GMSMarker markerWithPosition:coordinate];
        destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];

        destinationMarker.map = self.mapView;
        
        [self.markers addObject:destinationMarker];

        [self.points addObject:point];
        NSLog(@"You can now compute route");
        self.ready = YES;
        
    } else {
        [self clearButtonPressed:nil];
    }
}

#pragma mark - SITDirectionsDelegate methods

- (void)directionsManager:(id<SITDirectionsInterface>)manager
        didProcessRequest:(SITDirectionsRequest *)request
             withResponse:(SITRoute *)route
{
    // Display route
    if (route.routeSteps.count == 0) {
        NSLog(@"Empty route computed. Did you configure graph on this building?");
        [self showError:@"Empty route"];
        return;
    }
    
    self.route = route;
    [self showRoute];
    
    
}

- (void)directionsManager:(id<SITDirectionsInterface>)manager
 didFailProcessingRequest:(SITDirectionsRequest *)request
                withError:(NSError *)error
{
    [self showError:@"Unable to compute route"];
}

@end
