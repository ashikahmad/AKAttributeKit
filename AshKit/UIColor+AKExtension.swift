//
//  UIColor+AKExtension.swift
//  AKAttributeKitDemo
//
//  Created by Ashik Ahmad on 11/8/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /**
    Converts a formatted hexadecimal color-code string into respective UIColor.
    
    :param: hexStr String in any of these formats: `rgb | rgba | rrggbb | rrggbba` with or without prefix: `0x | #`
    :returns: UIColor from the `hexStr` if it is parsed successfully, nil otherwise.
    */
    class func colorFromString(hexString hexStr: String)->UIColor?
    {
        // 1. Make uppercase co reduce conditions
        var cStr = hexStr.trim().uppercaseString;
        
        // 2. Check if valid input
        var validRange = cStr.rangeOfString("(0X|#)?[0-9A-F]+", options: NSStringCompareOptions.RegularExpressionSearch)
        if validRange == nil || cStr.fullRange() != validRange! {
            print("Error: Inavlid format string: \(hexStr). Check documantation for correct formats")
            return nil
        }
        
        if(cStr.hasPrefix("0X")) {
            cStr = cStr.substringFromIndex(advance(cStr.startIndex, 2))
        } else if(cStr.hasPrefix("#")) {
            cStr = cStr.substringFromIndex(advance(cStr.startIndex, 1))
        }
        
        var strLen = cStr.length
        if (strLen == 3 || strLen == 4) {
            // Make it double
            var str2 = ""
            for ch in cStr {
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
            if countElements(cStr) == 8 {
                return UIColor(rgba:hexValue)
            } else {
                return UIColor(rgb:hexValue)
            }
        } else {
            println("scan hex error")
        }
        
        return nil
    }
    
    /**
    Creates a UIColor object with provided color-code. Note that, you may (or you should) provide
    color-code in hexadecimal number format i.e. `0xFF0000FF` for red.
    
    :param: rgbaNum 8-digit hexadecimal number representation. Two digits for each of red, green, blue and alpha component respectively.
    :returns: UIColor created from the `rgbaNum`
    */
    convenience init(rgba rgbaNum:CUnsignedLongLong)
    {
        var red   = CGFloat((rgbaNum & 0xFF000000) >> 24) / 255.0
        var green = CGFloat((rgbaNum & 0x00FF0000) >> 16) / 255.0
        var blue  = CGFloat((rgbaNum & 0x0000FF00) >> 8)  / 255.0
        var alpha = CGFloat(rgbaNum & 0x000000FF)        / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    /**
    Creates a UIColor object with provided color-code. Note that, you may (or you should) provide
    color-code in hexadecimal number format i.e. `0xFF0000` for red.
    
    :param: rgbNum 6-digit hexadecimal number representation. Two digits for each of red, green and blue component respectively.
    :returns: UIColor created from the `rgbNum`
    */
    convenience init(rgb rgbNum:CUnsignedLongLong)
    {
        var red   = CGFloat((rgbNum & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((rgbNum & 0x00FF00) >> 8)  / 255.0
        var blue  = CGFloat(rgbNum & 0x0000FF)         / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}