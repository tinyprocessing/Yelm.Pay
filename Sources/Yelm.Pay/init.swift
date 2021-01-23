// Server File.swift - contains object class to work with server pay




import Alamofire
import SwiftyJSON
import Combine
import SwiftUI
import Foundation



public let YelmPay: Pay = Pay()

open class Pay: ObservableObject, Identifiable {
    public var id: Int = 0
    public var settings : Settings =  Settings()
    public var core : Core =  Core()
    public var apple_pay : ApplePay = ApplePay()
    
    
    public func start(platform : String, auth: String, d3ds : String, charge : String, payment_url : String, completionHandlerStart: @escaping (_ success:Bool) -> Void){
        self.settings.platform = platform
        self.settings.auth = auth
        self.settings.charge = charge
        self.settings.d3ds = d3ds
        self.settings.payment_url = payment_url
        
        DispatchQueue.main.async {
            completionHandlerStart(true)
        }
        
        
    }
}
