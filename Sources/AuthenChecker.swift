//
//  AuthenChecker.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//
import Foundation

public class AuthenChecker {
    
    class func checkBeaer(header: String) -> String {
        
        guard let range = header.range(of: "Bearer ") else { return "" }
        let token = header.substring(from: range.upperBound)
        return token
    }
    
    class func checkBaicKey( header: String) -> Bool {

        guard let range = header.range(of: "Basic ") else { return false }
        let token = header.substring(from: range.upperBound)
        
        guard let data = Data(base64Encoded: token) else { return false }
        
        guard let decodedToken = String(data: data, encoding: .utf8),
            let separatorRange = decodedToken.range(of: ":") else {
                return false
        }
        
        //let apiKeyID = decodedToken.substring(to: separatorRange.lowerBound)
        //let apiKeySecret = decodedToken.substring(from: separatorRange.upperBound)
        
        return true
    }
}
