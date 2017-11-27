//
//  LoginServiceProvider.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/9/27.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class LoginServiceProvider: NSObject{
    
    private var delegate:LoginDelegate
    private var timeout:Int = 0
    
    init(delegate:LoginDelegate) {
        self.delegate = delegate
        super.init()
    }
    /// 登录方法
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - passwd: 密码
    func login(user:String,passwd:String) {
        if user == "" {
            self.delegate.didLoginFailed(errorCode: -1)
        }
        if passwd == "" {
            self.delegate.didLoginFailed(errorCode: -2)
        }
        //        异步进行登录
        DispatchQueue.global().async {
            Thread.current.name = "WebLogin"
            
        };
    }
    
}
