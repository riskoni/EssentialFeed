//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Nikolay Riskov on 26.05.25.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        let cell = self.dequeueReusableCell(withIdentifier: identifier) as! T
        return cell
    }
    
}
