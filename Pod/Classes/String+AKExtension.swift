//
//  String+AKExtension.swift
//  AKAttributeKitDemo
//
//  Created by Ashik Ahmad on 11/8/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    
    //------------------------------------------------------
    // MARK: Common Utils
    //------------------------------------------------------
    
    public var length:Int {
        get {
            // ???: What is better to use here? (countElements/utf16Count
            return self.characters.count
        }
    }
    
    public func trim()->String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    public func toUIColor()->UIColor? {
        return UIColor.colorFromString(hexString: self)
    }
    
    public func toAttributedString()->NSMutableAttributedString {
        return AKAttributeKit.parseString(self)
    }
    
    //------------------------------------------------------
    // MARK: Number Conversion
    //------------------------------------------------------
    
    func toFailSafeInt()->Int {
        if let value = Int(self.trim()) {
            return value
        } else {
            return 0
        }
    }
    
    func toFailSafeFloat()->Float {
        return (self.trim() as NSString).floatValue
    }
    
    //------------------------------------------------------
    // MARK: Range <=> NSRange
    //------------------------------------------------------
    
    public var fullRange:Range<String.Index> {
        get {
            return self.startIndex..<self.endIndex
        }
    }
    
    // Courtesy: Martin R's answer on StackOverflow
    // http://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index
    
    public func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
    
    public func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.startIndex, within: utf16view)
        let to = String.UTF16View.Index(range.endIndex, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
    }
    
    //------------------------------------------------------
    // MARK: String.Index <=> Int
    //------------------------------------------------------
    
    public func indexFromStringIndex(stringIndex:String.Index)->Int {
        let index16 = String.UTF16View.Index(stringIndex, within:utf16)
        return (utf16.startIndex.distanceTo(index16))
    }
    
    public func stringIndexFromIndex(indx:Int)->String.Index? {
        let from16 = utf16.startIndex.advancedBy(indx, limit: utf16.endIndex)
        if let from = String.Index(from16, within:self) {
            return from
        }
        return nil
    }
    
}