//
//  AKAttributeKit.swift
//  WNPopTipViewShowcase
//
//  Created by Ashik Ahmad on 11/1/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import UIKit
import Foundation

/**
AKAttributeKit is to help you to create attributed string effortlessly.
It parses predefined custom tags from within string you provide and
attribute the tagged parts with the supplied value (as tag parameter).

DEPENDENCIES:
 1. String+AKExtension.swift
 2. UIColor+AKExtension.swift

*/

class AKAttributeKit {
    
    enum AttributeType:String {
        /// Anchor/Link. Param:urlString.
        /// Ex: `<a http://google.com>`
        case a = "a"
        /// Baseline offset. Param:float
        case baseline = "baseline"
        /// BackgroundColor. Param:colorString
        /// Ex: `<bg #ffffff>` or `<bg 255|255|255>`
        case bg = "bg"
        /// Expansion. Param:float
        case ex = "ex"
        /// ForegroundColor. Param:colorString.
        /// Ex: `<fg #ffffff>` or `<fg 255|255|255>`
        case fg = "fg"
        /// Font. Param:fontName|size.
        /// Ex: `<font Arial|18>`
        case font = "font"
        /// Obliqueness. Param:float
        case i = "i"
        /// Kerning. Param:float
        case k = "k"
        /// Stroke color. Param:colorString
        case sc = "sc"
        /// Stroke width. Param:float(percent)
        case sw = "sw"
        /// Strike through. Ex: `<t 1>`
        case t = "t"
        /// Underline. Ex: `<u 1>`
        case u = "u"
        
        var attributeName:String {
            switch(self) {
            case .a       : return NSLinkAttributeName;
            case .baseline: return NSBaselineOffsetAttributeName
            case .bg      : return NSBackgroundColorAttributeName
            case .ex      : return NSExpansionAttributeName
            case .fg      : return NSForegroundColorAttributeName
            case .font    : return NSFontAttributeName
            case .i       : return NSObliquenessAttributeName
            case .k       : return NSKernAttributeName
            case .sc      : return NSStrokeColorAttributeName
            case .sw      : return NSStrokeWidthAttributeName
            case .t       : return NSStrikethroughStyleAttributeName
            case .u       : return NSUnderlineStyleAttributeName
            }
        }
        
        func valueForParams(param:String)->AnyObject? {
            switch(self) {
            case .bg, .fg, .sc:
                return AKAttributeKit.colorFromString(param)
            case .u, .t:
                return param.toFailSafeInt()
            case .baseline, .ex, .i, .k, .sw:
                return param.toFailSafeFloat()
            case .font:
                return AKAttributeKit.fontFromString(param)
            case .a:
                return NSURL(string: param)
            default:
                return nil
            }
        }
    }
    
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
                if let _ = AttributeType(rawValue: tag) {
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
                if let attrType = AttributeType(rawValue: attrTag.tag) {
                    if let value: AnyObject = attrType.valueForParams(attrTag.params) {
                        var rangeNS = NSMakeRange(attrTag.location, attrTag.length)
                        attrStr.addAttribute(attrType.attributeName, value: value, range: rangeNS)
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
