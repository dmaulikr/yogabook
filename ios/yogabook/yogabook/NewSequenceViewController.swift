//
//  NewSequenceViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/22/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class NewSequenceViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onDone() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


