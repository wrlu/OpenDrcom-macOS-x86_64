//
//  SoftwareUpdateViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/12/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class SoftwareUpdateViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "CheckUpdateSegue"), sender: self)
        // Do view setup here.
    }
    
}
