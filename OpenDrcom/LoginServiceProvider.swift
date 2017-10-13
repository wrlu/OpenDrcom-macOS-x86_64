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
            Thread.current.name = "pylogin"
            do {
                let gatewayURL = URL.init(string: "http://192.168.100.251")
                let readData:Data
                try readData = Data.init(contentsOf: gatewayURL!)
                print(readData.count)
                let resourcePath = Bundle.main.resourcePath
//              设置Python模块路径
                let pyModulePath = "sys.path.append('"+resourcePath!+"')"
//              获得Python参数
                let param = self.getParameter(user: user, passwd: passwd)
//              开始尝试登录

                startLogin(pyModulePath,param)

//              Python模块在登录成功之后会不断发送Keep-alive包
//              因此上面的C函数不会返回
//              所以一旦上面的函数返回，则证明登录失败
                self.delegate.didLoginFailed(errorCode: -4)
            }
            catch {
                print(error.localizedDescription)
                self.delegate.didLoginFailed(errorCode: -3)
            }
        };
        
        DispatchQueue.global().async {
            let frequent:TimeInterval = 1
            let schedule = Timer.scheduledTimer(timeInterval: frequent, target: self, selector: #selector(self.timerCallback), userInfo: nil, repeats: true)
            while true {
//         试从网关获取使用量，如果获取到了证明登录成功
                if UsageProvider.timeUsage() != "" && UsageProvider.flowUsage() != "" {
                    schedule.invalidate()
                    self.timeout = 0
                    self.delegate.didLoginSuccess()
                    break
                }
                else if self.timeout >= 30 {
                    schedule.invalidate()
                    self.timeout = 0
                    self.delegate.didLoginFailed(errorCode: -5)
                    break
                }
            }
        }
    }
    
    @objc func timerCallback() {
        timeout = timeout + 1
    }
    
    /// 生成Python参数的方法
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - passwd: 密码
    /// - Returns: Python参数，格式为：用户名/*DRCOM*/密码/*DRCOM*/IP地址
    private func getParameter(user:String,passwd:String) -> String {
        var resultParam = user + "/*DRCOM*/" + passwd + "/*DRCOM*/"
        resultParam += IPAddressProvider.currentIPAddresses().first!
        print(resultParam)
        return resultParam
    }
}
