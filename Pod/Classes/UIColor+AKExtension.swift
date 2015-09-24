//
//  UIColor+AKExtension.swift
//  AKAttributeKitDemo
//
//  Created by Ashik Ahmad on 11/8/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    /**
    Represents web-firnedly hexadecimal string representation of this color,
    
    Example: `#FF0000FF` for Red, `#FFFF00FF` for Yellow
    */
    public var hexString:String? {
        let nComp = CGColorGetNumberOfComponents(self.CGColor)
        let comp = CGColorGetComponents(self.CGColor)
        
        if (nComp == 4) { // RGB ColorSpace
            let r = Int(comp[0] * 255)
            let g = Int(comp[1] * 255)
            let b = Int(comp[2] * 255)
            let a = Int(comp[3] * 255)
            return NSString(format: "#%02X%02X%02X%02X", r, g, b, a) as String
        } else if (nComp == 2) { // White ColorSpace
            let w = Int(comp[0] * 255)
            let a = Int(comp[1] * 255)
            return NSString(format: "#%02X%02X%02X%02X", w, w, w, a) as String
        }
        
        return nil;
    }
    
    /**
    Converts a formatted hexadecimal color-code string into respective UIColor.
    
    - parameter hexStr: String in any of these formats: `rgb | rgba | rrggbb | rrggbba` with or without prefix: `0x | #`
    - returns: UIColor from the `hexStr` if it is parsed successfully, nil otherwise.
    */
    public class func colorFromString(hexString hexStr: String)->UIColor?
    {
        // 1. Make uppercase to reduce conditions
        var cStr = hexStr.trim().uppercaseString;
        
        // 2. Check if valid input
        let validRange = cStr.rangeOfString("\\b(0X|#)?([0-9A-F]{3,4}|[0-9A-F]{6}|[0-9A-F]{8})\\b", options: NSStringCompareOptions.RegularExpressionSearch)
        if validRange == nil {
            print("Error: Inavlid format string: \(hexStr). Check documantation for correct formats", terminator: "")
            return nil
        }
        
        cStr = cStr.substringWithRange(validRange!)
        
        if(cStr.hasPrefix("0X")) {
            cStr = cStr.substringFromIndex(cStr.startIndex.advancedBy(2))
        } else if(cStr.hasPrefix("#")) {
            cStr = cStr.substringFromIndex(cStr.startIndex.advancedBy(1))
        }
        
        let strLen = cStr.length
        if (strLen == 3 || strLen == 4) {
            // Make it double
            var str2 = ""
            for ch in cStr.characters {
                str2 += "\(ch)\(ch)"
            }
            cStr = str2
        } else if (strLen == 6 || strLen == 8) {
            // Do nothing
        } else {
            return nil
        }
        
        let scanner = NSScanner(string: cStr)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexLongLong(&hexValue) {
            if cStr.characters.count == 8 {
                return UIColor(rgba:hexValue)
            } else {
                return UIColor(rgb:hexValue)
            }
        } else {
            print("scan hex error")
        }
        
        return nil
    }
    
    /**
    Creates a UIColor object with provided color-code. Note that, you may (or you should) provide
    color-code in hexadecimal number format i.e. `0xFF0000FF` for red.
    
    - parameter rgbaNum: 8-digit hexadecimal number representation. Two digits for each of red, green, blue and alpha component respectively.
    - returns: UIColor created from the `rgbaNum`
    */
    public convenience init(rgba rgbaNum:CUnsignedLongLong)
    {
        let red   = CGFloat((rgbaNum & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgbaNum & 0x00FF0000) >> 16) / 255.0
        let blue  = CGFloat((rgbaNum & 0x0000FF00) >> 8)  / 255.0
        let alpha = CGFloat(rgbaNum & 0x000000FF)        / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    /**
    Creates a UIColor object with provided color-code. Note that, you may (or you should) provide
    color-code in hexadecimal number format i.e. `0xFF0000` for red.
    
    - parameter rgbNum: 6-digit hexadecimal number representation. Two digits for each of red, green and blue component respectively.
    - returns: UIColor created from the `rgbNum`
    */
    public convenience init(rgb rgbNum:CUnsignedLongLong)
    {
        let red   = CGFloat((rgbNum & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbNum & 0x00FF00) >> 8)  / 255.0
        let blue  = CGFloat(rgbNum & 0x0000FF)         / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    /**
    Create a UIColor object back from the string representation of UIColor.
    
    **Note:** Does not support colorString from a colorWithPatternImage. On
    such case, it returns clear color as fallback.
    
    - parameter colorString: string representation of a UIColor
    - returns: UIColor created back from `colorString`
    */
    public convenience init(colorString cStr:String) {
        let comp = cStr.componentsSeparatedByString(" ")
        if comp.count > 0{
            switch comp[0] {
            case "UIDeviceRGBColorSpace":
                if comp.count == 5 {
                    let r = CGFloat((comp[1] as NSString).floatValue)
                    let g = CGFloat((comp[2] as NSString).floatValue)
                    let b = CGFloat((comp[3] as NSString).floatValue)
                    let a = CGFloat((comp[4] as NSString).floatValue)
                    self.init(red:r, green:g, blue:b, alpha:a)
                    return
                } else {
                    print("Bad Color format: '\(cStr)'")
                }
                
            case "UIDeviceWhiteColorSpace":
                if comp.count == 3 {
                    let w = CGFloat((comp[1] as NSString).floatValue)
                    let a = CGFloat((comp[2] as NSString).floatValue)
                    self.init(white: w, alpha: a)
                    return
                } else {
                    print("Bad Color format: '\(cStr)'")
                }
                
            default:
                print("Not a RGB or GrayScale Color: '\(cStr)'")
            }
        }
        
        // Fall back to clear color
        self.init(white:0, alpha:0)
    }
}
