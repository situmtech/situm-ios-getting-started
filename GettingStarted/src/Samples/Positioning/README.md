Positioning
==============================

There are 4 steps your app has to follow in order to start receiving the location of the smartphone within a `SITBuilding`.

- Request authorization for using location services in your app. If your app only needs to locate the user when the app is in use, you can follow the steps documented by Apple [here](https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_when-in-use_authorization?language=objc). Otherwise, if your app needs to locate the user also in background, you can follow the steps documented by Apple [here](https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_always_authorization?language=objc). 

- Ensure you conform to `SITLocationDelegate` and that you have assigned your class as a delegate of `SITLocationManager`.

- Create a `SITLocationRequest` for your `SITBuilding` and start requesting location updates using `SITLocationManager`.

- Implement SITLocationDelegate methods where you’ll receive location updates, error notifications and state changes.

```objc

- (void)locationManager:(id<SITLocationInterface>)locationManager 
         didUpdateState:(SITLocationState)state;

- (void)locationManager:(id<SITLocationInterface>)locationManager 
       didFailWithError:(NSError *)error;

- (void)locationManager:(id<SITLocationInterface>)locationManager
      didUpdateLocation:(SITLocation *)location;