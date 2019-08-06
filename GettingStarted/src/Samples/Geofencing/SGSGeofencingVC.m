//
//  SGSGeofencingVC.m
//  GettingStarted
//
//  Created by Adrián Rodríguez on 06/08/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSGeofencingVC.h"

@interface SGSGeofencingVC ()

@property (strong, nonatomic) IBOutlet UILabel *buildingLabel;
@property (strong, nonatomic) IBOutlet UILabel *geofencesLabel;

@end

@implementation SGSGeofencingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBarWithTitle: @"Geofencing"];
    self.buildingLabel.text = [NSString stringWithFormat: @"Building: %@", self.selectedBuildingInfo.building.name];
    
    [[SITCommunicationManager sharedManager] fetchGeofencesFromBuilding: self.selectedBuildingInfo.building
                                                            withOptions: nil
                                                         withCompletion:^(id  _Nullable result, NSError * _Nullable error) {
                                                             NSArray<SITGeofence*>* fences = result;
                                                             if([fences count] > 0) {
                                                                 self.geofencesLabel.text = [self generateStringFromGeofencesArray: fences];
                                                             } else {
                                                                 self.geofencesLabel.text = @"Sorry, there was no geofences for this building. You can add some in our Dashboard.";
                                                             }
                                                             [self.geofencesLabel sizeToFit];
                                                            }];
}


// Auxiliar functions used to print the geofences info on the screen
- (NSString*) generateStringFromGeofencesArray: (NSArray<SITGeofence*>*) geofences {
    
    NSString* geofencesString = @"";
    for (SITGeofence* fence in geofences) {
        geofencesString = [geofencesString stringByAppendingString: [self generateStringFromGeofence: fence]];
    }
    
    return geofencesString;
}

- (NSString*) generateStringFromGeofence: (SITGeofence*) geofence {
    
    NSString* fullGeofence = @"{\n";
    fullGeofence = [fullGeofence stringByAppendingString: [NSString stringWithFormat: @"\tname: %@\n", geofence.name]];
    fullGeofence = [fullGeofence stringByAppendingString: [NSString stringWithFormat: @"\tcode: %@\n", geofence.code]];
    fullGeofence = [fullGeofence stringByAppendingString: [NSString stringWithFormat: @"\tdescription: %@\n", geofence.description]];
    fullGeofence = [fullGeofence stringByAppendingString: [NSString stringWithFormat: @"\tfloorId: %@\n", geofence.floorIdentifier]];
    fullGeofence = [fullGeofence stringByAppendingString: [NSString stringWithFormat: @"\tbuildingId: %@\n", geofence.buildingIdentifier]];
    fullGeofence = [fullGeofence stringByAppendingString: [NSString stringWithFormat: @"\tnumber of points: %lu\n", (unsigned long)[geofence.polygonPoints count]]];
    fullGeofence = [fullGeofence stringByAppendingString: @"}\n"];
    
    return fullGeofence;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

@end
