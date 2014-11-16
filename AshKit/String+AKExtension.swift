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
    
    func toAttributedString()->NSMutableAttributedString {
        return AKAttributeKit.parseString(self)
    }
}