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
import PassKit

public class Core: ObservableObject, Identifiable {
    public var id: Int = 0
    private let network = NetworkService()

    
    public func load_d3ds(par: String, asc: String, id: Int, completionHandlerD3DS: @escaping (_ success:Bool, _ response: HTTPURLResponse, _ data:Data) -> Void) {
        
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
                    if let responce_data = response_cp, let _ = response_cp?.url {
                        DispatchQueue.main.async {
                            completionHandlerD3DS(true,  responce_data as! HTTPURLResponse, data!)
                        }
                    }
                }
            }
        }
        task.resume()
        
        completionHandlerD3DS(false, HTTPURLResponse(), Data())
        
    }
    
    public func check_response(response: TransactionResponse, completionHandlerCheck: @escaping (_ success:Bool, _ response: HTTPURLResponse, _ data:Data) -> Void) {
        if (response.success) {
//            transaction done fine
            print(response.transaction?.message ?? "")
        }else {
//            some error code
            if (!response.message.isEmpty){print("check_response.error");return}
            
            if (response.transaction?.par != nil && response.transaction?.asc != nil){
                if (response.transaction?.asc == ""){ return }
                
                self.load_d3ds(par: response.transaction!.par, asc: response.transaction!.asc, id: response.transaction!.id) { (load, response, data)  in
                    if (load){
                        DispatchQueue.main.async {
                            completionHandlerCheck(true, response, data)
                        }
                    }
                }

                
            }
        }
    }
    
    public func check_3d3s(id: String, res: String, completionHandlerCheck: @escaping (_ success:Bool, _ message:String) -> Void){
        self.network.post3ds(transactionId: id, paRes: res) { (result) in
            switch result {
                case .success(let transaction):
                    print("check_3d3s.post3ds.transaction")
                    if (transaction.success){
                        print("check_3d3s.post3ds.transaction.success")
                        DispatchQueue.main.async {
                            completionHandlerCheck(true, transaction.transaction!.message)
                        }
                    }
                    
                    if (!transaction.success){
                        print("check_3d3s.post3ds.transaction.fail")
                        DispatchQueue.main.async {
                            completionHandlerCheck(false, transaction.transaction!.message)
                        }
                    }
                    
            case .failure(let error):
                    print("check_3d3s.post3ds.error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completionHandlerCheck(false, "ошибка")
                    }

            
            }
        }
    }
    
    
    public func payment(card_number : String, date: String, cvv: String, merchant: String, price: Float, completionHandlerPayment: @escaping (_ success:Bool, _ response: HTTPURLResponse, _ data:Data) -> Void) {
        let card = Card()
        let cryptogram = card.makeCryptogramPacket(card_number, andExpDate: date, andCVV: cvv, andMerchantPublicID: merchant)
        
//        Find any errors in cryptogram
        guard cryptogram != nil else {
            completionHandlerPayment(false, HTTPURLResponse(), Data())
            return
        }
        
        network.auth(cardCryptogramPacket: cryptogram!, cardHolderName: "", amount: price) { (result) in
            switch result {
                case .success(let response):
                    print("payment.network.auth.success")
                    self.check_response(response: response) { (load, response, data) in
                        if (load){
                            DispatchQueue.main.async {
                                completionHandlerPayment(true, response, data)
                            }
                        }
                    }
                case .failure(let error):
                    print("payment.network.auth.error: \(error.localizedDescription)")
                    completionHandlerPayment(false, HTTPURLResponse(), Data())

            }
        }
        
        
        
        
    }
    

    
    
}


public class ApplePay : NSObject, D3DSDelegate{
    public var id: Int = 0
    private let network = NetworkService()
    public var price : Float = 0
    
    static let support: [PKPaymentNetwork] = [
        .amex,
        .masterCard,
        .visa
    ]
    
    public func authorizationCompleted(withMD md: String!, andPares paRes: String!) {
        
    }
    
    public func authorizationFailed(withHtml html: String!) {
        
    }
    
    
    
    
    public func apple_pay(price: Float, delivery: Float, merchant: String, country: String, currency: String, completionHandlerApplePay: @escaping (_ success:Bool) -> Void){
        
        var items: [PKPaymentSummaryItem] = []
        items.append(PKPaymentSummaryItem(label: "Сумма", amount: NSDecimalNumber(value: price), type: .final))
        items.append(PKPaymentSummaryItem(label: "Доставка", amount: NSDecimalNumber(value: delivery), type: .final))
        items.append(PKPaymentSummaryItem(label: "Всего", amount: NSDecimalNumber(value: price+delivery), type: .final))
        
        self.price = price+delivery
        
        let payment = PKPaymentRequest()
        payment.paymentSummaryItems = items
        payment.merchantIdentifier = merchant
        payment.merchantCapabilities = .capability3DS
        payment.countryCode = country
        payment.currencyCode = currency
        payment.supportedNetworks = ApplePay.support

        let controller: PKPaymentAuthorizationController = PKPaymentAuthorizationController(paymentRequest: payment)
        controller.delegate = self
        controller.present { (success) in
            if (success){
                DispatchQueue.main.async {
                    completionHandlerApplePay(true)
                }
            }
            
            if (!success){
                DispatchQueue.main.async {
                    completionHandlerApplePay(false)
                }
            }
        }

        
    }
    
    func start_payment(cryptogram: String,  completionHandlerPayment: @escaping (_ success:Bool) -> Void) {
        network.auth(cardCryptogramPacket: cryptogram, cardHolderName: "", amount: self.price) { (result) in
            switch result {
                case .success(let response):
                    print("payment.network.auth.success")
                    YelmPay.core.check_response(response: response) { (load, response, data)  in
                        if (load){
                            DispatchQueue.main.async {
                                completionHandlerPayment(true)
                            }
                        }
                    }
                case .failure(let error):
                    print("payment.network.auth.error: \(error.localizedDescription)")
                    completionHandlerPayment(false)

            }
        }
    }
    
    
}


extension ApplePay: PKPaymentAuthorizationControllerDelegate{
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                               didAuthorizePayment payment: PKPayment,
                                               handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        guard let cryptogram = PKPaymentConverter.convert(toString: payment) else {
            completion(.init(status: .failure, errors: nil))
            return
        }
        
        start_payment(cryptogram: cryptogram) { (success) in
            if (success){
                completion(.init(status: .success, errors: nil))
                return
            }
            
            if (!success){
                completion(.init(status: .failure, errors: nil))
                return
            }
        }
        
    }
    
    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        
       
        
    }
    
}
