## <a name="communicationmanager"></a> Get buildings' information

Now that you have correctly configured your Android project, you can start writing your application's code.

In order to access the buildings' info, first of all you need to get an instance of the `SITCommunicationManager` with `[SITCommunicationManager sharedManager]`.
This object allows you to fetch your buildings data (list of buildings, floorplans, points of interest, etc.):

To get the buildings you need to call the method `fetchBuildings`

## <a name="positioning"></a> Start the positioning

In your class, make sure to conform to the protocol SITLocationDelegate and to set this class as the `SITLocationManager` delegate to be able to receive location events.

```objc
[[SITLocationManager sharedInstance] setDelegate: self];
```

Then, in order to retrieve the location of the smartphone within a `SITBuilding`, you will need to create a `SITLocationRequest` indicating the `SITBuilding` where you want to start the positioning:


```objc

SITBuilding *building = ...;


SITLocationRequest *request = [[[SITLocationRequest alloc]initWithBuildingId:self.buildingInfo.building.identifier];
```

Now implement SITLocationDelegate methods where you’ll receive location updates, error notifications and state changes.

In `locationManager:didUpdateLocation:` your application will receive the location updates. This `SITLocation` object contains
the building identifier, level identifier, cartesian coordinates, geographic coordinates, orientation,
accuracy, among other location information of the smartphone where the app is running.

In `locationManager:didUpdateState:` the app will receive changes in the status of the system:  `kSITLocationStopped`, `kSITLocationCalculating`, `kSITLocationUserNotInBuilding` or `kSITLocationStarted`.  Please refer to our
[appledoc](http://developers.situm.es/sdk_documentation/ios/documentation/html/Constants/SITLocationState.html) for a full explanation of 
these states.

In `locationManager:didFailWithError:` you will receive updates only if an error has occurred. In this case, the positioning will stop. 

In order to be able to calculate where a user is, it is mandatory to request authoritation to use location services from the user. If your app only needs to locate the user when the app is in use, you can follow the steps documented by Apple [here](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services?language=objc). Otherwise, if your app needs to locate the user also in background, you can follow the steps documented by Apple [here](hhttps://developer.apple.com/documentation/corelocation/getting_the_user_s_location/handling_location_events_in_the_background).

In brief, you will need to add the proper keys to your app's Info.plist file and manage the different authorization status. You can check the method `requestLocationAuthorization` [here](https://github.com/situmtech/situm-ios-getting-started/blob/master/GettingStarted/ViewController.m) as an example.

Finally, you can start the positioning with:

```objc
[[SITLocationManager sharedInstance] requestLocationUpdates:request];
```
and start receiving location updates.   