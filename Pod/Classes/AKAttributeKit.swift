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
3. UIFont+AKExtension.swift
*/

public class AKAttributeKit {
    
    /*
    Supported List of NS**AttributeName
    ------------------------------------------------------
    
    This is not part of Documentation comment. This is only for developer
    to track which is supported so far and which is not supported yet.
    
    [x] NSFontAttributeName - UIFont, default Helvetica(Neue) 12
    [ ] NSParagraphStyleAttributeName - NSParagraphStyle, default defaultParagraphStyle
    [x] NSForegroundColorAttributeName - UIColor, default blackColor
    [x] NSBackgroundColorAttributeName - UIColor, default nil: no background
    [ ] NSLigatureAttributeName - NSNumber containing integer, default 1: default ligatures, 0: no ligatures
    [x] NSKernAttributeName - NSNumber containing floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
    [x] NSStrikethroughStyleAttributeName - NSNumber containing integer, default 0: no strikethrough
    [x] NSUnderlineStyleAttributeName - NSNumber containing integer, default 0: no underline
    [x] NSStrokeColorAttributeName - UIColor, default nil: same as foreground color
    [x] NSStrokeWidthAttributeName - NSNumber containing floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
    [ ] NSShadowAttributeName - NSShadow, default nil: no shadow
    [ ] NSTextEffectAttributeName - NSString, default nil: no text effect
    [ ] NSAttachmentAttributeName - NSTextAttachment, default nil
    [x] NSLinkAttributeName - NSURL (preferred) or NSString
    [x] NSBaselineOffsetAttributeName - NSNumber containing floating point value, in points; offset from baseline, default 0
    [x] NSUnderlineColorAttributeName - UIColor, default nil: same as foreground color
    [x] NSStrikethroughColorAttributeName - UIColor, default nil: same as foreground color
    [x] NSObliquenessAttributeName - NSNumber containing floating point value; skew to be applied to glyphs, default 0: no skew
    [x] NSExpansionAttributeName - NSNumber containing floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion
    [ ] NSWritingDirectionAttributeName  - NSArray of NSNumbers representing the nested levels of writing direction overrides as defined by Unicode LRE, RLE, LRO, and RLO characters.  The control characters can be obtained by masking NSWritingDirection and NSTextWritingDirection values.  LRE: NSWritingDirectionLeftToRight|NSWritingDirectionEmbedding, RLE: NSWritingDirectionRightToLeft|NSWritingDirectionEmbedding, LRO: NSWritingDirectionLeftToRight|NSWritingDirectionOverride, RLO: NSWritingDirectionRightToLeft|NSWritingDirectionOverride,
    [ ] NSVerticalGlyphFormAttributeName - An NSNumber containing an integer value.  0 means horizontal text.  1 indicates vertical text.  If not specified, it could follow higher-level vertical orientation settings.  Currently on iOS, it's always horizontal.  The behavior for any other value is undefined.
    */
    
    /**
    AttributeType is basically the tags which represents a NS*AttributeName with short suitable name.
    See every tag for specific details.
    
    Every tag takes a param of any of the following types. In some cases, param can be omitted which
    is indicated as `Optional` beside param-type.
    
    **Param Types**
    
    - ### Int
      Any integer value supported by respective attribute
    - ### Float
      Any float value
    - ### Color
      1. **Hex formats:** `rgb`, `rgba`, `rrggbb`, `rrggbbaa` with or without `0x` or `#` prefix
      2. **Integer sequence:** `r|g|b|a` param sequence, where all params in sequence are Int ranges from 0-255.
      3. **Insert UIColor:** Directly insert UIColor into swift string like `<tag \(myColor)>` where myColor is any UIColor other than `colorWithPatternImage`.
    - ### Font
      1. **Param sequence:** `fontName|fontSize` param sequence where fontName is String and fontSize is Float
      2. **Insert UIFont:** Directly insert UIFont into swift string like `<font \(myFont.asAKAttribute())>`
    - ### Link
      String of any valid URL format
    */
    public enum AttributeType:String {
        /// #### Anchor/Link.
        /// Param: Link
        /// Ex: `<a http://google.com>`
        case a = "a"
        /// #### Baseline offset
        /// Param: Float
        case base = "base"
        /// #### BackgroundColor
        /// Param: Color
        /// Ex: `<bg #ffffff>` or `<bg 255|255|255>`
        case bg = "bg"
        /// #### Expansion
        /// Param: Float
        case ex = "ex"
        /// #### ForegroundColor
        /// Param: Color
        /// Ex: `<fg #ffffff>` or `<fg 255|255|255>`
        case fg = "fg"
        /// #### Font
        /// Param: Font (fontName|fontSize)
        /// Ex: `<font Arial|18>`
        case font = "font"
        /// #### Obliqueness
        /// Param: Float
        case i = "i"
        /// #### Kerning
        /// Param: Float
        case k = "k"
        /// #### Stroke color
        /// Param: Color
        case sc = "sc"
        /// #### Stroke width
        /// Param: Float (percent)
        case sw = "sw"
        /// #### Strike through
        /// Param: Int (Optional)
        /// Ex: `<t>` or `<t 1>`
        case t = "t"
        /// #### Strike through color
        /// Param: Color
        /// Ex: `<tc #f00>`
        case tc = "tc"
        /// #### Underline
        /// Param: Int (Optional)
        /// Ex: `<u>` or `<u \(NSUnderlineStyle.StyleDouble.rawValue | NSUnderlineStyle.PatternDot.rawValue)>`
        case u = "u"
        /// #### Underline color
        /// Param: Color
        /// Ex: `<uc #f00>`
        case uc = "uc"
        
