//
//  LogoutDelegate.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/12/17.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Foundation

protocol LogoutDelegate {
    func didLogoutSuccess() -> Void
    func didLogoutFailed(errorCode:Int, reason:String?) -> Void
}
