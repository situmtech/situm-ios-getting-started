<div style="text-align:center">

# Situm iOS SDK Sample app
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

</div>
<div style="float:right; margin-left: 1rem;">

[![](https://situm.com/wp-content/themes/situm/img/logo-situm.svg)](https://www.situm.es)
</div>

[Situm SDK](https://situm.com/docs/01-introduction/) is a set of utilities that allow any developer to build location based apps using Situm's indoor positioning system. 

This project contains an app to test some basic examples using this SDK, so that you can get an idea of what you can achieve with [Situm's tecnology](https://situm.com/en/).

**If you are looking for Swift examples, please check [situm-ios-swift-getting-started](https://github.com/situmtech/situm-ios-swift-getting-started) repository.**

---
## Table of contents
1. [How to run this app](#how-to-run-this-app)
2. [Examples](#examples)
2. [Versioning](#versioning)
3. [Submitting contributions](#submitting-contributions)
4. [License](#license)
5. [More information](#more-information)
6. [Support information](#support-information)

---
## How to run this app

In order to get this examples working you must follow this steps:

1. Create a Situm account, an Api key and a building. Just follow the steps in [this link](https://situm.com/docs/01-introduction/#3-toc-title)

2. Install cocoapods dependencies
```console
    $ pod install
```    

If you dont have Cocoapods installed you can check how to do so on the [Cocoapods Documentation](https://guides.cocoapods.org/using/getting-started.html#getting-started).

3. Set your credentials in the app. Open the `AppDelegate` file and in the  `-application:didFinishLaunchingWithOptions:` method include your own credentials.

```objc
    [SITServices provideAPIKey:@"INCLUDE HERE YOUR API KEY"
                      forEmail:@"INCLUDE HERE YOUR EMAIL"];
```


4. Set your [Google Maps api key](https://developers.google.com/maps/documentation/ios-sdk/get-api-key) in order to run the examples that show a map. Open the `AppDelegate` file and in the  `-application:didFinishLaunchingWithOptions:` method include your own credentials.

```objc
    [GMSServices provideAPIKey:@"INCLUDE A GOOGLE MAP KEY FOR IOS"];
```        


Perfect! You can now test all the examples in this apps.


---
## Examples

1. [Positioning](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/Positioning)
2. [Draw building in Google Maps](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/DrawBuilding)
3. [Draw position in Google Maps](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/DrawPosition)
4. [Get other devices locations on realtime](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/LocationAndRealTime)
5. [Show routes between two points in Google Maps](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/RouteAndDirections)
6. [Show geofences and calculate intersection with a point](https://github.com/situmtech/situm-ios-getting-started/tree/master/GettingStarted/src/Samples/Geofencing)

---
## Versioning

Please refer to [CHANGELOG.md](./CHANGELOG.md) for a list of notables changes for each version of the plugin.

You can also see the [tags on this repository](https://github.com/situmtech/situm-android-getting-started/tags).

---

## Submitting contributions

You will need to sign a Contributor License Agreement (CLA) before making a submission. [Learn more here](https://situm.com/contributions/). 

---
## License
This project is licensed under the MIT - see the [LICENSE](./LICENSE) file for further details.

---

## More information

More info is available at our [Developers Page](https://situm.com/docs/01-introduction/).

---

## Support information

For any question or bug report, please send an email to [support@situm.es](mailto:support@situm.es)
