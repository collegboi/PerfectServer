//
//  File.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//

import TurnstileCrypto

public class AuthenticationController {
    
    static func tryLoginWith(_ apkey: String, _ username: String, password: String ) -> ( Bool, String ) {
        
        
        let ( result, strResult ) = DatabaseController.checkIfExist(apkey, "Staff", objects: ["username":username])
        
        let staffObjects = JSONController.parseDatabaseAny(strResult)
        
        if staffObjects.count > 0 {
            
            var staffObject = staffObjects[0] as? [String:Any] ?? [:]
            
            if staffObject.count > 0 {
                
                let resetPassword = staffObject["resetPassword"] as? Int ?? 0
                
                if resetPassword == 1 {
                    
                    return ( result, "{\"data\":[\(JSONController.parseJSONToStr(dict: staffObject))]}" )
                }
            }
        }

        
        let queryObject: [String:String] = ["userID": username]
        
        let queryStr = JSONController.parseJSONToStr(dict: queryObject)
        
        let userHash = DatabaseController.retrieveCollectionQueryStr(apkey, "UserHash", query: queryStr)
        
        let hashObjects = JSONController.parseDatabaseAny(userHash)
        
        if hashObjects.count > 0 {
            
            var hashObject = hashObjects[0] as? [String:Any] ?? [:]
            
            let hashStr = hashObject["hash"] as! String
            
            do  {
                let hashSalt = try BCryptSalt(string: hashStr)
                
                let testHashStr = BCrypt.hash(password: password, salt: hashSalt)
            
                let ( result, strResult ) = DatabaseController.checkIfExist(apkey, "Staff", objects: ["username":username, "password": testHashStr])
                
                let staffObjects = JSONController.parseDatabaseAny(strResult)
                
                if staffObjects.count > 0 {
                    
                    let staffObject = staffObjects[0] as? [String:Any] ?? [:]
                    
                    if staffObject.count > 0 {
                
                        return ( result, "{\"data\":[\(JSONController.parseJSONToStr(dict: staffObject))]}" )
                    }
                }
            
            } catch {
                return ( false,  "{\"data\":[]}")
            }
        }
        
        return ( false, "{\"data\":[]}")
    }
    
    static func tryResetPassword(_ apkey: String, _ username: String, password: String ) -> ( Bool, String ) {
        
        if username == "" {
            return ( false, "mssing username" )
        }
        
        if password == "" {
            return ( false, "missing password" )
        }
        
        let queryObject: [String:String] = ["username": username]
        
        let queryStr = JSONController.parseJSONToStr(dict: queryObject)
        
        let staffStr = DatabaseController.retrieveCollectionQueryStr(apkey, "Staff", query: queryStr)
        
        let resetObjects = JSONController.parseDatabaseAny(staffStr)
        
        if resetObjects.count > 0 {
            
            var resetObject = resetObjects[0] as? [String:Any] ?? [:]
            
            
            let hashSalt = BCryptSalt()
            let hashStr = hashSalt.string
            
            let hashDatabase: [String:String] = ["userID": username, "hash": hashStr  ]
            
            let userObj: [String:String] = ["userID": username ]
            
            let jsonhash = JSONController.parseJSONToStr(dict: hashDatabase)
            let jsonUser = JSONController.parseJSONToStr(dict: userObj)
            
            DatabaseController.updateDocument(apkey, "UserHash", jsonStr: jsonhash, query: jsonUser)
            
            resetObject["password"] = BCrypt.hash(password: password, salt: hashSalt)
            resetObject["resetPassword"] = 0
    
            let resetStr = JSONController.parseJSONToStr(dict: resetObject)
    
            return (true, DatabaseController.updateDocument(apkey, "Staff", jsonStr: resetStr, query: queryStr) )
            
        } else {
        
            return (false, "error with parsing")
        }
    }
    
    static func tryRegister(_ apkey: String, _ jsonStr: String ) -> String {
        
        var registerObjects = JSONController.parseJSONToDict(jsonStr)
        
        guard let username = registerObjects["username"] as? String else {
            return "mssing username"
        }
        
        guard let password = registerObjects["password"] as? String else {
            return "missing password"
        }
        
        let hashSalt = BCryptSalt()
        let hashStr = hashSalt.string
        
        let hashDatabase: [String:String] = ["userID": username, "hash": hashStr  ]
        
        let jsonhash = JSONController.parseJSONToStr(dict: hashDatabase)
        
        DatabaseController.insertDocument(apkey, "UserHash", jsonStr: jsonhash)
        
        registerObjects["password"] = BCrypt.hash(password: password, salt: hashSalt)

        
        let (exits, _) = DatabaseController.checkIfExist(apkey, "Staff", objects: ["username": username])
        if exits {
            return "usernmae already exist"
        }
        
        let registerStr = JSONController.parseJSONToStr(dict: registerObjects)
        
        return DatabaseController.insertDocument(apkey, "Staff", jsonStr: registerStr )
    }
}
