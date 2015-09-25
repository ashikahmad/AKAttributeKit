# AKAttributeKit

[![CI Status](http://img.shields.io/travis/Ashik uddin Ahmad/AKAttributeKit.svg?style=flat)](https://travis-ci.org/Ashik uddin Ahmad/AKAttributeKit)
[![Version](https://img.shields.io/cocoapods/v/AKAttributeKit.svg?style=flat)](http://cocoapods.org/pods/AKAttributeKit)
[![License](https://img.shields.io/cocoapods/l/AKAttributeKit.svg?style=flat)](http://cocoapods.org/pods/AKAttributeKit)
[![Platform](https://img.shields.io/cocoapods/p/AKAttributeKit.svg?style=flat)](http://cocoapods.org/pods/AKAttributeKit)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- XCode 7
- Swift 2
- iOS 8.0+

## HTML-ish tags, not HTML

There are some other libraries to create NSAttributedString form HTML. This is not like that. AKAttributeKit focuses on native APIs and gives a straight way to implement those. The basic difference between AKAttribute Tags and HTML Tags are:

1. AKAttribute tags are some custom defined tags based on NS**AttributeNames provided by native APIs. For convenience, related tags are named like in HTML, but they are not exact same thing.
2. Properties for AKAttribute tags are provided as `|(Bar)`-separated sequencial values.
3. Unlike HTML, any tag started in other tag can be finished outside that tag. e.g. `<fg #f00>Red text <u>with</fg> underline</u>` is works just fine.

## Tags (Short Reference)

Tag | Attribute | Example 
 --- | --- | ---
 a | NSLinkAttributeName | `<a http://google.com>Google</a>`
 baseline | NSBaselineOffsetAttributeName | `square<baseline 15>2</baseline>`
 bg | NSBackgroundColorAttributeName | `<bg #00ff00>Green</bg>` or <code>\<bg 255&#124;255&#124;0>Yellow\</bg></code>
 ex | NSExpansionAttributeName | `<ex 5>WIDE</ex>`
 fg | NSForegroundColorAttributeName | `<fg #ff0000>Red</fg>` or <code>\<fg 0&#124;0&#124;255>Blue\</fg></code>
 font | NSFontAttributeName | <code>Different \<font Arial&#124;18>Font\</font></code>
 i | NSObliquenessAttributeName | `<i 0.5>Italic</i>` or `<i 0.8>oblique</i>`
 k | NSKernAttributeName | `<k 20>Huge Space</k>`
 sc, sw | NSStrokeColorAttributeName, NSStrokeWidthAttributeName | `<sc #f00><sw 2>Storked Text</sw></sc>`
 t | NSStrikethroughStyleAttributeName | `<t 1>Wrong</t>`
 u | NSUnderlineStyleAttributeName | `<u 1>Important</u>`

## Installation

AKAttributeKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AKAttributeKit"
```

## TODO

Below is some TODOs that I have plan to implement. New ideas and/or help on current tasks are most welcome :D

- [ ] For common tags with (almost) obvius choices make parameter optional.
	- [x] underline
	- [ ] italic
- [ ] Support OSX

## Author

Ashik uddin Ahmad, ashikcu@gmail.com

## License

AKAttributeKit is available under the MIT license. See the LICENSE file for more info.
