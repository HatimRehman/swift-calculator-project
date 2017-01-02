//
//  SplitViewController.swift
//  Calculator
//
//  Created by Hatim Rehman on 2016-06-05.
//  Copyright © 2016 Hatim Rehman. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return YES to prevent UIKit from applying its default behavior
        return true
    }
}
