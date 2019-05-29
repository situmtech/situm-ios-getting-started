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
@property (nonatomic,strong) GMSMapView *googleMapView;
@end

static NSString *NoFloorsInBuildingAlertTitle = @"No Floors";
static NSString *NoFloorsInBuildingAlertBody = @"At least one floor is needed to draw the building.";
static NSString *NoFloorsInBuildingOk = @"Ok";

static NSString *ShowBuildingButtonText = @"Show Building";

@implementation SGSDrawBuildingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self drawGoogleMap];
    [self addShowBuildingButton];
}

#pragma mark - Draw Google Map in Proper View
-(void)drawGoogleMap{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
    self.googleMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view=self.googleMapView;
}

-(void)addShowBuildingButton{
    UIBarButtonItem *showBuildingButton = [[UIBarButtonItem alloc] initWithTitle:ShowBuildingButtonText style:UIBarButtonItemStylePlain target:self
                                                                          action:@selector(showBuilding)];
    self.navigationItem.rightBarButtonItem=showBuildingButton;
}

#pragma mark - Draw Building in Map
- (void)showBuilding{
    [self moveCameraToBuildingPosition];
    [self drawBuilding];
}

-(void)moveCameraToBuildingPosition{
    //Move camera to building coordinates and set the desired zoom
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.selectedBuildingInfo.building.center zoom:19];
    [self.googleMapView animateToCameraPosition:cameraPosition];
}

-(void)drawBuilding{
    //Select the floor to draw
    SITFloor *selectedFloor = self.selectedBuildingInfo.floors[0];
    //Get the floor image
    [[SITCommunicationManager sharedManager] fetchMapFromFloor:selectedFloor
                                                withCompletion:^(NSData *imageData) {
                                                    //Create Google Maps overly from Situm data
                                                    GMSGroundOverlay *overlay = [self createGMSGroundOverlyImage:imageData bounds:self.selectedBuildingInfo.building.bounds bearing:self.selectedBuildingInfo.building.rotation.degrees];
                                                    //Assign our map as the overly map
                                                    overlay.map=self.googleMapView;
                                                }];
}

#pragma mark - Create Google Maps overly from Situm data
-(GMSGroundOverlay *)createGMSGroundOverlyImage:(NSData *)imageData bounds:(SITBounds)bounds bearing:(float)bearing{
    GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:bounds.southWest coordinate:bounds.northEast];
    GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageWithData:imageData]];
    mapOverlay.bearing = bearing;
    return mapOverlay;
}

@end
