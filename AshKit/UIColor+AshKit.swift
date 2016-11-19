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
    public enum ParseError: Error {
        // "Error: Inavlid format string: \(hexStr). Check documantation for correct formats"
        case InvalidFormat
    }
    
    /**
     Converts a formatted hexadecimal color-code string into respective UIColor.
     
     :param: hexStr String in any of these formats: `rgb | rgba | rrggbb | rrggbba` with or without prefix: `0x | #`
     :returns: UIColor from the `hexStr` if it is parsed successfully, nil otherwise.
     */
    public convenience init(hexString hexStr: String) throws {
        // 1. Make uppercase to reduce conditions
        var cStr = hexStr.trim().uppercased()
        // 2. Check if valid input
        guard let validRange = cStr.range(of: "\\b(0X|#)?([0-9A-F]{3,4}|[0-9A-F]{6}|[0-9A-F]{8})\\b", options: NSString.CompareOptions.regularExpression) else {
            throw ParseError.InvalidFormat
        }
        
        cStr = cStr.substring(with: validRange)
            .removing(prefix: "0X")
            .removing(prefix: "#")
        
        var strLen = cStr.length
        if (strLen == 3 || strLen == 4) { // Make it double
            cStr = cStr.characters.reduce("") { $0 + "\($1)\($1)" }
        }
        
        strLen = cStr.length
        guard strLen == 6 || strLen == 8 else {
            throw ParseError.InvalidFormat
        }
        
        let scanner = Scanner(string: cStr)
        var hexValue: CUnsignedLongLong = 0
        guard scanner.scanHexInt64(&hexValue) else {
            throw ParseError.InvalidFormat
        }
        
        if strLen == 8 {
            self.init(rgba:hexValue)
        } else {
            self.init(rgb:hexValue)
        }
    }
    
    /**
     Creates a UIColor object with provided color-code. Note that, you may (or you should) provide
     color-code in hexadecimal number format i.e. `0xFF0000FF` for red.
     
     :param: rgbaNum 8-digit hexadecimal number representation. Two digits for each of red, green, blue and alpha component respectively.
     :returns: UIColor created from the `rgbaNum`
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
     
     :param: rgbNum 6-digit hexadecimal number representation. Two digits for each of red, green and blue component respectively.
     :returns: UIColor created from the `rgbNum`
     */
    public convenience init(rgb rgbNum:CUnsignedLongLong)
    {
        let red   = CGFloat((rgbNum & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbNum & 0x00FF00) >> 8)  / 255.0
        let blue  = CGFloat(rgbNum & 0x0000FF)         / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
