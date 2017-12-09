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
                    self.delegate.didLoginFailed(errorCode: -3)
                    print(error.localizedDescription)
                    return
                }
//                服务器错误，回调返回错误代码
                let data = data!
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.delegate.didLoginFailed(errorCode: -5)
                    return
                }
//                无HTTP错误，获得响应HTML
                let responseHtml = String (data: data, encoding: .ascii)!
//                查找登录成功标志，查找到回调返回成功状态
                if responseHtml.contains("v46ip=") == true {
                    self.delegate.didLoginSuccess()
                }
//                登录失败，用户名或密码错误
                else {
                    self.delegate.didLoginFailed(errorCode: -6)
                }
            })
            task.resume()
        }
    }
    
}



