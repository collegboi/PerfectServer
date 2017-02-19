//
//  File.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//

import TurnstileCrypto

public class AuthenticationController {
    
    static func tryLoginWith(_ apkey: String, _ username: String, password: String ) -> Bool {
        
        let encryptedPassword = BCrypt.hash(password: password)
        
        return DatabaseController.checkIfExist(apkey, "Users", objects: ["username":username, "password": encryptedPassword])
    }
    
    static func tryRegister(_ apkey: String, _ jsonStr: String ) -> String {
        
        var registerObjects = JSONController.parseJSONToDict(jsonStr)
        
        guard let username = registerObjects["username"] as? String else {
            return "mssing username"
        }
        
        guard let password = registerObjects["password"] as? String else {
            return "missing password"
        }
        
        registerObjects["password"] = BCrypt.hash(password: password)
        
        if DatabaseController.checkIfExist(apkey, "Users", objects: ["username": username]) {
            return "usernmae already exist"
        }
        
        let registerStr = JSONController.parseJSONToStr(dict: registerObjects)
        
        return DatabaseController.insertDocument(apkey, "Users", jsonStr: registerStr )
    }
}
