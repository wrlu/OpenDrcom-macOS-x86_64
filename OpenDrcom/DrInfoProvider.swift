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
    
    let gatewayURLString = "http://192.168.100.200"
    let publicIPURLString = "http://ip.chinaz.com/getip.aspx"
    var htmlCode:String?
    var remoteHtmlCode:String?
    
    override init() {
        super.init()
        self.searchGateway()
        self.searchPublicIPProvider()
    }
    
    func searchGateway() {
        let gatewayURL = URL.init(string: gatewayURLString)
        let readData:Data
        do {
//            尝试连接网关
            try readData = Data.init(contentsOf: gatewayURL!)
//            获取页面HTML代码，居然都不是UTF-8的，还得用ASCII，差评
            self.htmlCode = String.init(data: readData, encoding: String.Encoding.ascii)
        } catch {
//        无法连接到网关
            print(error.localizedDescription)
            self.htmlCode = nil
        }
    }
    
    func searchPublicIPProvider() {
        let publicIPURL = URL.init(string: publicIPURLString)
        let readData:Data
        do {
            try readData = Data.init(contentsOf: publicIPURL!)
            self.remoteHtmlCode = String.init(data: readData, encoding: String.Encoding.ascii)
        } catch {
            print(error.localizedDescription)
            self.remoteHtmlCode = nil
        }
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
    
    /// 获得公网IPv4地址
    ///
    /// - Returns: 公网IPv4地址
    func ipv4Public() -> String? {
        guard remoteHtmlCode != nil else {
            return nil
        }
        let ipRange = remoteHtmlCode?.range(of: "{ip:'")
        guard ipRange != nil else {
            return nil
        }
        let ipSubstring = remoteHtmlCode?[(ipRange?.upperBound)!...]
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
