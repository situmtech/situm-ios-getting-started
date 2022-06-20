## <a name="drawgeofences"><a/> Draw geofences

Another interesting functionality is to show a geofence on top of a building plan and detect if a tap on the map is inside the geofence.

- To check how the floor plan is drawn you can refer to the example on how to [draw a building](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/DrawBuilding)

- To draw a geofence you first need to download the building geofences with the `fetchGeofencesFromBuilding` method from `SITCommunicationManager`. Next you need to create a `GMSMutablePath` with its points and finally create a `GMSPolygon` using the previous `GMSMutablePath`.

- To detect if the tap was inside the geofence you will need to make use of the `GMSGeometryContainsLocation` function.

<p align="center">
    <img src="/img/geofencing.gif" />
</p>
