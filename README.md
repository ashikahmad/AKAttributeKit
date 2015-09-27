# AKAttribute<i>Kit</i>

<!-- [![CI Status](http://img.shields.io/travis/Ashik uddin Ahmad/AKAttributeKit.svg?style=flat)](https://travis-ci.org/Ashik uddin Ahmad/AKAttributeKit) -->
[![Version](https://img.shields.io/cocoapods/v/AKAttributeKit.svg?style=flat)](http://cocoapods.org/pods/AKAttributeKit)
[![License](https://img.shields.io/cocoapods/l/AKAttributeKit.svg?style=flat)](http://cocoapods.org/pods/AKAttributeKit)
[![Platform](https://img.shields.io/cocoapods/p/AKAttributeKit.svg?style=flat)](http://cocoapods.org/pods/AKAttributeKit)

AKAttributeKit is a new fun way to create NSAttributedString. Same power of it without the hassles of genarating! Use HTML-ish tags instead of finding ranges for setting attributes.

```swift
// ---- Native way to NSAttributedString ----//
var mStr = NSMutableAttributedString(string: "Hello Attributed String!")
var range = (mStr.string as NSString).rangeOfString("Hello")
mStr.addAttributes([
    NSForegroundColorAttributeName : UIColor.redColor(),
    NSFontAttributeName : UIFont(name: "Arial", size: 25)!
    ], range: range)

// ---- AKAttributeKit way to NSAttributedString ----//
mStr = "<fg #f00><font Arial|25>Hello</font></fg> Attributed string!".toAttributedString()
// or
mStr = AKAttributeKit.parseString("<fg #f00><font Arial|25>Hello</font></fg> Attributed string!")
```

## Usage

Check the **example project** and/or **playground** to see and play with AKAttributeKit.  
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- XCode 7
- Swift 2
- iOS 8.0+

## HTML-ish tags, not HTML

There are some other libraries to create NSAttributedString form HTML. This is not like that. AKAttributeKit focuses on native APIs and gives a straight way to implement those. The basic difference between AKAttribute Tags and HTML Tags are:

1. AKAttribute tags are some custom defined tags based on NS**AttributeNames provided by native APIs. For convenience, related tags are named like in HTML, but they are not exact same thing.
2. Properties for AKAttribute tags are provided as `| (Bar)`-separated sequencial values.
3. Unlike HTML, any tag started in other tag can be finished outside that tag. e.g. `<fg #f00>Red text <u>with</fg> underline</u>` is works just fine.

## Tags (Short Reference)

Tag | Attribute | Example 
 --- | --- | ---
 `a` | NSLinkAttributeName | `<a http://google.com>Google</a>`
 `base` | NSBaselineOffsetAttributeName | `square<base 15>2</base>`
 `bg` | NSBackgroundColorAttributeName | `<bg #00ff00>Green</bg>` or <code>\<bg 255&#124;255&#124;0>Yellow\</bg></code>
 `ex` | NSExpansionAttributeName | `<ex 5>WIDE</ex>`
 `fg` | NSForegroundColorAttributeName | `<fg #ff0000>Red</fg>` or <code>\<fg 0&#124;0&#124;255>Blue\</fg></code>
 `font` | NSFontAttributeName | <code>Different \<font Arial&#124;18>Font\</font></code>
 `i` | NSObliquenessAttributeName | `<i 0.5>Italic</i>` or `<i 0.8>oblique</i>`
 `k` | NSKernAttributeName | `<k 20>Huge Space</k>`
 `sc`,<br/> `sw` | NSStrokeColorAttributeName,<br/> NSStrokeWidthAttributeName | `<sc #f00><sw 2>Storked Text</sw></sc>`
 `t`,<br/> `tc` | NSStrikethroughStyleAttributeName,<br/> NSStrikethroughColorAttributeName | `<t 1>Wrong</t>` or `<t><tc #f00>Wrong</t></tc>`
 `u`,<br/> `uc` | NSUnderlineStyleAttributeName,<br/> NSUnderlineColorAttributeName | `<u>Important</u>` or `<u 1><uc #f00>Important</u></uc>`
 
 > Note: `tc` or `uc` are not necessary normally. But when used, it need `t` or `u` respectively in scope to be applied. Similarly, `sc` and `sw` need to be coupled to imply a visible attribute change.

## Parameter Types

Here is the short list of parameter types and acceptable formats to use:

Type | Acceptable Formats | Tags to apply
--- | --- | ---
Link | Any valid URL format | `a`
Int | Any integer value supported by respective attribute | `t`, `u`
Float | Any float value | `base`, `ex`, `i`, `k`, `sw`
Color | 1. **Hex formats:**  `rgb`, `rgba`, `rrggbb`, `rrggbbaa` with or without `0x` or `#` prefix <br/> 2. **Integer sequence:**  <code>r&#124;g&#124;b&#124;a</code> param sequence where all params in sequence are Int ranges from 0-255. <br/> 3. **Insert UIColor:** Directly insert UIColor into swift string like `<tag \(myColor)>` where myColor is any UIColor other than `colorWithPatternImage`. | `bg`, `fg`, `sc`, `tc`, `uc`
Font | 1. **Param sequence:** <code>fontName&#124;fontSize</code> param sequence where fontName is String and fontSize is Float <br/> 2. **Insert UIFont:** Directly insert UIFont into swift string like `<font \(myFont.asAKAttribute())>`  | `font`

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
  - [x] italic
  - [x] Strike through
- [ ] Support OSX
- [ ] Ability to escape a tag
- [ ] Unit testing

## Author

Ashik uddin Ahmad, ashikcu@gmail.com

## License

AKAttributeKit is available under the MIT license. See the LICENSE file for more info.
