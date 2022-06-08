## <a name="realtime"><a/> Show the location of other devices in real time over Google Maps

This functionality will allow you to show the real-time location of devices that are being positioned inside a `SITBuilding` over Google Maps. Remember that you can use any other GIS of your choosing, such as OpenStreetMaps, Carto, ESRI, Mapbox, etc.

First of all, you will need to retrieve the information of the desired `SITBuilding`. In the following example, we will just get the first `SITBuilding` returned.

After displaying the building in the map, the next step is to obtain the real-time location updates of all the smartphones inside the selected `SITBuilding`. To achieve it you will have to set the current class as the delegate of `SITRealTimeManager` build a `SITRealTimeRequest` and call the method `requestRealTimeUpdates` from `SITRealTimeManager` that will start sending realtime updates to its delegate.

In the following example, we are also going to draw markers in the locations of other users in the building.


