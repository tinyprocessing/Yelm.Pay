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
    
    
    public func start(platform : String,
                      auth: String = "cp_auth.php",
                      d3ds : String = "cp_post3ds.php",
                      charge : String = "cp_charge.php",
                      payment_url : String = "https://api.yelm.io/payments/",
                      completionHandlerStart: @escaping (_ success:Bool) -> Void){
        
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
