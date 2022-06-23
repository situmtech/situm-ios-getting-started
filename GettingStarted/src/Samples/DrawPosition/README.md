## <a name="drawposition"><a/> Show the current on Earth user position in Google Maps

This functionality will allow you to represent the current position of your device using Google Maps. However, you can also use another GIS provider, such as Carto, Arcgis, Mapbox, etc.

Note: It is mandatory to request location services authorization in order to be able to calculate where the user is located. You can follow the steps documented by Apple [here](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services?language=objc).

There are 4 steps your app has to follow in order to draw the user position on a GoogleMaps map.

1. Add the map to your view. You can find more information in the section [Getting Started](https://developers.google.com/maps/documentation/ios-sdk/start) of Google Maps documentation.

2. Ask `GMSMapView` to enable locations. This will automatically show user´s location on the map.

3. Ask `CLLocationManager` to start updating user location changes.

4. Animate camera to user location when a change is notified by `CLLocationManager`.


In this example it is important to note that we are requesting location updates from `CLLocationManager`, if you revisit the positioning example you will observe that in that example we requested location updates from `SITLocationManager`. `CLLocationManager` provides updates of user's location on Earth, while `SITLocationManager` provide updates of user's location inside a given building.