//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Nikolay Riskov on 28.06.25.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
