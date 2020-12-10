//
//  UIView+addBorder.swift
//  Snacktacular
//
//  Created by Michael Ryan on 11/10/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit

extension UIView {
    func addBorders(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
}
