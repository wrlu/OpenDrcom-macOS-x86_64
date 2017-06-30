//
//  ViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa
import Python

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func clickLoginButton(_ sender: Any) {
        self.login()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func login() -> Void {
        DispatchQueue.main.async {
            let resourcePath = Bundle.main.resourcePath
            let pyModulePath = resourcePath! + "Drcom_CAUC.py"
            let pyModuleObjCString:NSString = NSString.init(string: pyModulePath)
            startLogin(pyModuleObjCString.utf8String,pyModuleObjCString.utf8String)
        };
    }
}
