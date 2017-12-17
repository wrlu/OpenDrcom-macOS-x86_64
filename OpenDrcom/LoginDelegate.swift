//
//  LoginDelegate.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/9/27.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Foundation

protocol LoginDelegate {
    func didLoginSuccess() -> Void
    func didLoginFailed(errorCode:Int, reason:String?) -> Void
}
