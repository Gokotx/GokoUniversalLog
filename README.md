# GokoUniversalLog
Universal Log Tools for Objective-C
## How To Get Started
- [Download GokoUniversalLog](https://github.com/Gokotx/GokoUniversalLog/archive/master.zip) and try out the included example demo
- Read the GokoUniversalLog.h file for a comprehensive look at all of the APIs available in GokoUniversalLog

## Installation
## From CocoaPods
- [CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C , which automates and simplifies the process of using 3rd-party libraries like [GokoUniversalLog](https://github.com/Gokotx/GokoUniversalLog) in your projects . First , add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):
` pod 'GokoUniversalLog'`
- If you want to use the latest features of [GokoUniversalLog](https://github.com/Gokotx/GokoUniversalLog) use normal external source dependencies .
` pod 'GokoUniversalLog', :git => 'https://github.com/Gokotx/GokoUniversalLog.git'`
This pulls from the master branch directly .
- Second, ,  install GokoUniversalLog into your project :
` pod install`
## Carthage
- Not support now . coming soon
## Manually
- Just drag the GokoUniversalLog/GokoUniversalLog folder into your project .
## Usage
### Gloable Setting For GokoUniversalLog
- Suggest to invoke the follow method in ` -(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
```
/**
Gloable setting for GokoUniversalLog

@param enable YES for enable , NO for disable
*/
void GokoLogEnable(BOOL enable);

```
### Start Log
- If you just want to see a convenient log for their self of objects , use the following :
```
__attribute__((overloadable))  void GokoLog(id firstParam, ...) NS_REQUIRES_NIL_TERMINATION;
```
usually look as simple as this (see [demo](https://github.com/Gokotx/GokoUniversalLog/archive/master.zip) for more):
```
@Class Foo
NSString * fooo = @"Fooo";
GokoLog(fooo,[Foo new], nil);
```

- If you want to see  all properties of all objects , use the following :
```
__attribute__((overloadable)) void GokoDescriptionLog(id firstParam, ...) NS_REQUIRES_NIL_TERMINATION;
```
usually look as simple as this ( see [demo](https://github.com/Gokotx/GokoUniversalLog/archive/master.zip) for more) :
```
@Class Foo
NSString * fooo = @"Fooo";
GokoDescriptionLog(fooo,[Foo new], nil);
```
## License
GokoUniversalLog is released under the MIT license. See LICENSE for details.
