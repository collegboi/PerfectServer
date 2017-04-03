//
//  AuthenChecker.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//
import Foundation
import PerfectHTTP

public class AuthenChecker {
    
    class func checkBeaer(header: String) -> String {
        
        guard let range = header.range(of: "Bearer ") else { return "" }
        let token = header.substring(from: range.upperBound)
        return token
    }
    
    class func checkTestMode(request: HTTPRequest) -> Int {
    
        let queryParams = request.queryParams
        
        if queryParams.count > 0 {
            
            for query in queryParams {
                
                if query.0 == "testMode" {
                    
                    let test = query.1
                    
                    if test != "1"  && test != "" {
                        return 0
                    } else if test == "1" {
                        return 1
                    }
                }
            }
        }
        return 0
    }
    
    class func checkVersion(request: HTTPRequest) -> String {
        
        let queryParams = request.queryParams
        
        if queryParams.count > 0 {
            
            for query in queryParams {
                
                if query.0 == "appVersion" {
                    
                    let test = query.1
                
                    return test
                }
            }
        }
        return ""
    }

    
    class func checkBaicKey( header: String) -> Bool {

        guard let range = header.range(of: "Basic ") else { return false }
        let token = header.substring(from: range.upperBound)
        
        guard let data = Data(base64Encoded: token) else { return false }
        
        guard let decodedToken = String(data: data, encoding: .utf8),
             let _ = decodedToken.range(of: ":") else {
            return false
        }
        
        //let apiKeyID = decodedToken.substring(to: separatorRange.lowerBound)
        //let apiKeySecret = decodedToken.substring(from: separatorRange.upperBound)
        
        return true
    }
}
