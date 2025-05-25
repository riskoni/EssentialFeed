//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Nikolay Riskov on 25.05.25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
