//
//  SGSMapViewVC.m
//  GettingStarted
//
//  Created by fsvilas on 28/7/23.
//  Copyright © 2023 Situm Technologies S.L. All rights reserved.
//

#import "SGSMapViewVC.h"
@interface SGSMapViewVC()
@property (weak, nonatomic) IBOutlet SITMapView *mapView;
@end

@implementation SGSMapViewVC

- (void)viewWillAppear:(BOOL)animated{
    SITMapViewConfiguration * mapViewConfiguration = [[SITMapViewConfiguration alloc] initWithBuildingIdentifier:self.selectedBuildingInfo.building.identifier floorIdentifier:self.selectedBuildingInfo.floors[0].identifier];
    [self.mapView loadWithConfiguration:mapViewConfiguration withCompletion:^(SITMapViewController * _Nullable mapViewController, NSError * _Nullable error) {
    }];
    [super viewWillAppear:animated];
}

- (IBAction)startPositioning:(id)sender {
    [[SITLocationManager sharedInstance] requestLocationUpdates:nil];
}

- (IBAction)stopPositioning:(id)sender {
    [[SITLocationManager sharedInstance] removeUpdates];
}

@end
