//
//  AKAttributeKit.swift
//  WNPopTipViewShowcase
//
//  Created by Ashik Ahmad on 11/1/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import UIKit
import Foundation

let AKAttributeTags = [
    "bg"    :NSBackgroundColorAttributeName,
    "fg"    :NSForegroundColorAttributeName,
    "font"  :NSFontAttributeName,
    "s"     :NSStrikethroughStyleAttributeName,
    "u"     :NSUnderlineStyleAttributeName
];

class AKAttributeKit {
    
    struct AttributeTag {
        var tag:String
        var params:String
        var location:Int
        var length:Int = -1
        
        init(tag t:String, params p:String, location l:Int) {
            tag = t; params = p; location = l;
            length = -1;
        }
        
        func isOpen()->Bool { return  length < 0 }
        func isEmpty()->Bool { return length <= 0 }
    }
    
    // Another approach to support inner tag of same type and partial inner tag
    class func parseStringFlat(str:String)->NSMutableAttributedString
    {
        var tags:[AttributeTag] = []
        let tagRegex = "</?[a-zA-Z][^<>]*>"
        let regexOpt = NSStringCompareOptions.RegularExpressionSearch
        var formatingStr = str;
        var searchRange = formatingStr.fullRange()
        
        // Parse tags
        while let tagRange = formatingStr.rangeOfString(tagRegex, options: regexOpt, range: searchRange) {
            var wholeTag = formatingStr.substringWithRange(tagRange)
            var validTag = false
            if wholeTag.hasPrefix("</") { // Closing Tag
                let tag = wholeTag.substringWithRange(advance(wholeTag.startIndex, 2)..<wholeTag.endIndex.predecessor())
                if let tagIndex = self.indexOfLatestOpenTag(ofType: tag, inQeue: tags) {
                    let tagStart = advance(formatingStr.startIndex, tags[tagIndex].location)
                    tags[tagIndex].length = distance(tagStart, tagRange.startIndex)
                    validTag = true
                }
            } else { // Starting Tag
                let tagWithParams = wholeTag.substringWithRange(wholeTag.startIndex.successor()..<wholeTag.endIndex.predecessor())
                let tag = tagWithParams.componentsSeparatedByString(" ")[0]
                if let _ = AKAttributeTags[tag] {
                    if let tagNameRange = tagWithParams.rangeOfString(tag) {
                        let params = tagWithParams.stringByReplacingCharactersInRange(tagNameRange, withString: "").trim()
                        var attrTag = AttributeTag(tag: tag, params: params, location: distance(formatingStr.startIndex, tagRange.startIndex))
                        tags.append(attrTag)
                        validTag = true
                    }
                }
            }
            
            if validTag {
                let currentDistance = distance(formatingStr.startIndex, searchRange.startIndex)
                formatingStr.removeRange(tagRange)
                searchRange = advance(formatingStr.startIndex, currentDistance)..<formatingStr.endIndex
            } else {
                searchRange.startIndex = tagRange.endIndex
            }
        }
        
        // Add attributes
        var attrStr = NSMutableAttributedString(string: formatingStr)
        for index in 0..<tags.count {
            let attrTag = tags[index]
            if !attrTag.isEmpty() {
                if let attrKey = AKAttributeTags[attrTag.tag] {
                    if let value: AnyObject = valueForAttribute(attrKey, params: attrTag.params) {
                        var rangeNS = NSMakeRange(attrTag.location, attrTag.length)
                        attrStr.addAttribute(attrKey, value: value, range: rangeNS)
                    }
                }
            }
        }
        
        return attrStr
    }
    
    private class func indexOfLatestOpenTag(ofType type:String, inQeue qeue:[AttributeTag])->Int?
    {
        for index in reverse(0..<qeue.count){
            var attrTag = qeue[index]
            if(attrTag.isOpen() && attrTag.tag == type) {
                return index;
            }
        }
        return nil
    }
    
    class func parseString(str:String)->NSMutableAttributedString
    {
        let attrStr = NSMutableAttributedString();
        var currentLocation = str.startIndex;
        var searchRange = str.fullRange()
        
