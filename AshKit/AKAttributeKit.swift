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

/**
AKAttributeKit is to help you to create attributed string effortlessly.
It parses predefined custom tags from within string you provide and
attribute the tagged parts with the supplied value (as tag parameter).

DEPENDENCIES:
 1. String+AKExtension.swift
 2. UIColor+AKExtension.swift

*/

class AKAttributeKit {
    
    struct AttributeTag {
        var tag:String
        var params:String
        var location:Int
        var length:Int = -1
        
        var isOpen:Bool { return length < 0; }
        var isEmpty:Bool { return length <= 0; }
        
        init(tag t:String, params p:String, location l:Int) {
            tag = t; params = p; location = l;
            length = -1;
        }
    }
    
    // Another approach to support inner tag of same type and partial inner tag
    class func parseString(str:String)->NSMutableAttributedString
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
            if !attrTag.isEmpty {
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
            if(attrTag.isOpen && attrTag.tag == type) {
                return index;
            }
        }
        return nil
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
