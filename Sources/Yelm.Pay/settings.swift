//
//  File.swift
//
//
//  Created by Michael on 22.01.2021.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyJSON
import SystemConfiguration


let version : String = "3.0"


public class Settings: ObservableObject, Identifiable {
    var domain : String = "https://rest.yelm.io/api/"
    var domain_beta : String = "https://dev.yelm.io/api/mobile/"
    
    public var id: Int = 0
    public var platform : String = ""
    public var debug : Bool = true
    
    public var payment_url : String = ""
    public var auth : String = ""
    public var charge : String = ""
    public var d3ds : String = ""
    
    

    /// Get url to connect rest api
    /// - Parameter method: Method Name - example m-application
    /// - Returns: Ready string
    
    func internet() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(SCNetworkReachabilityCreateWithName(nil, "https://yelm.io")!, &flags)
        
        let reachable = flags.contains(.reachable)
        let connection = flags.contains(.connectionRequired)
        let automated = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let connection_noninteraction = automated && !flags.contains(.interventionRequired)
        
       return reachable && (!connection || connection_noninteraction)
    }
    
}
