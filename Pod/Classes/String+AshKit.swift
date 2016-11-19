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
    
    var length: Int {
        return characters.count
    }
    
    func trim()->String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var fullRange: Range<String.Index> {
        return startIndex..<endIndex
    }
    
    //------------------------------------------------------
    // MARK: Number Conversion
    //------------------------------------------------------
    
    func toFailSafeInt()->Int {
        return Int(trim()) ?? 0
    }
    
    func toFailSafeFloat()->Float {
        return Float(trim()) ?? 0
    }
    
    //---------------------------------------------------
    // MARK: - Remove variatinos
    //---------------------------------------------------
    
    func removing(prefix: String)->String {
        if hasPrefix(prefix) {
            let start = index(startIndex, offsetBy: prefix.characters.count)
            return substring(from: start)
        }
        return self
    }
    
    func removing(suffix: String)->String {
        if hasSuffix(suffix) {
            let end = index(startIndex, offsetBy: characters.count-suffix.characters.count)
            return substring(to: end)
        }
        return self
    }
    
    func removing(firstOccurence str: String)-> String {
        if let range = range(of: str) {
            return replacingCharacters(in: range, with: "")
        }
        return self
    }
    
}
