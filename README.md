Situm iOS SDK Code Samples app
==============================

**If you are looking for Swift examples, please check [situm-ios-swift-getting-started](https://github.com/situmtech/situm-ios-swift-getting-started) repository.**

This is a sample Objective-C application built using the Situm SDK. With this sample app, you will be able to:

1. Display information on a map, show and animate user location and real-time updates
    * In this example you'll see how to retrieve information about your buildings, how to retrieve all the information about one specific building and how to display a floorplan on Google Maps. Additionaly if the building is calibrated you'll be able to see your location. If more than one user is positioning on the same building you'll see the location of different devices in realtime.
2. Show directions from a point to a destination
    * In this example you'll see how to request directions from one point to a different point and display the route. You could also see a list of human readable indications (not implemented) that will let your users navigate within the route. In order to compute directions in one building you'll need to configure navigation areas on our dashboard [Walking areas configuration](https://dashboard.situm.es/buildings/) by going to the Paths tab.
3. Calculate if the user is inside an event
    * In this example, you will see how to calculate if the user's position is inside the trigger area of an event. In order to do this, first, we are going to fetch the list of buildings and retrieve the detailed information of one of them. Then, we will start the positioning on that building, and intersect every location computed with the list of events. If the user happens to be inside an event, a dialog will be shown. In order to be able to properly execute this example, you will need to create at least one event on our dashboard.

## Table of contents

[Introduction](#introduction)

[Setup](#setup)

1. [Configure our SDK in your iOS project](#configuration)
2. [Set API Key](#apikey)
3. [Setup Google Maps](#mapsapikey)

#### [Samples](#samples)

1. [Fetch buildings](#fetchBuildings)
2. [Fetch information from a particular building](#fetchBuildingInfo)
3. [Start the positioning](#positioning)
4. [Show a building in Google Maps](#drawbuilding)
5. [Show and animate the current position in Google Maps](#drawposition)
6. [Show POIs in Google Maps](#drawpois)
7. [Compute a route](#directions)
8. [Show routes between POIs in Google Maps](#drawroute)
9. [Get realtime updates](#realtime)
10. [List Building Events](#buildingevents)
11. [Calculate if the user is inside en event](#positionevents)
12. [Show geofences and calculate intersection with a point](#geofencing)


[More information](#moreinfo)

## <a name="introduction"></a> Introduction

Situm SDK is a set of utilitites that allow any developer to build location based apps using Situm's indoor positioning system. Among many other capabilities, apps developed with Situm SDK will be able to:

1. Obtain information related to buildings where Situm's positioning system is already configured: floorplans, points of interest, geotriggered events, etc.
2. Retrieve the location of the smartphone inside these buildings (position, orientation, and floor where the smartphone is).
3. Compute a route from a point A (e.g. where the smartphone is) to a point B (e.g. any point of interest within the building).
4. Trigger notifications when the user enters a certain area.
5. See the position of other users in real time.

In this tutorial, we will guide you step by step to set up your first iOS application using Situm SDK. Before starting to write code, we recommend you to set up an account in our [Dashboard](https://dashboard.situm.es), retrieve your API KEY and configure your first building. You can find a guide for this process [here](http://developers.situm.es/pages/rest/authentication.html).

Perfect! Now you are ready to develop your first indoor positioning application.

### <a name="configuration"></a> Step 1: Configuration guide

To learn how to configure our SDK, please visit our [developers page](http://developers.situm.es/pages/mobile/ios/quick_start_guide.html).

### <a name="apikey"></a> Step 2: Set API Key

Now that you have correctly configured your iOS project, you can start writting your application's code. All you need to do is introduce your credentials. You can do that your appDelegate.m file. There are two ways of doing this:

##### Using your email address and APIKEY.

This is the recommended option and the one we have implemented in this project. Write the following sentence on the -application:didFinishLaunchingWithOptions: method.

```objc
[SITServices provideAPIKey:@"SET YOUR API KEY HERE" 
                  forEmail:@"SET YOUR EMAIL HERE"];
```

##### Using your user and password

This is the other available option to provide your credentials, with your username and password. As in the previous case, write the following sentence on the -application:didFinishLaunchingWithOptions: method.

```objc
[SITServices provideUser:@"SET YOUR USER HERE" 
                  password:@"SET YOUR PASSWORD HERE"];
```
In both cases, remember to add the following dependency in the same file: 

```objc
#import <SitumSDK/SitumSDK.h>
```

### <a name="mapsapikey"></a> Step 3: Setup Google Maps

You may need to configure an API KEY in order to be able to use Google Maps on your app. Please follow steps provided on [Google Maps for iOS](https://developers.google.com/maps/documentation/ios-sdk/get-api-key?hl=en) to generate an API Key. When you've successfully generated a key add it to the project by writing the following sentence on the `application:didFinishLaunchingWithOptions:` method (`AppDelegate.m`):

```objc
[GMSServices provideAPIKey:@"INCLUDE A GOOGLE MAP KEY FOR IOS"];
```

Remember to add the following dependency in the same file: 

```objc
#import <GoogleMaps/GoogleMaps.h>
```

## Samples <a name="samples"></a>
### <a name="fetchBuildings"></a> Fetch buildings

Now that you have correctly configured your iOS project, you can start writing your application's code. 

In order to access the buildings' info, first of all you need to get an instance of the `SITCommunicationManager` with `[SITCommunicationManager sharedManager]`.
This object allows you to fetch your buildings' data (list of buildings, floorplans, points of interest, etc.):

In the next snippet we will fetch all the buildings associated with our user's account and print them:

```objc

[[SITCommunicationManager sharedManager] fetchBuildingsWithOptions:nil success:^(NSDictionary *mapping) {
        NSArray<SITBuilding*>* buildings = [mapping valueForKey:@"results"];
        NSLog(@"%@", buildings);
         for (SITBuilding *building in buildings) {
            NSLog(@"%@", building.name);
        }
        
        
    } failure:^(NSError *error) {
        NSLog(@"error fetching buildings: %@", error);
    }];
```

### <a name="fetchBuildingInfo"></a> Fetch information from a particular building

Once you've retrieved the list with your configured buildings, your next step should probably be getting the data about an specific building. This will allow you to draw the building blueprints in the map and start using the positioning functionalities. 

```objc
SITBuilding *selectedBuilding = buildings[0];
[[SITCommunicationManager sharedManager] fetchBuildingInfo:selectedBuilding.identifier
                    withOptions:nil
                        success:^(NSDictionary *mapping) {
                        	SITBuildingInfo *buildingInfo = [mapping valueForKey:@"results"];
                        }
                        failure:^(NSError *error) {
                        // Handle error accordingly
                    	}];

```

### <a name="positioning"></a> Start the positioning

In order to start the indoor positioning within a building, we will need to obtain this building first. In order to do that, please refer to the previous section: [Get buildings' information](#communicationmanager).

In your class, make sure to conform to the protocol SITLocationDelegate

```objc
[[SITLocationManager sharedInstance] setDelegate: self];


SITBuilding *building = ...;


SITLocationRequest *request = [[[SITLocationRequest alloc]initWithBuildingId:self.buildingInfo.building.identifier];
```

Implement SITLocationDelegate methods where you’ll receive location updates, error notifications and state changes.

```objc

@interface MyViewController () <SITLocationDelegate>

...

- (void)locationManager:(id<SITLocationInterface>)locationManager 
         didUpdateState:(SITLocationState)state;

- (void)locationManager:(id<SITLocationInterface>)locationManager 
       didFailWithError:(NSError *)error;

- (void)locationManager:(id<SITLocationInterface>)locationManager
      didUpdateLocation:(SITLocation *)location;


[SITLocationManager sharedInstance].delegate = self;
```

In `didUpdateLocation` your application will receive the location updates. This `SITLocation` object contains
the building identifier, level identifier, cartesian coordinates, geographic coordinates, orientation,
accuracy, among other location information of the smartphone where the app is running.

In `didUpdateState` the app will receive changes in the status of the system:  `kSITLocationStopped`, `kSITLocationCalculating`, `kSITLocationUserNotInBuilding` or `kSITLocationStarted`.  Please refer to our
[appledoc](http://developers.situm.es/sdk_documentation/ios/documentation/html/Constants/SITLocationState.html) for a full explanation of 
these states.

In `didFailWithError` you will receive updates only if an error has occurred. In this case, the positioning will stop. 

In order to be able to calculate where a user is, it is mandatory to request authoritation to use location services from the user. If your app only needs to locate the user when the app is in use, you can follow the steps documented by Apple [here](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services?language=objc). Otherwise, if your app needs to locate the user also in background, you can follow the steps documented by Apple [here](hhttps://developer.apple.com/documentation/corelocation/getting_the_user_s_location/handling_location_events_in_the_background).

In brief, you will need to add the proper keys to your app's Info.plist file and manage the different authorization status. You can check the method `requestLocationAuthorization` [here](https://github.com/situmtech/situm-ios-getting-started/blob/master/GettingStarted/ViewController.m) as an example.

Finally, you can start the positioning with:

```objc
[[SITLocationManager sharedInstance] requestLocationUpdates:request];
```
and start receiving location updates.

### <a name="drawbuilding"></a> Show a building in Google Maps

Another interesting functionality is to show the floorplan of a building on top of your favorite GIS provider. In this example, we will show you how to do it by using Google Maps, but you might use any other of your choosing, such as OpenStreetMaps, Carto, ESRI, Mapbox, etc.

As a required step, you will need to complete the steps in the [Setup Google Maps](#mapsapikey) section. Once this is done, you should
 obtain the floors of the target `SITBuilding`.

 ```objc

#import <GoogleMaps/GoogleMaps.h>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) GMSGroundOverlay *floorMapOverlay;

...

GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.buildingInfo.building.center
                                                                   zoom:19];
    
    [self.mapView animateToCameraPosition:cameraPosition];

    SITFloor *selectedFloor = self.buildingInfo.floors[0];
    self.selectedFloor = selectedFloor;
    
    __weak typeof(self) welf = self;
    SITImageFetchHandler fetchingMapFloorHandler = ^(NSData *imageData) {

        SITBounds bounds = [welf.buildingInfo.building bounds];
        
        GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc]
            initWithCoordinate:bounds.southWest
                    coordinate:bounds.northEast];
        GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds
                                                                            icon:[UIImage 
                                                                   imageWithData:imageData]];
        
        mapOverlay.bearing = [welf.buildingInfo.building.rotation degrees];
        
        mapOverlay.map = welf.mapView;
        welf.floorMapOverlay = mapOverlay;
    }

````
You can check the complete sample in the [SGSLocationAndRealTimeVC](https://github.com/situmtech/situm-ios-code-samples/blob/master/GettingStarted/src/Samples/LocationAndRealTime/SGSLocationAndRealtimeVC.m) file.

### <a name="drawposition"></a> Show and animate the current position in Google Maps

This functionality will allow you to represent the current position of your device using Google Maps. Instead, you can also use another GIS provider, such as OpenStreetMaps, Carto, ESRI, Mapbox, etc.

First of all, you will need to perform all the steps required to start receiving location updates, as shown in the [Start the positioning](#positioning) section.

Then, in the delegate method `didUpdateLocation`, you can insert the code required to draw the circle that represents the position of the device.

```objc
#import <GoogleMaps/GoogleMaps.h>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

...

GMSMarker *userLocationMarker = [self userLocationMarkerInMapView:self.mapView];
    
    if ([self.selectedFloor.identifier isEqualToString:location.position.floorIdentifier]) {
        userLocationMarker.position = location.position.coordinate;
        userLocationMarker.map = self.mapView;
        
        if (location.quality == kSITHigh && location.bearingQuality == kSITHigh) {
            userLocationMarker.icon = [UIImage imageNamed:@"location-pointer"];
            userLocationMarker.rotation = [location.bearing degrees];
            
            GMSCameraPosition *newCameraPosition = [[GMSCameraPosition alloc
                initWithTarget:location.position.coordinate
                          zoom:self.mapView.camera.zoom
                       bearing:[location.bearing degrees]
                  viewingAngle:0];
            
            [self.mapView animateToCameraPosition:newCameraPosition];
        } else {
            userLocationMarker.icon = [UIImage imageNamed:@"location"];
        }
        
    } else {
        userLocationMarker.map = nil;
        NSLog(@"Found user on a different floor than selected");
    }
```
You can check the complete sample in the [SGSLocationAndRealTimeVC](https://github.com/situmtech/situm-ios-code-samples/blob/master/GettingStarted/src/Samples/LocationAndRealTime/SGSLocationAndRealtimeVC.m) file.

### <a name="drawpois"></a> Show POIs (Points of Interest) in Google Maps

This functionality allows to show the list of `SITPoi`s of a `SITBuilding` over Google Maps. Instead, you can also use another GIS provider, such as OpenStreetMaps, Carto, ESRI, Mapbox, etc.

First of all, we need to retrieve the list of `SITPoi`s of our `SITBuilding` using the `SITCommunicationManager`. 

```objc
#import <GoogleMaps/GoogleMaps.h>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

...

for (SITPOI *indoorPoi in listOfPois) {
    GMSMarker *poiMarker = [GMSMarker markerWithPosition:indoorPoi.position.coordinate];
    poiMarker.map = welf.mapView;            
}
```

### <a name="directions"></a> Compute a route

```objc
[SITDirectionsManager sharedInstance].delegate = self;

SITDirectionsRequest *request = [[SITDirectionsRequest alloc]initWithLocation:myLocation
                                                                withDestination:selectedPoi.position];

[[SITDirectionsManager sharedInstance] requestDirections:request];
```

We also need to implement the following delegate methods:

```objc

@interface SGSRouteAndDirectionsVC () <SITDirectionsDelegate>

- (void)directionsManager:(id<SITDirectionsInterface>)manager
        didProcessRequest:(SITDirectionsRequest*)request
             withResponse:(SITRoute*)route {
	// Handle route information
}

- (void)directionsManager:(id<SITDirectionsInterface>)manager
 didFailProcessingRequest:(SITDirectionsRequest*)request 
                withError:(NSError*)error {
    // Handle request error
}
```

You can check the complete sample in the [SGSRouteAndDirectionsVC](https://github.com/situmtech/situm-ios-code-samples/blob/master/GettingStarted/src/Samples/RouteAndDirections/SGSRouteAndDirectionsVC.m) file.

### <a name="drawroute"></a> Show routes between POIs in Google Maps
This funcionality will allow you to draw a route between two points inside a `SITBuilding`. As in the previous examples, you can also use another GIS provider, such as OpenStreetMaps, Carto, ESRI, Mapbox, etc.

In this example, we will show a route between two `SITPoi`s of a `SITBuilding`. Therefore, in the first place you will need to get a `SITBuilding` and its `SITPoi`s using the `SITCommunicationManager`. Please refer to the 
[Show POIs over Google Maps](#drawpois) example in order to retrieve this information.

After obtaining the basic information, you can request a route between two of the retrieved `SITPoi`s to the `SITDirectionsManager`. At this point, you will be able to draw a Google Maps polyline to represent the route.

```objc
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) GMSMutablePath *routePath;
@property (nonatomic, strong) GMSPolyline *polyline;

...

GMSMutablePath *routePath = [GMSMutablePath path];


for (SITRouteStep *step in self.route.routeSteps) { 
    [routePath addCoordinate:step.from.coordinate];
}

GMSPolyline *polyline = [GMSPolyline polylineWithPath:routePath];
polyline.strokeWidth = 3;
polyline.map = self.mapView;

self.routePath = routePath;

self.polyline = polyline;
```

You can check the complete sample in the [SGSRouteAndDirectionsVC](https://github.com/situmtech/situm-ios-code-samples/blob/master/GettingStarted/src/Samples/RouteAndDirections/SGSRouteAndDirectionsVC.m) file.

### <a name="realtime"></a> Get realtime updates

Another interesting functionality you can find in the SDK is the realtime updates of all the users in a building. With this you can show in your app not only the user's position, but also inform about where are others located. In order to obtain this information, you need to include some steps fairly similar to the previous section about positioning. Again, you'll need to implement and send a request to start receiving the real time updates, and also prepare a delegate to  process the realtime updates. This can be done in the following manner:

```objc
SITRealTimeRequest *request = [[SITRealTimeRequest alloc]init];
request.buildingIdentifier = building.identifier;
request.updateInterval = 5;   
    
[[SITRealTimeManager sharedManager] requestRealTimeUpdates:request];
```

In this code we create a realtime request to be sent, with the identifier of the desired building and a refresh rate in seconds (this value is limited between 3 and 20 seconds). After this, the only thing left to do is receiving and processing the realtime updates sent from the server. The required methods are the following:

```objc
- (void) realTimeManager: (id<SITRealTimeInterface>) realTimeManager
  didUpdateUserLocations:(SITRealTimeData *)realTimeData {
    			// Handle the realtime updates
}

- (void) realTimeManager: (id<SITRealTimeInterface>) realTimeManager 
        didFailWithError:(NSError *)error {
    			// Handle properly the error
}
```

### <a name="buildingevents"></a> List Building Events

You can obtain more information about what an event is [here](http://developers.situm.es/pages/terminology/#event_container).

In order to know all the `SITEvent` you have in your `SITBuilding`, the first thing you have to do is to fetch your buildings and select the one you want to check. This SDK allows you to know the exact position of the `SITEvent` and to know where the message in your smartphone will be shown. In the following example we will show you how to fetch the events and how to list them in order to know the details for each one.

```objc
[[SITCommunicationManager sharedManager] fetchEventsFromBuilding:selectedBuilding
                                                 withCompletion:^SITHandler(NSArray<SITEvent *> *result,
                                                 NSError *error) {
    if (result) {
        //process events
    }
    if (error) {
        //handle error
    }
    return false;
}];
```
### <a name="positionevents"></a> Calculate if the user is inside en event

In order to determine if the user is inside the trigger area of a `SITEvent`, you should intersect every new location with the `trigger` area of every event in the building. 
This can be done by following the next example (Please note that minimun iOS SDK version is 2.12.0):

```objc
- (void)locationManager:(id<SITLocationInterface>)locationManager
      didUpdateLocation:(SITLocation *)location
{
    
    SITEvent *event = [self getEventForLocation: location];
    
    if (event != nil) {
        NSLog(@"%@", [NSString stringWithFormat:@"User inside event: %@", event.name]);
    }
}

- (SITEvent*) getEventForLocation: (SITLocation*) location {
    for (SITEvent *event in self.buildingInfo.events) {
        if ([self isLocation: location insideEvent: event]) {
            return event;
        }
    }
    return nil;
}

- (BOOL) isLocation: (SITLocation*) location
        insideEvent: (SITEvent*) event {
    if (! [location.position.floorIdentifier isEqualToString:event.trigger.center.floorIdentifier]) {
        return false;
    }
    return [location.position distanceToPoint:event.trigger.center] < [event.trigger.radius floatValue];
}
```

### <a name="geofencing"></a> Show geofences and calculate intersection with a point

This functionality will allow your app to display geofences (previously configured in the [dashboard](http://dashboard.situm.es/)) over
your floorplans and calculate if an user's position is entering or leaving any of that areas.
This is done by obtaining the geofences information and constructing a polygon from them, which can be used to represent in a map.

```objc
[[SITCommunicationManager sharedManager] fetchGeofencesFromBuilding: self.selectedBuildingInfo.building
                                                            withOptions: nil
                                                         withCompletion:^(id  result, NSError * error) {

                                                            NSArray<SITGeofence*>* fences = result;
                                                            GMSMutablePath* path = [GMSMutablePath new];
                                                            for(SITPoint* point in fences[0].polygonPoints) {
                                                                [path addCoordinate: point.coordinate];
                                                            }

                                                            // Create polygon
                                                            GMSPolygon* polygon = [GMSPolygon new];
                                                            polygon.strokeColor = UIColor.blackColor;
                                                            polygon.strokeWidth = 3;
                                                            polygon.fillColor = UIColor.yellowColor;
                                                            polygon.path = path;

                                                            // Show polygon
                                                            polygon.map = mapView;
                                                         }];
```

## <a name="moreinfo"></a> More information

Go to the [developers section of the web](http://developers.situm.es/pages/mobile/ios/index.html) and download the full documentation of the SDK, including the documentation with all the available functionalities. For any other question, [contact us](https://situm.es/contact).
## <a name="supportinfo"></a> Support information

For any question or bug report, please send an email to [support@situm.es](mailto:support@situm.es)
