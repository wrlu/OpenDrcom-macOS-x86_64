/**
 * Copyright (c) 2017, 小路.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 */

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
            self.loginDelegate?.didLoginFailed(reason: "请输入用户名")
            return
        }
        if passwd == "" {
            self.loginDelegate?.didLoginFailed(reason: "请输入密码")
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
//            let parameter = "DDDDD=\(user)&upass=\(passwd)&R1=0&R3=0&R6=0&MKKey=123456"
            let parameter = "0MKKey=%B5%C7+++++%C2%BC&DDDDD=\(user)&upass=\(passwd)&C1=on"
//            对参数进行编码
            let encodePara = parameter.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
//            将参数写入HTTP主体
            request.httpBody = encodePara.data(using: .ascii)
//            添加请求头
            request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
            request.addValue("http://192.168.100.200/a70.htm", forHTTPHeaderField: "Referer")
//            创建任务
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//                网络相关错误，回调返回错误代码
                if let error = error {
                    self.loginDelegate?.didLoginFailed(reason:"网络错误:"+error.localizedDescription)
                    return
                }
//                服务器错误，回调返回错误代码
                guard let data = data else { return }
                let httpResponse = response as? HTTPURLResponse
                guard let status = httpResponse?.statusCode else { return }
                guard status == 200 else {
                    self.loginDelegate?.didLoginFailed(reason: "HTTP错误,状态码:"+String.init(format: "%d", status))
                    return
                }
//                无HTTP错误，获得响应HTML
                let responseHtml = String (data: data, encoding: .ascii)!
//                查找登录成功标志，查找到回调返回成功状态
                if responseHtml.contains("v46ip=") == true {
                    self.loginDelegate?.didLoginSuccess()
                } else if responseHtml.contains("Msg=01;") == true {
//                登录失败，用户名或密码错误
                    self.loginDelegate?.didLoginFailed(reason: "用户名或密码错误")
                } else if responseHtml.contains("Msg=04;") == true {
//                登录失败，网络账号超支
                    self.loginDelegate?.didLoginFailed(reason: "本账号费用超支或时长流量超过限制")
                } else {
                    self.loginDelegate?.didLoginFailed(reason: "未知错误")
                }
            })
            task.resume()
        }
    }
    
    /// 注销方法
    func logout() {
        DispatchQueue.global().async {
//            创建注销URL
            let url = URL.init(string: "http://192.168.100.200/F.htm")!
//            创建URL请求
            var request = URLRequest(url: url)
            request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.addValue("zh-cn", forHTTPHeaderField: "Accept-Language")
            request.addValue("http://192.168.100.200", forHTTPHeaderField: "Referer")
//            创建任务
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//                网络相关错误，回调返回错误代码
                if let error = error {
                    self.logoutDelegate?.didLogoutFailed(reason:"网络错误,"+error.localizedDescription)
                    return
                }
//                服务器错误，回调返回错误代码
                let httpResponse = response as? HTTPURLResponse
                guard let status = httpResponse?.statusCode else { return }
                guard status == 200 else {
                    self.logoutDelegate?.didLogoutFailed(reason: "HTTP错误,状态码为"+String.init(format: "%d", status))
                    return
                }
//                注销成功
                self.logoutDelegate?.didLogoutSuccess()
            })
            task.resume()
        }
    }
    
}