        // 1. Have a tag?
        while let tagRange = str.rangeOfString("<[a-zA-Z][^<>]*>", options: NSStringCompareOptions.RegularExpressionSearch, range:searchRange)
        {
            // 2. Get the Tag
            var wholeTag = str.substringWithRange(tagRange)
            wholeTag = wholeTag.substringWithRange(wholeTag.startIndex.successor()..<wholeTag.endIndex.predecessor())
            var tag = wholeTag.componentsSeparatedByString(" ").first!
            // If this tag is supported
            if let attribute = AKAttributeTags[tag] {
                // ..and have a successive closing tag
                if let endTagRange = str.rangeOfString("</\(tag)>", options: NSStringCompareOptions.CaseInsensitiveSearch, range: tagRange.endIndex..<str.endIndex) {
                    // Add any text not added before this tag
                    let strBefore = str.substringWithRange(currentLocation..<tagRange.startIndex)
                    if strBefore.length > 0 {
                        attrStr.appendAttributedString(NSAttributedString(string: strBefore));
                    }
                    // Add this tagged string with proper attribute
                    var taggedStr = str.substringWithRange(tagRange.endIndex..<endTagRange.startIndex)
                    if taggedStr.length > 0 {
                        let tagParam = wholeTag.stringByReplacingCharactersInRange(wholeTag.rangeOfString(tag)!, withString: "")
                        let attrTaggedStr = self.parseString(taggedStr);
                        if let value: AnyObject = self.valueForAttribute(attribute, params: tagParam) {
                            attrTaggedStr.addAttribute(attribute, value: value, range: NSMakeRange(0, attrTaggedStr.string.length))
                        }
                        attrStr.appendAttributedString(attrTaggedStr);
                    }
                    // advance to ending tag for next iteration
                    currentLocation = endTagRange.endIndex
                    searchRange.startIndex = endTagRange.endIndex
                    continue
                }
            }
            // advance to end of this tag to ignore it on next iteration
            searchRange.startIndex = tagRange.endIndex
        }
        // Add any untagged trail is available
        let strBefore = str.substringWithRange(currentLocation..<str.endIndex)
        if strBefore.length > 0 {
            attrStr.appendAttributedString(NSAttributedString(string: strBefore));
        }
        
        return attrStr;
    }
    
    private class func valueForAttribute(attrName:String, params param:String)->AnyObject?
    {
        switch(attrName)
        {
            case NSBackgroundColorAttributeName, NSForegroundColorAttributeName:
                return self.colorFromString(param)
            case NSUnderlineStyleAttributeName, NSStrikethroughStyleAttributeName:
                return param.toFailSafeInt()
            case NSFontAttributeName:
                return self.fontFromString(param)
            default:
                return nil
        }
    }
    
    private class func fontFromString(fontStr:String)->UIFont?
    {
        var components = fontStr.componentsSeparatedByString("|");
        if components.count >= 2 {
            var fontName = components[0].trim()
            var fontSize = components[1].toFailSafeInt()
            if let font = UIFont(name: fontName, size: CGFloat(fontSize)) {
                return font
            }
        }
        return nil;
    }
    
    private class func colorFromString(colorStr:String)->UIColor?
    {
        var components = colorStr.componentsSeparatedByString("|");
        if components.count >= 3 {
            var r = self.toColorPart(components[0])
            var g = self.toColorPart(components[1])
            var b = self.toColorPart(components[2])
            var a = components.count >= 4 ? self.toColorPart(components[3]) : 1
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else if components.count == 1 {
            return UIColor.colorFromString(hexString: components[0])
        }
        return nil
    }
    
    private class func toColorPart(strValue:String)->CGFloat
    {
        var value = strValue.toFailSafeInt()
        var fVal:Float = Float(value)
        fVal /= 255.0
        return CGFloat(fVal);
    }
}

extension String {
    var length:Int {
        get {
            return countElements(self)
        }
    }
    
    func trim()->String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func toFailSafeInt()->Int {
        if let value = self.trim().toInt() {
            return value
        } else {
            return 0
        }
    }
    
    func fullRange()->Range<String.Index> {
        return self.startIndex..<self.endIndex
    }
    
    func toUIColor()->UIColor? {
        return UIColor.colorFromString(hexString: self)
    }
}

extension UIColor {
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
    
    convenience init(rgba rgbaNum:CUnsignedLongLong)
    {
        var red   = CGFloat((rgbaNum & 0xFF000000) >> 24) / 255.0
        var green = CGFloat((rgbaNum & 0x00FF0000) >> 16) / 255.0
        var blue  = CGFloat((rgbaNum & 0x0000FF00) >> 8)  / 255.0
        var alpha = CGFloat(rgbaNum & 0x000000FF)        / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    convenience init(rgb rgbNum:CUnsignedLongLong)
    {
        var red   = CGFloat((rgbNum & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((rgbNum & 0x00FF00) >> 8)  / 255.0
        var blue  = CGFloat(rgbNum & 0x0000FF)         / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}