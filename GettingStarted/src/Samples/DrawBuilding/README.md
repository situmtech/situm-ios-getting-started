## <a name="drawbuilding"><a/> Show a building in Google Maps

Another interesting functionality is to show the floorplan of a building on top of your favorite GIS provider. In this example, we will show you how to do it by using Google Maps, but you might use any other of your choosing, such as Carto, Arcgis, Mapbox, etc.

As a required step, you will need to complete the steps in the [Setup Google Maps section](https://github.com/situmtech/situm-ios-getting-started#mapsapikey). Once this is done, there are 5 steps your app has to follow in order to draw a floorplan image on a GoogleMaps map.

1.  Add the map to your view. You can find more information in the section [Getting Started](https://developers.google.com/maps/documentation/ios-sdk/start) of Google Maps documentation.

2. Animate the camera to the coordinates where your building is located.

3. Fetch the floor image you want to draw from Situm servers with the method `fetchMapFromFloor` from `SITCommunicationManager`.

4. Create a `GMSGroundOverlay` using the floor image you have just retrieved and the data provided by `SITBuildingInfo`. 

5. Finally, once you have the `GMSGroundOverlay`, you will need to set its maps property to your map view. 

<p align="center">
    <img src="/img/drawBuilding.gif" />
</p>