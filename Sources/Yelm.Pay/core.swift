//
//  File.swift
//
//
//  Created by Michael on 22.01.2021.
//

import Foundation
import SDK_objc
import Alamofire
import SwiftyJSON
import Combine
import SwiftUI


public class Core: ObservableObject, Identifiable {
    public var id: Int = 0
    private let network = NetworkService()
    
    
    public func load_d3ds(par: String, asc: String, id: Int, completionHandlerD3DS: @escaping (_ success:Bool, _ data: HTTPURLResponse) -> Void) {
        
        var request: NSMutableURLRequest? = nil
        if let url = URL(string: asc) {
            request = NSMutableURLRequest(url: url)
        }
        request?.httpMethod = "POST"
        request?.cachePolicy = .reloadIgnoringCacheData
        var requestBody: String?
        requestBody = "MD="
        requestBody = (requestBody ?? "") + String(describing: id)
        requestBody = (requestBody ?? "") + "&PaReq="
        requestBody = (requestBody ?? "") + par
        requestBody = (requestBody ?? "") + "&TermUrl="
        requestBody = (requestBody ?? "") + POST_BACK_URL
        request?.httpBody = requestBody?.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)

        if let request = request {
            URLCache.shared.removeCachedResponse(for: request as URLRequest)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request! as URLRequest) { data, response_cp, error in
            if let http_response = response_cp as? HTTPURLResponse {
                if (http_response.statusCode == 200) || (http_response.statusCode == 201){
                    if let responce_data = response_cp, let url = response_cp?.url {
                        DispatchQueue.main.async {
                            completionHandlerD3DS(true,  responce_data as! HTTPURLResponse)
                        }
                    }
                }
            }
        }
        task.resume()
        
        completionHandlerD3DS(false, HTTPURLResponse())
        
    }
    
    public func check_response(response: TransactionResponse) {
        if (response.success) {
//            transaction done fine
            print(response.transaction?.message ?? "")
        }else {
//            some error code
            if (response.message.isEmpty){print("check_response.error");return}
            
            if (response.transaction?.par != nil && response.transaction?.asc != nil){
                if (response.transaction?.asc == ""){ return }
                
                self.load_d3ds(par: response.transaction!.par, asc: response.transaction!.asc, id: response.transaction!.id) { (load, response) in
                    if (load){
                        
                    }
                }

                
            }
        }
    }
    
    
    public func payment(card_number : String, date: String, cvv: String, merchant: String, price: Float) {
        let card = Card()
        let cryptogram = card.makeCryptogramPacket(card_number, andExpDate: date, andCVV: cvv, andMerchantPublicID: merchant)
        
//        Find any errors in cryptogram
        guard let packet = cryptogram else {
            return
        }
        
        network.auth(cardCryptogramPacket: cryptogram!, cardHolderName: "", amount: 0) { (result) in
            switch result {
                case .success(let response):
                    print("payment.network.auth.success")
                    self.check_response(response: response)
                case .failure(let error):
                    print("payment.network.auth.error: \(error.localizedDescription)")
            }
        }
        
        
        
        
    }
    
    
}
