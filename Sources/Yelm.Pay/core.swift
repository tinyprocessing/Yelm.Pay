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
    
    func payment(card_number : String, date: String, cvv: String, merchant: String, price: Float) {
        let card = Card()
        let cryptogram = card.makeCryptogramPacket(card_number, andExpDate: date, andCVV: cvv, andMerchantPublicID: merchant)
        
//        Find any errors in cryptogram
        guard let packet = cryptogram else {
            return
        }
        
        
    }
    
    
}
