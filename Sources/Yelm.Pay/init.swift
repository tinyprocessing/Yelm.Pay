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
    
    
    public func start(platform : String, position : String, completionHandlerStart: @escaping (_ success:Bool) -> Void){
        self.settings.platform = platform
        self.settings.position = position
        
        DispatchQueue.main.async {
            completionHandlerStart(true)
        }
        
        
    }
}
