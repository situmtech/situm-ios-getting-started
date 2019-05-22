//
//  SGSDrawBuildingVC.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 22/05/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSDrawBuildingVC.h"
@import GoogleMaps;

@interface SGSDrawBuildingVC ()
//Make sure this view is of class GMSMapView in storyboard, otherwise the map wouldnt appear
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

static NSString *NoFloorsInBuildingAlertTitle = @"No Floors";
static NSString *NoFloorsInBuildingAlertBody = @"At least one floor is needed to draw the building.";
static NSString *NoFloorsInBuildingOk = @"Ok";

@implementation SGSDrawBuildingVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self drawGoogleMap];
}

#pragma mark - Draw Google Map in Proper View
-(void)drawGoogleMap{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //Use addSubview instead of self.mapView=mapView
    //As you are not presenting the map in self.view but in a self.view subview, use [self.mapView addSubview:mapView]; instead of self.mapView=mapView;
    [self.mapView addSubview:mapView];
}

#pragma mark - Draw Building in Map
- (IBAction)drawBuilding:(id)sender {
    //Check if the building has any floor to show
    if (self.selectedBuildingInfo.floors.count == 0) {
        [self showNoFloorsInBuildingAlert];
        return;
    }
    
    //Move camera to building coordinates and set the desired zoom
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.selectedBuildingInfo.building.center zoom:19];
    [(GMSMapView *)self.mapView animateToCameraPosition:cameraPosition];
    
    //Select the floor to draw
       SITFloor *selectedFloor = self.selectedBuildingInfo.floors[0];
    
    //Get the floor image
    
    [[SITCommunicationManager sharedManager] fetchMapFromFloor:selectedFloor
                                                withCompletion:^(NSData *imageData) {
                                                    //Create Google Maps overly from Situm data
                                                    GMSGroundOverlay *overlay = [self createGMSGroundOverlyImage:imageData bounds:self.selectedBuildingInfo.building.bounds bearing:self.selectedBuildingInfo.building.rotation.degrees];
                                                    //Assign our map as the overly map
                                                    overlay.map=self.mapView;
                                                }];
    
}

#pragma mark - Create Google Maps overly from Situm data
-(GMSGroundOverlay *)createGMSGroundOverlyImage:(NSData *)imageData bounds:(SITBounds)bounds bearing:(float)bearing{
    GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:bounds.southWest coordinate:bounds.northEast];
    GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageWithData:imageData]];
    mapOverlay.bearing = bearing;
    return mapOverlay;
}

-(void)showNoFloorsInBuildingAlert{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NoFloorsInBuildingAlertTitle
                                 message:NoFloorsInBuildingAlertBody
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NoFloorsInBuildingOk
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
