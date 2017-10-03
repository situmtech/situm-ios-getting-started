Situm iOS SDK Code Samples app
==============================

## Table of contents

[Introduction](#introduction)

[Step 1: Configure our SDK in your iOS project (Manual instalation)](#configureproject)

[Step 2: Set API Key](#apikey)

[Step 3: Display information on a map, show user location and realtime updates](#example1-display-location-and-realtime)

[Step 4: Show directions from a point to a destination](#example2-directions)

[More information](#moreinfo)

### Introduction

This is a sample iOS Application built with Situm SDK for iOS. Situm SDK is a set of utilitites that allow any developer to build location based apps using Situm's indoor positioning system. Among many other capabilities, apps developed with Situm SDK will be able to:

1. Obtain information related to buildings where Situm's positioning system is already configured: floorplans, points of interest, geotriggered events, etc.
2. Retrieve the location of the smartphone inside these buildings (position, orientation, and floor where the smartphone is).
3. Compute a route from a point A (e.g. where the smartphone is) to a point B (e.g. any point of interest within the building).
4. Trigger notifications when the user enters a certain area.

In this tutorial, we will guide you step by step to set up your first iOS application using Situm SDK. Before starting to write code, we recommend you to set up an account in our Dashboard (https://dashboard.situm.es), retrieve your APIKEY and configure your first building.

1. Go to the [sign in form](https://dashboard.situm.es/accounts/register) and enter your username and password to sign in.
2. Go to the [apps section](https://dashboard.situm.es/accounts/profile) and click on "Are you a developer?" to generate your APIKEY and download the full SDKs and its documentation (although this project also includes the latest SDK).
3. Go to the [buildings section](https://dashboard.situm.es) and create your first building.
4. Download [SitumMaps](https://play.google.com/store/apps/details?id=es.situm.maps). With this application, you will be able to configure and test Situm's indoor positioning system in your buildings (coming soon on iOS).

Perfect! Now you are ready to develop your first indoor positioning application.

### <a name="configureproject"></a> Step 1: Configure our SDK in your iOS project (Manual installation)

First of all, you must configure Situm SDK in your iOS project. This has been already done for you in the sample application, but nonetheless we will walk you through the process.

* Drag the file SitumSDK.framework to your project (normally this should be included in a SitumSDK folder, inside your Vendor folder). Make sure to check the option "Copy items if needed". In recent versions of Xcode this automatically links your app with the framework as you can check on the Build phase tab, Link Binary with Libraries section. Otherwise, add a link to the framework. You can download the latest version of our SDK from our developers page on [Situm developers iOS](http://developers.situm.es/pages/ios).

In order to work Situm SDK needs some dependencies installed in your app. The easiest way to install them is through CocoaPods.

* Create a file on the root of your project called Podfile and insert the following contents on it:

```
source 'https://github.com/CocoaPods/Specs.git'
target 'GettingStarted' do # Change your target name here
        # Required by Situm SDK
        platform :ios, '8.0'
        pod 'RestKit', '~> 0.27.2'
        pod 'CocoaAsyncSocket'

        # Required by app
        pod 'GoogleMaps'
        pod 'GooglePlaces'

end
```

* Close the *.xcodeproj file.

*  Open a terminal on the root and type 'pod install'. Dependencies should be installed in a few seconds. If you don't have CocoaPods installed, please visit [CocoaPods Installation Guide.](https://guides.cocoapods.org/using/getting-started.html)
 
* From now on, open the *.xcworkspace instead.

To finish, we need you to configure some settings:

* Open your project settings and go to the Build Settings tab. Search for the options Other Linker Flags and add the following item to the list: -lstdc++. Search for the setting Enable Bitcode and chage its value to NO (if not already done).

* Go to the Build Phases settings tab. Add libz.tbd and libc++.tbd on Link Binary With Libraries. 

* On Link Binary With Libraries add the following system frameworks: CoreLocation and CoreMotion.

There is a last step needed if we want to work with the indoor location system: requesting permissions to access location of the user. 

* Go to the Info tab of the Settings of your app. Add one of the following keys:
NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription. The value of this key can be anything you want but as an example just type "Location is required to find out where you are".

And that's all. From now on, you should be able to use Situm SDK in your app by importing its components with the line:

```objective-c
#import <SitumSDK/SitumSDK.h>
```

### <a name="apikey"></a> Step 2: Set API Key

Now that you have correctly configured your iOS project, you can start writting your application's code. All you need to do is introduce your credentials. You can do that your appDelegate.m file. There are two ways of doing this:

##### Using your email address and APIKEY.

This is the recommended option and the one we have implemented in this project. Write the following sentence on the -application:didFinishLaunchingWithOptions: method.

```objective-c
[SITServices provideAPIKey:@"SET YOUR API KEY HERE" 
                  forEmail:@"SET YOUR EMAIL HERE"];
```

Remember to add the following dependency in the same file: 

```objective-c
#import <SitumSDK/SitumSDK.h>
```

You may need to configure an API KEY for use Google Maps on your app. Please follow steps provided on [Google Maps for iOS](https://developers.google.com/maps/documentation/ios-sdk/get-api-key?hl=en) to generate an API Key. When you've successfully generated a key add it to the project by writing the following sentence on the -application:didFinishLaunchingWithOptions: method (appDelegate.m):

```objective-c
[GMSServices provideAPIKey:@"INCLUDE A GOOGLE MAP KEY FOR IOS"];
```

Remember to add the following dependency in the same file: 

```objective-c
#import <GoogleMaps/GoogleMaps.h>
```

###<a name="example1-display-location-and-realtime"></a> Step 3: Display information on a map, show user location and realtime updates

At this point, you should be able to use all the tools on the SDK. In this example you'll see how to retrieve information about your buildings, how to retrieve all the information about one buildings (the first one) and how to display the map of the first floor on Google Maps. Additionaly if location is configured - see how can you do this on [Try us](https://situm.es/en/try-us) page - you'll be able to see your location. If more than one user is being positioned on the same building you'll see the location of different devices in realtime.

### <a name="example2-directions"> Step 4: Show directions from a point to a destination

In this example you'll see how to request directions from one point to a different point and display the route. You could also see a list of human readable indications (not implemented) that will let your users navigate within the route. In order to compute directions in one building you'll need to configure navigation areas on our dashboard [Walking areas configuration](https://dashboard.situm.es/buildings/) by going to the Paths tab.

## <a name="moreinfo"></a> More information

Go to the developers section of the dashboard and download the full documentation of the SDK, including the documentation with all the available functionalities.

For any other question, contact us in https://situm.es/contact.
