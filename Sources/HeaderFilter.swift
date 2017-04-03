//
//  HeaderFilter.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 02/04/2017.
//
//
import PerfectHTTP
import SwiftString

public struct HeaderFilter: HTTPRequestFilter {
    
    public init() {
    }
    
    public func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
       
        let headerAuthen = request.header(.custom(name: "authen_key"))
        
        if headerAuthen == "123456" {
            callback(.continue(request, response))
            return
        } else {
            response.status = .unauthorized
            
            let bodyResponse = ResultBody.errorBody(value: "authentication error")
            
            response.appendBody(string: bodyResponse)
            callback(.halt(request, response))
        }
        return
    }
}
