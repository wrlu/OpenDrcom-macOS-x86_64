//
//  SuccessInfoViewController.swift
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

import Cocoa

class SuccessInfoViewController: NSViewController {
    @IBOutlet weak var labelUserIP: NSTextField!
    @IBOutlet weak var labelGatewayIP: NSTextField!
    @IBOutlet weak var labelUsageTime: NSTextField!
    @IBOutlet weak var labelUsageFlow: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.getUsage()
        labelUserIP.stringValue=self.getIPAddresses()[0]
    }
    
    func getUsage() {
        let usageURL = URL.init(string: "http://192.168.100.251")
        let readData:Data
        do {
            try readData = Data.init(contentsOf: usageURL!)
            let htmlCode = String.init(data: readData, encoding: String.Encoding.ascii)
            let timeRange = htmlCode?.range(of: "time='")
            let flowRange = htmlCode?.range(of: "';flow='")
            let timeSubstring = htmlCode?.substring(from: (timeRange?.upperBound)!)
            let flowSubstring = htmlCode?.substring(from: (flowRange?.upperBound)!)
            
            var usageTimeString:String=""
            for perChar in (timeSubstring?.characters)! {
                if perChar >= "0" && perChar <= "9" {
                    usageTimeString.append(perChar)
                }
                else {
                    break;
                }
            }
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
            labelUsageTime.stringValue = usageTimeString + " 分钟"
            labelUsageFlow.stringValue = usageFlowString + " MB"
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func getIPAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr;
            while ( ptr != nil ) {
                let flags = Int32((ptr?.pointee.ifa_flags)!)
                var addr = ptr?.pointee.ifa_addr.pointee
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String.init(validatingUTF8: hostname){
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses
    }
    
}
