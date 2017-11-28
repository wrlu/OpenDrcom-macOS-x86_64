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
    func login(user:String, passwd:String) {
        if user == "" {
            self.delegate.didLoginFailed(errorCode: -1)
        }
        if passwd == "" {
            self.delegate.didLoginFailed(errorCode: -2)
        }
        //        异步进行登录
        DispatchQueue.global().async {
            Thread.current.name = "WebLogin"
            let url = URL.init(string: "http://192.168.100.200/a70.htm")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameter = "DDDDD=\(user)&upass=\(passwd)&R1=0&R3=0&R6=0&MKKey=123456"
            let encodePara = parameter.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            request.httpBody = encodePara.data(using: .ascii)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    self.delegate.didLoginFailed(errorCode: -3)
                    print(error.localizedDescription)
                    return
                }
                let data = data!
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.delegate.didLoginFailed(errorCode: -5)
                    return
                }
                let responseHtml = String (data: data, encoding: .ascii)!
                if responseHtml.contains("v46ip=") == true {
                    self.delegate.didLoginSuccess()
                }
                else {
                    self.delegate.didLoginFailed(errorCode: -6)
                }
            })
            task.resume()
        }
    }
    
}



