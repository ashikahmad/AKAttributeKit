//
//  UIFont+AKExtension.swift
//  Pods
//
//  Created by Ashik Ahmad on 9/26/15.
//
//

import UIKit

public extension UIFont {
    public func asAKAttribute()->String {
        return "\(fontName)|\(pointSize)"
    }
}