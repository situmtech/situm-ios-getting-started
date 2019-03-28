//
//  SGSPositioningVC.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 28/03/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSPositioningVC.h"
@import CoreLocation;

@interface SGSPositioningVC ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

// Request user permission strings
static NSString *PermissionDeniedAlertTitle = @"Location Authorization Needed";
static NSString *PermissionDeniedAlertBody = @"This app needs location authorization to work properly. Please go to settings and enable it.";
static NSString *PermissionDeniedOk = @"Ok";

@implementation SGSPositioningVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Has to be done after the view has appeared otherwise the alert wont last enough
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

@end
