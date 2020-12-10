//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Michael Ryan on 11/10/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
