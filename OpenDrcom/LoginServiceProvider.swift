//
//  LoginServiceProvider.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/9/27.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class LoginServiceProvider: NSObject{
    
    private var loginDelegate:LoginDelegate?
    private var logoutDelegate:LogoutDelegate?
    
    init(loginDelegate:LoginDelegate?, logoutDelegate:LogoutDelegate?) {
        self.loginDelegate = loginDelegate
        self.logoutDelegate = logoutDelegate
        super.init()
    }
    /// 登录方法
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - passwd: 密码
    func login(user:String, passwd:String) {
        if user == "" {
            self.loginDelegate?.didLoginFailed(errorCode: -1, reason: nil)
            return
        }
        if passwd == "" {
            self.loginDelegate?.didLoginFailed(errorCode: -2, reason: nil)
            return
        }
//        异步进行登录
        DispatchQueue.global().async {
            Thread.current.name = "WebLogin"
//            创建登录URL
            let url = URL.init(string: "http://192.168.100.200/a70.htm")!
//            创建URL请求
            var request = URLRequest(url: url)
//            更改为POST请求方式
            request.httpMethod = "POST"
//            构造参数
            let parameter = "DDDDD=\(user)&upass=\(passwd)&R1=0&R3=0&R6=0&MKKey=123456"
//            对参数进行编码
            let encodePara = parameter.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
//            将参数写入HTTP主体
            request.httpBody = encodePara.data(using: .ascii)
//            创建任务
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//                网络相关错误，回调返回错误代码
                if let error = error {
                    self.loginDelegate?.didLoginFailed(errorCode: -3, reason: error.localizedDescription)
                    return
                }
//                服务器错误，回调返回错误代码
                let data = data!
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.loginDelegate?.didLoginFailed(errorCode: -5,reason: "HTTP Status:")
                    return
                }
//                无HTTP错误，获得响应HTML
                let responseHtml = String (data: data, encoding: .ascii)!
//                查找登录成功标志，查找到回调返回成功状态
                if responseHtml.contains("v46ip=") == true {
                    self.loginDelegate?.didLoginSuccess()
                }
//                登录失败，用户名或密码错误
                else {
                    self.loginDelegate?.didLoginFailed(errorCode: -6, reason: nil)
                }
            })
            task.resume()
        }
    }
    
    func logout() {
        DispatchQueue.global().async {
//            创建注销URL
            let url = URL.init(string: "http://192.168.100.200/F.htm")!
//            创建URL请求
            let request = URLRequest(url: url)
//            创建任务
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//                网络相关错误，回调返回错误代码
                if let error = error {
                    self.logoutDelegate?.didLogoutFailed(errorCode: -3, reason: error.localizedDescription)
                    return
                }
//                服务器错误，回调返回错误代码
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.logoutDelegate?.didLogoutFailed(errorCode: -5, reason: nil)
                    return
                }
//                注销成功
                self.logoutDelegate?.didLogoutSuccess()
            })
            task.resume()
        }
    }
    
}



