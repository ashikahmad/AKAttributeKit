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

public class AKAttributeKit {
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
        
        var name:String {
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
        
        func valueForParams(_ param:String)->AnyObject? {
            switch(self) {
            case .bg, .fg, .sc:
                return AKAttributeKit.colorFromString(param)
            case .u, .t: // Defaults to 1
                return (Int(param) ?? 1) as AnyObject?
            case .baseline, .ex, .i, .k, .sw:
                return param.toFailSafeFloat() as AnyObject?
            case .font:
                return AKAttributeKit.fontFromString(param)
            case .a:
                return URL(string: param) as AnyObject?
                //default:
                //  return nil
            }
        }
    }
    
    class AKAttributeTag {
        let wholeTag: String
        var range: NSRange
        
        private(set) var isOpeningTag: Bool = false
        private(set) var name: String = ""
        private(set) var paramString: String?
        
        // Should only be set to opening tags
        var endingTagIndex: Int?
        
        private func processWholeTag() {
            isOpeningTag = !wholeTag.hasPrefix("</")
            
            let strippedTag = wholeTag.removing(prefix: isOpeningTag ? "<":"</").removing(suffix: ">").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            name = strippedTag.components(separatedBy: CharacterSet.whitespacesAndNewlines).first ?? ""
            if isOpeningTag {
                paramString = strippedTag.removing(prefix: name).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if paramString?.length == 0 { paramString = nil }
            }
        }
        
        init(wholeTag: String, range: NSRange) {
            self.wholeTag = wholeTag
            self.range = range
            processWholeTag()
        }
    }
    
    public class func parseString(_ str:String)->NSMutableAttributedString {
        let tagRegex = "</?[a-zA-Z][^<>]*>"
        var tagQueue:[AKAttributeTag] = []
        var attrStr = NSMutableAttributedString(string: str)
        
        if let regex = try? NSRegularExpression(pattern: tagRegex, options: .dotMatchesLineSeparators) {
            let matches = regex.matches(in: str, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: (str as NSString).length))
            
            // Map all tags
            for match in matches {
                let wholeTag = (str as NSString).substring(with: match.range)
                let tag = AKAttributeTag(wholeTag: wholeTag, range: match.range)
                if tag.isOpeningTag {
                    tagQueue.append(tag)
                } else {
                    for index in (0..<tagQueue.count).reversed() {
                        let openTag = tagQueue[index]
                        if !openTag.isOpeningTag { continue }
                        if openTag.endingTagIndex != nil { continue }
                        if tag.name == openTag.name {
                            openTag.endingTagIndex = tagQueue.count
                            break
                        }
                    }
                    tagQueue.append(tag)
                }
            }
            
            func removeTag(index: Int) {
                let tag = tagQueue[index]
                attrStr.replaceCharacters(in: tag.range, with: NSAttributedString())
                let nextIndex = index+1
                if nextIndex < tagQueue.count {
                    for tIndex in nextIndex..<tagQueue.count {
                        tagQueue[tIndex].range.location -= tag.range.length
                    }
                }
            }
            
            // Apply all tags starting from outside
            for index in 0..<tagQueue.count {
                let tag = tagQueue[index]
                if tag.isOpeningTag {
                    guard let attribute = AttributeType(rawValue: tag.name) else { continue }
                    
                    removeTag(index: index)
                    if let closeIndex = tag.endingTagIndex {
                        guard closeIndex < tagQueue.count else { continue }
                        let closingTag = tagQueue[closeIndex]
                        removeTag(index: closeIndex)
                        
                        let attrName:String = attribute.name
                        let attrValue:Any? = attribute.valueForParams(tag.paramString ?? "")
                        
                        if let attrValue = attrValue {
                            let location = tag.range.location
                            let length = closingTag.range.location-location
                            
                            attrStr.addAttribute(attrName, value: attrValue, range: NSRange(location: location, length: length))
                        }
                    }
                }
                
            }
        }
        
        return attrStr
    }
}

extension AKAttributeKit {
    
    //---------------------------------------------------
    // MARK: - Color Utils
    //---------------------------------------------------
    
    fileprivate class func colorFromString(_ colorStr:String)->UIColor?
    {
        var components = colorStr.components(separatedBy: "|");
        if components.count >= 3 {
            let r = self.toColorPart(components[0])
            let g = self.toColorPart(components[1])
            let b = self.toColorPart(components[2])
            let a = components.count >= 4 ? self.toColorPart(components[3]) : 1
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else if components.count == 1 {
            return try? UIColor(hexString: components[0])
        }
        return nil
    }
    
    fileprivate class func toColorPart(_ strValue:String)->CGFloat
    {
        let value = strValue.toFailSafeInt()
        var fVal:Float = Float(value)
        fVal /= 255.0
        return CGFloat(fVal);
    }
    
    //---------------------------------------------------
    // MARK: - Font Utils
    //---------------------------------------------------
    
    fileprivate class func fontFromString(_ fontStr:String)->UIFont?
    {
        var components = fontStr.components(separatedBy: "|");
        if components.count >= 2 {
            let fontName = components[0].trim()
            let fontSize = components[1].toFailSafeInt()
            if let font = UIFont(name: fontName, size: CGFloat(fontSize)) {
                return font
            }
        }
        return nil;
    }
}
