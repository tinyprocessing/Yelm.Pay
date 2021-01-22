//
//  File.swift
//  
//
//  Created by Michael on 22.01.2021.
//

import Foundation
import Alamofire

struct HTTPRequest {
    
    let resource: HTTPResource
    
    let method: HTTPMethod
    
    let headers: HTTPHeaders
    
    let parameters: Parameters
    
    let mappingKeyPath: String?
    
    init(resource: HTTPResource,
         method: HTTPMethod = .post,
         headers: HTTPHeaders = [:],
         parameters: Parameters = [:],
         
         
         mappingKeyPath: String? = nil) {
        
        self.resource = resource
        
        
        self.method = method
        self.headers = headers
        self.parameters = parameters
        self.mappingKeyPath = mappingKeyPath
    }
}
