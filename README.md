Situm iOS SDK Code Samples app
==============================

This is a sample Objective-C application built using the Situm SDK. With this sample app, you will be able to:

1. Display information on a map, show user location and real-time updates
    * In this example you'll see how to retrieve information about your buildings, how to retrieve all the information about one buildings (the first one) and how to display the map of the first floor on Google Maps. Additionaly if the building is calibrated you'll be able to see your location. If more than one user is being positioned on the same building you'll see the location of different devices in realtime.
2. Show directions from a point to a destination
    * In this example you'll see how to request directions from one point to a different point and display the route. You could also see a list of human readable indications (not implemented) that will let your users navigate within the route. In order to compute directions in one building you'll need to configure navigation areas on our dashboard [Walking areas configuration](https://dashboard.situm.es/buildings/) by going to the Paths tab.

## Table of contents

[Introduction](#introduction)

[Setup](#setup)

1. [Configure our SDK in your iOS project (Manual instalation)](#configureproject)
2. [Set API Key](#apikey)
3. [Setup Google Maps](#mapsapikey)

#### [Samples](#samples)

1. [Fetch buildings](#fetchBuildings)
2. [Fetch information from a particular building](#fetchBuildingInfo)
3. [Start the positioning](#positioning)
4. [Show a building in Google Maps](#drawbuilding)
5. [Compute a route](#directions)
6. [Get realtime updates](#realtime)


[More information](#moreinfo)

## <a name="introduction"></a> Introduction

Situm SDK is a set of utilitites that allow any developer to build location based apps using Situm's indoor positioning system. Among many other capabilities, apps developed with Situm SDK will be able to:

1. Obtain information related to buildings where Situm's positioning system is already configured: floorplans, points of interest, geotriggered events, etc.
2. Retrieve the location of the smartphone inside these buildings (position, orientation, and floor where the smartphone is).
3. Compute a route from a point A (e.g. where the smartphone is) to a point B (e.g. any point of interest within the building).
4. Trigger notifications when the user enters a certain area.
5. See the position of other users in real time.

In this tutorial, we will guide you step by step to set up your first iOS application using Situm SDK. Before starting to write code, we recommend you to set up an account in our [Dashboard] (https://dashboard.situm.es), retrieve your APIKEY and configure your first building. You can find a guide for this process [here] (http://developers.situm.es/pages/rest/authentication.html).

Perfect! Now you are ready to develop your first indoor positioning application.

## <a name="setup"></a> Setup

### <a name="configureproject"></a> Step 1: Configure our SDK in your iOS project (Manual installation)

First of all, you must configure Situm SDK in your iOS project. This has been already done for you in the sample application, but nonetheless we will walk you through the process.

* Drag the file SitumSDK.framework to your project (normally this should be included in a SitumSDK folder, inside your Vendor folder). Make sure to check the option "Copy items if needed". In recent versions of Xcode this automatically links your app with the framework as you can check on the Build phase tab, Link Binary with Libraries section. Otherwise, add a link to the framework. You can download the latest version of our SDK from our developers page on [Situm developers iOS](http://developers.situm.es/pages/ios).

In order to work this Sample Application needs some dependencies installed in your app. The easiest way to install them is through CocoaPods.

* Create a file on the root of your project called Podfile and insert the following contents on it:

```
source 'https://github.com/CocoaPods/Specs.git'
target 'GettingStarted' do # Change your target name here

        # Required by app
        pod 'GoogleMaps'
        pod 'GooglePlaces'

end
```

* Close the *.xcodeproj file.

*  Open a terminal on the root and type 'pod install'. Dependencies should be installed in a few seconds. If you don't have CocoaPods installed, please visit [CocoaPods Installation Guide.](https://guides.cocoapods.org/using/getting-started.html)
 
* From now on, open the *.xcworkspace instead.

To finish, we need you to configure some settings:

* Open your project settings and go to the Build Settings tab. Search for the setting Enable Bitcode and chage its value to NO (if not already done).

* Go to the Build Phases settings tab. Add libz.tbd and libc++.tbd on Link Binary With Libraries. 

* On Link Binary With Libraries add the following system frameworks: CoreLocation and CoreMotion.

There is a last step needed if we want to work with the indoor location system: requesting permissions to access location of the user. 

* Go to the Info tab of the Settings of your app. Add one of the following keys:
NSLocationAlwaysUsageDescription (in XCode, "Privacy - Location Always Usage Description") or NSLocationWhenInUseUsageDescription (in XCode, "Privacy - Location When In Use Usage Description"). The value of this key can be anything you want but as an example just type "Location is required to find out where you are".

And that's all. From now on, you should be able to use Situm SDK in your app by importing its components with the line:

```objc
#import <SitumSDK/SitumSDK.h>
```

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

You may need to configure an API KEY for use Google Maps on your app. Please follow steps provided on [Google Maps for iOS](https://developers.google.com/maps/documentation/ios-sdk/get-api-key?hl=en) to generate an API Key. When you've successfully generated a key add it to the project by writing the following sentence on the -application:didFinishLaunchingWithOptions: method (appDelegate.m):

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

For instance, in the next snippet we fetch all the buildings associated with our user's account and print them:

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

Here we are obtaining the shared instance of the communication manager and using it to query the server and obtaining the configured buildings. The storage of this information should be done in the success handler.


### <a name="fetchBuildingInfo"></a> Fetch information from a particular building

Once you've retrieved the list with your configured buildings, your next step should probably be getting the data about an specific building. This will allow you to draw the building blueprints in the map and start using the positioning functionalities. This info download can be made with an SDK call like this:

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

This process is really similar to the previous one, the only additional data you need to provide is the identifier of the building that you want to use.

### <a name="positioning"></a> Start the positioning

In order to start the indoor positioning within a building, we will need to obtain this building first. In order to do that, please refer to the previous section: [Get buildings' information](#communicationmanager).

In your class, make sure to conform to the protocol SITLocationDelegate

```objc
[[SITLocationManager sharedInstance] setDelegate: self];


SITBuilding *building = ...;


    SITLocationRequest *request = [[SITLocationRequest alloc initWithPriority:kSITHighAccuracy
            provider:kSITInPhoneProvider
      updateInterval:1
          buildingID:self.buildingInfo.building.identifier
      operationQueue:nil
    useDeadReckoning:YES
             options:nil];
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

In order to be able to calculate where a user is, it is mandatory to declare `NSLocationAlwaysUsageDescription` or `NSLocationWhenInUseUsageDescription`. The value of this key can be anything you want but as an example just type "Location is required to find out where you are".

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
        
        GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc]initWithCoordinate:bounds.southWest
                coordinate:bounds.northEast];
        GMSGroundOverlay *mapOverlay = [GMSGroundOverlay groundOverlayWithBounds:coordinateBounds
                           icon:[UIImage imageWithData:imageData]];
        
        mapOverlay.bearing = [welf.buildingInfo.building.rotation degrees];
        
        mapOverlay.map = welf.mapView;
        welf.floorMapOverlay = mapOverlay;
    }

````
You can check the complete sample in the [SGSLocationAndRealTimeVC](https://github.com/situmtech/situm-ios-code-samples/blob/master/GettingStarted/src/Samples/LocationAndRealTime/SGSLocationAndRealtimeVC.m) file.


### <a name="directions"></a> Compute a route

```objc
[SITDirectionsManager sharedInstance].delegate = self;

SITDirectionsRequest *request = [[SITDirectionsRequest alloc] initWithRequestID:0 
												location:myLocation 
												destination:selectedPoi.position 
												options:nil];
[[SITDirectionsManager sharedInstance] requestDirections:request];
```

Where we are using the `SITDirectionsManager` to send the request indicating the user's position, and the desired destination. We also select the delegate to receive the result of the request, said processing can be made with the following code:

```objc
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

## <a name="moreinfo"></a> More information

Go to the [developers section of the web](http://developers.situm.es/pages/ios/) and download the full documentation of the SDK, including the documentation with all the available functionalities. For any other question, [contact us](https://situm.es/contact).
## <a name="supportinfo"></a> Support information

For any question or bug report, please send an email to [support@situm.es](mailto:support@situm.es)
