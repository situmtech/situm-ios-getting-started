## <a name="realtime"><a/> Show user location and other devices locations in real time over Google Maps

This example covers two functionalities:

* How to obtain and show the user location inside a `SITBuilding` over Google Maps. 
* How to get other devices locations on real-time and draw them inside a `SITBuilding` over Google Maps.

First of all, you will need to retrieve the information of the desired `SITBuilding` and draw it on Google Maps. In this example, we will just get the first `SITBuilding` returned. The example [Draw building in Google Maps](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/DrawBuilding) covers this topic in detail.

After displaying the building in the map, we need to get updates about the user location inside the building. The example [Positioning](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/Positioning) cover this topic in detail.

To show the user position on the map we create a Google Maps marker. The location of this marker is updated each time a new `SITLocation` is received using the `SITLocation position.coordinate`.

Finally obtain the real-time location updates of all the smartphones inside the selected `SITBuilding` we need to:
* Set the current class as the delegate of `SITRealTimeManager`
* Build a `SITRealTimeRequest` and call the method `requestRealTimeUpdates` from `SITRealTimeManager`.
* Receive real-time location updates on `SITRealTimeDelegate` methods.

In the following example, we are also going to draw markers in the locations of other users in the building.

<p align="center">
    <img src="/img/location.gif" />
</p>
