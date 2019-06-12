Show a Building in Google Maps
==============================

This functionality will allow you to represent the current position of your device using Google Maps. However, you can also use another GIS provider, such as Carto, Arcgis, Mapbox, etc. 

Note: From the steps documented by Apple for requesting locations permissions [here](https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_when-in-use_authorization?language=objc) or [here](https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_always_authorization?language=objc) you will only need to add `NSLocationWhenInUseUsageDescription` key or `NSLocationAlwaysAndWhenInUseUsageDescription` key to your `Information Property List file`. The other steps are managed by Google Maps.

There are 4 steps your app has to follow in order to draw the user position on a GoogleMaps map.

- Add the map to your view. You can find more information in the section [Getting Started](https://developers.google.com/maps/documentation/ios-sdk/start) of Google Maps documentation.

- Ask `GMSMapView` to enable locations. This will automatically show user´s location on the map.

- Ask `CLLocationManager` to start updating user location changes.

- Animate camera to user location when a change is notified by `CLLocationManager`.


In this example it is important to note that we are requesting location uptades from `CLLocationManager`, if you revisit the positioning example you will observe that in that example we requested location updates from `SITLocationManager`. `CLLocationManager` provides updates of user's location on Earth, while `SITLocationManager`, provide updates of user's location inside a given building.