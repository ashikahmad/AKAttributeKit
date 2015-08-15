//
//  String+AKExtension.swift
//  AKAttributeKitDemo
//
//  Created by Ashik Ahmad on 11/8/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var length:Int {
        get {
            // ???: What is better to use here? (countElements/utf16Count
            return count(self)
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
    
    func toFailSafeFloat()->Float {
        return (self.trim() as NSString).floatValue
    }
    
    func fullRange()->Range<String.Index> {
        return self.startIndex..<self.endIndex
    }
    
    func indexFromStringIndex(stringIndex:String.Index)->Int {
        let index16 = String.UTF16View.Index(stringIndex, within:utf16)
        return (index16 - utf16.startIndex)
    }
    
    func stringIndexFromIndex(indx:Int)->String.Index? {
        let from16 = advance(utf16.startIndex, indx, utf16.endIndex)
        if let from = String.Index(from16, within:self) {
            return from
        }
        return nil
    }
    
    // Courtesy: Martin R's answer on StackOverflow
    // http://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = advance(utf16.startIndex, nsRange.location, utf16.endIndex)
        let to16 = advance(from16, nsRange.length, utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
    
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.startIndex, within: utf16view)
        let to = String.UTF16View.Index(range.endIndex, within: utf16view)
        return NSMakeRange(from - utf16view.startIndex, to - from)
    }
    
    func toUIColor()->UIColor? {
        return UIColor.colorFromString(hexString: self)
    }
    
    func toAttributedString()->NSMutableAttributedString {
        return AKAttributeKit.parseString(self)
    }
}