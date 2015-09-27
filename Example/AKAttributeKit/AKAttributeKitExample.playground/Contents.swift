//: Playground - noun: a place where people can play

import UIKit
import AKAttributeKit

var aStr = "<fg #f00>Hello</fg>, <u>playground</u>".toAttributedString()

aStr = "<fg #f0f>Magenta Text</fg>".toAttributedString()

aStr = "<bg #00f><fg \(UIColor.whiteColor())>White on Blue</fg></bg>".toAttributedString()
aStr = "<font HelveticaNeue-Bold|25>Text with font</font>".toAttributedString()

let font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)!
let str = "<font \(font.asAKAttribute())>Font test 2</font>"
aStr = str.toAttributedString()

aStr = "<t>Strike through</t>".toAttributedString()
aStr = "square<base 3>2</base>".toAttributedString()
aStr = "<i 0.25>Italic or Oblique</i>".toAttributedString()
