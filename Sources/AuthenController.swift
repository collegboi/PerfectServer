//
//  File.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//

import Turnstile
import TurnstileCrypto

public class AuthenticationController {
    
    static func tryLoginWith(_ username: String, password: String ) -> Bool {
        
        let encryptedPassword = BCrypt.hash(password: password)
        
        return DatabaseController.checkIfExist("Users", objects: ["username":username, "password": encryptedPassword])
    }
    
    static func tryRegister(_ jsonStr: String ) -> String {
        
        var registerObjects = JSONController.parseJSONToDict(jsonStr)
        
        guard let username = registerObjects["username"] as? String else {
            return "mssing username"
        }
        
        guard let password = registerObjects["password"] as? String else {
            return "missing password"
        }
        
        registerObjects["password"] = BCrypt.hash(password: password)
        
        if DatabaseController.checkIfExist("Users", objects: ["username": username]) {
            return "usernmae already exist"
        }
        
        let registerStr = JSONController.parseJSONToStr(dict: registerObjects)
        
        return DatabaseController.insertDocument("Users", jsonStr: registerStr )
    }
}