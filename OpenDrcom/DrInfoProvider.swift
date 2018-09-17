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

/// 获得使用量的类
class DrInfoProvider: NSObject {
    let delegate:DrInfoProviderDelegate
    let gatewayURLString = "http://192.168.100.200"
    var htmlCode:String?
    var remoteHtmlCode:String?
    
    init(delegate: DrInfoProviderDelegate) {
        self.delegate = delegate
        super.init()
        self.searchGateway()
    }
    
    /// 连接到校园网网关
    func searchGateway() {
        let gatewayURL = URL.init(string: gatewayURLString)!
        var request = URLRequest(url: gatewayURL)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "accept-language")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "accept-encoding")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//           网络相关错误
            if let error = error {
                print(error.localizedDescription)
                return
            }
//           服务器错误
            guard let data = data else { return }
            let httpResponse = response as? HTTPURLResponse
            guard let status = httpResponse?.statusCode else { return }
            guard status == 200 else {
                print(status)
                return
            }
            self.htmlCode = String (data: data, encoding: .ascii)
            self.delegate.finishRefreshUsageAndIP()
        })
        task.resume()
    }
    
    /// 从网关获取使用时长
    ///
    /// - Returns: 帐号使用时长，单位是分钟
    func timeUsage() -> String? {
        guard htmlCode != nil else {
            return nil
        }
        let timeRange = htmlCode?.range(of: "time='")
        guard timeRange != nil else {
            return nil
        }
        let timeSubstring = htmlCode?[(timeRange?.upperBound)!...]
        var usageTimeString:String=""
        for perChar in timeSubstring! {
            if perChar >= "0" && perChar <= "9" {
                usageTimeString.append(perChar)
            } else {
                break;
            }
        }
        return usageTimeString
    }
    
    /// 从网关获得使用流量
    ///
    /// - Returns: 帐号使用的流量，单位是MB
    func flowUsage() -> String? {
        guard htmlCode != nil else {
            return nil
        }
        let flowRange = htmlCode?.range(of: "';flow='")
        guard flowRange != nil else {
            return nil
        }
        let flowSubstring = htmlCode?[(flowRange?.upperBound)!...]
        var usageFlowString:String=""
        for perChar in flowSubstring! {
            if perChar >= "0" && perChar <= "9" {
                usageFlowString.append(perChar)
            } else {
                break;
            }
        }
        let usageFlowInt:Int? = Int.init(usageFlowString)
        var flow0:Int = usageFlowInt! % 1024;
        let flow1:Int = usageFlowInt! - flow0;
        flow0 = flow0 * 1000;
        flow0 = flow0 - flow0 % 1024;
        usageFlowString = String.init(format: "%ld.%ld", flow1 / 1024 ,flow0 / 1024)
        return usageFlowString
    }
    
    /// 从网关获得余额
    ///
    /// - Returns: 帐号的余额，单位是CNY
    func balanceUsage() -> String? {
        guard htmlCode != nil else {
            return nil
        }
        let balanceRange = htmlCode?.range(of: "fee='")
        guard balanceRange != nil else {
            return nil
        }
        let balanceSubstring = htmlCode?[(balanceRange?.upperBound)!...]
        var usageBalanceString:String=""
        
        for perChar in balanceSubstring! {
            if perChar >= "0" && perChar <= "9" {
                usageBalanceString.append(perChar)
            } else {
                break;
            }
        }
        var usageBalanceDouble = Double.init(usageBalanceString)!
        usageBalanceDouble = usageBalanceDouble / 10000
        usageBalanceString = String.init(format: "%.2f", usageBalanceDouble);
        return usageBalanceString
    }
    
    
    /// 从网关获得本地IPv4地址
    ///
    /// - Returns: 本地IPv4地址
    func ipv4Private() -> String? {
        guard htmlCode != nil else {
            return nil
        }
        let ipRange = htmlCode?.range(of: "v4ip='")
        guard ipRange != nil else {
            return nil
        }
        let ipSubstring = htmlCode?[(ipRange?.upperBound)!...]
        var iPString:String=""
        for perChar in ipSubstring! {
            if (perChar >= "0" && perChar <= "9") || perChar == "." {
                iPString.append(perChar)
            } else {
                break;
            }
        }
        return iPString
    }
    
}
