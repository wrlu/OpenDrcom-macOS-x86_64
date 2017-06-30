//
//  UsageProvider.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/7/1.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class UsageProvider: NSObject {
    static func timeUsage() -> String? {
        let usageURL = URL.init(string: "http://192.168.100.251")
        let readData:Data
        do {
            try readData = Data.init(contentsOf: usageURL!)
            let htmlCode = String.init(data: readData, encoding: String.Encoding.ascii)
            let timeRange = htmlCode?.range(of: "time='")
            let timeSubstring = htmlCode?.substring(from: (timeRange?.upperBound)!)
            
            var usageTimeString:String=""
            for perChar in (timeSubstring?.characters)! {
                if perChar >= "0" && perChar <= "9" {
                    usageTimeString.append(perChar)
                }
                else {
                    break;
                }
            }
            return usageTimeString
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    static func flowUsage() -> String? {
        let usageURL = URL.init(string: "http://192.168.100.251")
        let readData:Data
        do {
            try readData = Data.init(contentsOf: usageURL!)
            let htmlCode = String.init(data: readData, encoding: String.Encoding.ascii)
            let flowRange = htmlCode?.range(of: "';flow='")
            let flowSubstring = htmlCode?.substring(from: (flowRange?.upperBound)!)

            var usageFlowString:String=""
            for perChar in (flowSubstring?.characters)! {
                if perChar >= "0" && perChar <= "9" {
                    usageFlowString.append(perChar)
                }
                else {
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
        catch {
            print(error.localizedDescription)
            return nil
        }
        
    }

}
