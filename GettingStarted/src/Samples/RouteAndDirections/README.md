## <a name="drawroute"><a/> Show routes between two points in Google Maps
This functionality will allow you to draw a route between two points inside a `SITBuilding` that the user determine by tapping on two different locations inside the building.. As in the previous examples, you can also use another GIS provider, such as OpenStreetMaps, Carto, ESRI, Mapbox, etc.

After obtaining the basic information, you can request a route between the two points to the `SITDirectionsManager`. The route will be received on the `directionsManager:didProcessRequest:withResponse:` callback of the `SITDirectionsDelegate`. At this point, you will be able to draw a Google Maps polyline to represent the route.


