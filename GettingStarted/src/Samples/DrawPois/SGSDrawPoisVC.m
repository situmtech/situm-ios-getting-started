//
//  SGSDrawPoisVC.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 18/06/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSDrawPoisVC.h"
@import GoogleMaps;


@interface SGSDrawPoisVC ()
@property (nonatomic,strong) GMSMapView *googleMapView;
@property (nonatomic,strong) NSMutableDictionary *poiMarkers;
@end

//Show pois button
static NSString *ShowPoisButtonText = @"Show Pois";

@implementation SGSDrawPoisVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    [self drawGoogleMap];
    [self addShowPoisButton];
}

#pragma mark - Draw Google Map
-(void)drawGoogleMap{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
    self.googleMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view=self.googleMapView;
}

#pragma mark - Show Pois
-(void)addShowPoisButton{
    UIBarButtonItem *showPoisButton = [[UIBarButtonItem alloc] initWithTitle:ShowPoisButtonText style:UIBarButtonItemStylePlain target:self
                                                                              action:@selector(showPois)];
    self.navigationItem.rightBarButtonItem=showPoisButton;
}

-(void)showPois{
    if ([self.selectedBuildingInfo.indoorPois count]==0){
        
    }else{
        [self moveCameraToBuildingPosition];
        for (SITPOI * poi in self.selectedBuildingInfo.indoorPois){
            // Get poi icons deselected
            [self poiIconData:poi selected:NO completion:^(NSData *iconData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addMarkerForPoi:poi iconData:iconData map:self.googleMapView];
                });
            }];
        }
        
    }
}


-(void)moveCameraToBuildingPosition{
    //Move camera to building coordinates and set the desired zoom
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.selectedBuildingInfo.building.center zoom:19];
    [self.googleMapView animateToCameraPosition:cameraPosition];
}

-(void)addMarkerForPoi:(SITPOI *)poi iconData:(NSData *)iconData map:(GMSMapView *)gmapView{
    GMSMarker *marker = [GMSMarker markerWithPosition:poi.position.coordinate];
    marker.title = poi.name;
    marker.icon = [UIImage imageWithData:iconData scale:3];
    marker.map = gmapView;
}

-(void)poiIconData:(SITPOI *)poi selected:(BOOL)selected completion:(void(^)(NSData *iconData))completion{
    [[SITCommunicationManager sharedManager] fetchSelected:selected
                                           iconForCategory:poi.category
                                            withCompletion:^(NSData *iconData, NSError *error) {
                                                if (error) {
                                                    NSLog(@"error retrieving icon data");
                                                    completion(nil);
                                                } else {
                                                    completion(iconData);
                                                }
                                            }];
}



@end
