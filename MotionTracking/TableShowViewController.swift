//
//  TableShowViewController.swift
//  SwingWatch
//
//  Created by Dan Anderton on 29/05/2022.
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import UIKit

class TableShowViewController: UIViewController {
    
    
    var contactIndex = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var shot: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shot.text = appDelegate.shots[contactIndex]
    }
    

}
