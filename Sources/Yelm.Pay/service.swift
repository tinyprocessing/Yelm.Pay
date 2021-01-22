//
//  File.swift
//  
//
//  Created by Michael on 22.01.2021.
//

import Foundation
import Alamofire
import ObjectMapper

public class TransactionResponse: Mappable {
    
    private(set) var success = Bool()
    
    private(set) var message = String()
    
    private(set) var transaction: Transaction?
    
    required public init?(map: Map) {
        
    }
    
    // Mappables
    public func mapping(map: Map) {
        success     <- map["Success"]
        message     <- map["Message"]
        transaction <- map["Model"]
    }
}


enum HTTPResource: URLConvertible {
    
    private static let baseURLString = "https://api.yelm.io/payments/"
    
    case charge
    case auth
    case post3ds
    
    func asURL() throws -> URL {
        guard let baseURL = URL(string: HTTPResource.baseURLString) else {
            throw AFError.invalidURL(url: HTTPResource.baseURLString)
        }
        
        switch self {
        case .charge:
            let url_new = baseURL.absoluteString + "cp_charge.php?platform=\(YelmPay.settings.platform)"
            return URL(string: url_new)!
        case .auth:
            
            let url_new = baseURL.absoluteString + "cp_auth.php?platform=\(YelmPay.settings.platform)"
            return URL(string: url_new)!

        case .post3ds:
            
            let url_new = baseURL.absoluteString + "cp_post3ds.php?platform=\(YelmPay.settings.platform)"
            return URL(string: url_new)!
            
            
        }
    }
}


public class NetworkService {
    
    private let sessionManager: Session
    
    init(sessionManager: Session = Session.default) {
        self.sessionManager = sessionManager
    }
}


extension NetworkService {
    
    func makeObjectRequest<T: BaseMappable>(_ request: HTTPRequest, completion: @escaping (AFResult<T>) -> Void) {
        validatedDataRequest(from: request).responseObject(keyPath: request.mappingKeyPath) { completion($0.result) }
    }
    
    func makeArrayRequest<T: BaseMappable>(_ request: HTTPRequest, completion: @escaping (AFResult<[T]>) -> Void) {
        validatedDataRequest(from: request).responseArray(keyPath: request.mappingKeyPath) { completion($0.result) }
    }
}

private extension NetworkService {
    
    func validatedDataRequest(from httpRequest: HTTPRequest) -> DataRequest {
        
        return sessionManager
            .request(httpRequest.resource,
                     method: httpRequest.method,
                     parameters: httpRequest.parameters,
                     encoding: JSONEncoding.default,
                     headers: httpRequest.headers)
            .validate()
    }
}

extension NetworkService {
    
    

    
    func charge(cardCryptogramPacket: String, cardHolderName: String, amount: Int, completion: @escaping (AFResult<TransactionResponse>) -> Void) {
        
        // Параметры:
        let parameters: Parameters = [
            "amount" : "\(amount)", // Сумма платежа (Обязательный)
            "currency" : "", // Валюта (Обязательный)
            "name" : cardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "card_cryptogram_packet" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
            "invoice_id" : "", // Номер счета или заказа в вашей системе (Необязательный)
            "description" : "", // Описание оплаты в свободной форме (Необязательный)
            "account_id" : "", // Идентификатор пользователя в вашей системе (Необязательный)
            "JsonData" : "" // Любые другие данные, которые будут связаны с транзакцией (Необязательный)
        ]
        
        let request = HTTPRequest(resource: .charge, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
    
    func auth(cardCryptogramPacket: String, cardHolderName: String, amount: Int, completion: @escaping (AFResult<TransactionResponse>) -> Void) {
        
        // Параметры:
        let parameters: Parameters = [
            "amount" : "\(amount)", // Сумма платежа (Обязательный)
            "currency" : "", // Валюта (Обязательный)
            "name" : cardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "card_cryptogram_packet" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
            "invoice_id" : "", // Номер счета или заказа в вашей системе (Необязательный)
            "description" : "", // Описание оплаты в свободной форме (Необязательный)
            "account_id" : "", // Идентификатор пользователя в вашей системе (Необязательный)
            "json_data" : "" // Любые другие данные, которые будут связаны с транзакцией (Необязательный)
        ]
        
        
        
        let request = HTTPRequest(resource: .auth, method: .post, parameters: parameters)
        
        print(try! request.resource.asURL().absoluteString)
        

        /*let parameters: [String: String] = [
            "amount" : "111",
            "currency" : "RUB"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        let request = HTTPRequest(resource: .auth, method: .post, parameters: [:], encoding: "myBody", headers: [:])*/
                        
        makeObjectRequest(request, completion: completion)
    }
    
    func post3ds(transactionId: String, paRes: String, completion: @escaping (AFResult<TransactionResponse>) -> Void) {
        
        let parameters: Parameters = [
            "transaction_id" : transactionId,
            "pa_res" : paRes
        ]
        
        let request = HTTPRequest(resource: .post3ds, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
}


extension String {
    static let oneStagePayment = "Одностадийная оплата"
    static let twoStagePayment = "Двухстадийная оплата"
    static let errorWord = "Ошибка"
    static let enterCardNumber = "Введите номер карты"
    static let enterCorrectCardNumber = "Введите корректный номер карты"
    static let enterExpirationDate = "Введите дату окончания действия карты в формате MM/YY"
    static let enterCardHolder = "Введите имя владельца карты"
    static let enterCVVCode = "Введите CVV код"
    static let informationWord = "Информация"
    static let errorCreatingCryptoPacket = "Ошибка при создании крипто-пакета"
}

public class Transaction: Mappable {
    
    private(set) var id = Int()
    
    private(set) var code = Int()
    
    private(set) var message = String()
    
    private(set) var par = String()
    
    private(set) var asc = String()
    
    required public init?(map: Map) {
        
    }
    
    // Mappable
    public func mapping(map: Map) {
        id       <- map["TransactionId"]
        code          <- map["ReasonCode"]
        message   <- map["CardHolderMessage"]
        par               <- map["PaReq"]
        asc              <- map["AcsUrl"]
    }
}