        var attributeName:String {
            switch(self) {
            case .a    : return NSLinkAttributeName
            case .base : return NSBaselineOffsetAttributeName
            case .bg   : return NSBackgroundColorAttributeName
            case .ex   : return NSExpansionAttributeName
            case .fg   : return NSForegroundColorAttributeName
            case .font : return NSFontAttributeName
            case .i    : return NSObliquenessAttributeName
            case .k    : return NSKernAttributeName
            case .sc   : return NSStrokeColorAttributeName
            case .sw   : return NSStrokeWidthAttributeName
            case .t    : return NSStrikethroughStyleAttributeName
            case .tc   : return NSStrikethroughColorAttributeName
            case .u    : return NSUnderlineStyleAttributeName
            case .uc   : return NSUnderlineColorAttributeName
            }
        }
        
        func valueForParams(param:String)->AnyObject? {
            switch(self) {
            case .bg, .fg, .sc, .tc, .uc:
                return AKAttributeKit.colorFromString(param)
            case .u, .t:
                return Int(param) ?? 1
            case .base, .ex, .k, .sw:
                return param.toFailSafeFloat()
            case .i:
                return Float(param) ?? 0.25
            case .font:
                return AKAttributeKit.fontFromString(param)
            case .a:
                return NSURL(string: param)
            }
        }
    }
    
    private struct AttributeTag {
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
    public class func parseString(str:String)->NSMutableAttributedString
    {
        var tags:[AttributeTag] = []
        let tagRegex = "</?[a-zA-Z][^<>]*>"
        let regexOpt = NSStringCompareOptions.RegularExpressionSearch
        var formatingStr = str;
        var searchRange = formatingStr.fullRange
        
        // Parse tags
        while let tagRange = formatingStr.rangeOfString(tagRegex, options: regexOpt, range: searchRange) {
            let wholeTag = formatingStr.substringWithRange(tagRange)
            var validTag = false
            if wholeTag.hasPrefix("</") { // Closing Tag
                let tag = wholeTag.substringWithRange(wholeTag.startIndex.advancedBy(2)..<wholeTag.endIndex.predecessor())
                if let tagIndex = self.indexOfLatestOpenTag(ofType: tag, inQeue: tags) {
                    if let openingIndex = formatingStr.stringIndexFromIndex(tags[tagIndex].location) {
                        tags[tagIndex].length = formatingStr.NSRangeFromRange(openingIndex..<tagRange.startIndex).length
                        validTag = true
                    }
                }
            } else { // Starting Tag
                let tagWithParams = wholeTag.substringWithRange(wholeTag.startIndex.successor()..<wholeTag.endIndex.predecessor())
                let tag = tagWithParams.componentsSeparatedByString(" ")[0]
                if let _ = AttributeType(rawValue: tag) {
                    if let tagNameRange = tagWithParams.rangeOfString(tag) {
                        let loc = formatingStr.indexFromStringIndex(tagRange.startIndex)
                        let params = tagWithParams.stringByReplacingCharactersInRange(tagNameRange, withString: "").trim()
                        let attrTag = AttributeTag(tag: tag, params: params, location: loc)
                        tags.append(attrTag)
                        validTag = true
                    }
                }
            }
            
            if validTag {
                let currentDistance = formatingStr.startIndex.distanceTo(searchRange.startIndex)
                formatingStr.removeRange(tagRange)
                searchRange = formatingStr.startIndex.advancedBy(currentDistance)..<formatingStr.endIndex
            } else {
                searchRange.startIndex = tagRange.endIndex
            }
        }
        
        // Add attributes
        let attrStr = NSMutableAttributedString(string: formatingStr)
        for index in 0..<tags.count {
            let attrTag = tags[index]
            if !attrTag.isEmpty {
                if let attrType = AttributeType(rawValue: attrTag.tag) {
                    if let value: AnyObject = attrType.valueForParams(attrTag.params) {
                        let rangeNS = NSMakeRange(attrTag.location, attrTag.length)
                        attrStr.addAttribute(attrType.attributeName, value: value, range: rangeNS)
                    }
                }
            }
        }
        
        return attrStr
    }
    
    private class func indexOfLatestOpenTag(ofType type:String, inQeue qeue:[AttributeTag])->Int?
    {
        for index in Array((0..<qeue.count).reverse()){
            let attrTag = qeue[index]
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
            let fontName = components[0].trim()
            let fontSize = components[1].toFailSafeFloat()
            if let font = UIFont(name: fontName, size: CGFloat(fontSize)) {
                return font
            }
        }
        return nil;
    }
    
    private class func colorFromString(colorStr:String)->UIColor?
    {
        if (colorStr as NSString).hasPrefix("UIDevice") {
            return UIColor(colorString: colorStr)
        }
        
        var components = colorStr.componentsSeparatedByString("|");
        if components.count >= 3 {
            let r = self.toColorPart(components[0])
            let g = self.toColorPart(components[1])
            let b = self.toColorPart(components[2])
            let a = components.count >= 4 ? self.toColorPart(components[3]) : 1
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else if components.count == 1 {
            return UIColor.colorFromString(hexString: components[0])
        }
        return nil
    }
    
    private class func toColorPart(strValue:String)->CGFloat
    {
        let value = strValue.toFailSafeInt()
        var fVal:Float = Float(value)
        fVal /= 255.0
        return CGFloat(fVal);
    }
}

