//
//  UIImageView+Animations.swift
//  EssentialFeed
//
//  Created by Nikolay Riskov on 26.05.25.
//

import UIKit

extension UIImageView {
     func setImageAnimated(_ newImage: UIImage?) {
         image = newImage

         guard newImage != nil else { return }

         alpha = 0
         UIView.animate(withDuration: 0.25) {
             self.alpha = 1
         }
     }
 }
