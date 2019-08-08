//
//  SGSGeofencingVC.m
//  GettingStarted
//
//  Created by Adrián Rodríguez on 06/08/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSGeofencingVC.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SGSGeofencingVC () <GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSGroundOverlay* floorMapOverlay;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) GMSMarker* marker;
@property (strong, nonatomic) NSArray<GMSPolygon*>* polygons;

@end

@implementation SGSGeofencingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithTitle: @"Geofencing"];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.mapView.delegate = self;
    self.polygons = [NSArray new];
    [self downloadAndShowMap];
    [self downloadAndShowGeofences];
}

/**
 * Retrieves geofences from SitumSDK and paints the corresponding polygon over Google map
 */
- (void) downloadAndShowGeofences {
    [[SITCommunicationManager sharedManager] fetchGeofencesFromBuilding: self.selectedBuildingInfo.building
                                                            withOptions: nil
                                                         withCompletion:^(id  _Nullable result, NSError * _Nullable error) {
                                                             NSArray<SITGeofence*>* fences = result;
                                                             if([fences count] > 0) {
                                                                 [self showGeofences: fences];
                                                             } else {
                                                                 self.topLabel.text = @"Sorry, there was no geofences for this building.";
                                                             }
                                                         }];
}

/**
 * Show multiple geofences over the map
 */
- (void) showGeofences: (NSArray<SITGeofence*>*) geofences {
    
    NSMutableArray* polygons = [NSMutableArray new];
    for(SITGeofence* fence in geofences) {
        GMSPolygon* polygon = [self createAndShowGeofence: fence];
        [polygons addObject: polygon];
    }
    
    // We store the polygons to check intersections later on
    self.polygons = [polygons copy];
}

/**
 * Show a single instance of geofence over the map
 */
- (GMSPolygon*) createAndShowGeofence: (SITGeofence*) geofence {
    
    // Create path with the polygon borders
    GMSMutablePath* path = [GMSMutablePath new];
    for(SITPoint* point in geofence.polygonPoints) {
        [path addCoordinate: point.coordinate];
    }
    
    // Create polygon
    GMSPolygon* polygon = [GMSPolygon new];
    polygon.strokeColor = UIColor.blackColor;
    polygon.strokeWidth = 3;
    polygon.fillColor = UIColor.yellowColor;
    polygon.zIndex = 2;
    polygon.path = path;
    
    // Show polygon
    polygon.map = self.mapView;
    
    return polygon;
}

- (void) mapView: (GMSMapView *) mapView didTapAtCoordinate: (CLLocationCoordinate2D) coordinate {
    // Erase previous marker
    if(self.marker != nil) {
        self.marker.map = nil;
    }
    
    // Create and show new marker
    self.marker = [GMSMarker markerWithPosition: coordinate];
    self.marker.map = self.mapView;
    
    // We check if the marker is inside any geofence
    for(GMSPolygon* polygon in self.polygons) {
        if (GMSGeometryContainsLocation(coordinate, polygon.path, YES)) {
            // The point is inside a geofence, we stop checking the polygons.
            self.topLabel.text = @"The point is inside a geofence.";
            return;
        }
    }
    // The point is NOT inside a geofence
    self.topLabel.text = @"The point is outside any geofence.";
}

/**
 * Downloads a floor map and shows it over the Google map
 */
- (void) downloadAndShowMap {
    
    if (self.selectedBuildingInfo.floors.count == 0) {
        self.topLabel.text = @"Sorry, there was no floors for this building.";
        return;
    }
    
    // Move the map to the coordinates of the building
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget: self.selectedBuildingInfo.building.center zoom: 19];
    [self.mapView setCamera:cameraPosition];
    
    // Download map
    SITFloor *selectedFloor = self.selectedBuildingInfo.floors[0];
    __weak typeof(self) welf = self;
    SITImageFetchHandler fetchingMapFloorHandler = ^(NSData *imageData) {
        // Display map
        SITBounds bounds = [welf.selectedBuildingInfo.building bounds];
        GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc]initWithCoordinate:bounds.southWest
                                                                                    coordinate:bounds.northEast];
        GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds
                                                                            icon:[UIImage imageWithData:imageData]];
        mapOverlay.bearing = [welf.selectedBuildingInfo.building.rotation degrees];
        mapOverlay.zIndex = 1;
        mapOverlay.map = welf.mapView;
        welf.floorMapOverlay = mapOverlay;
    };
    
    [[SITCommunicationManager sharedManager] fetchMapFromFloor:selectedFloor
                                                withCompletion:fetchingMapFloorHandler];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

@end
