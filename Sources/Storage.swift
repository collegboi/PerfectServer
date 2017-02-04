//
//  Storage.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 25/01/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectLib

class Storage {
    
    class func parseAndStoreObject(_ jsonString: String ) -> Bool {
        
        var result : Bool = false
        
        do {
            
            let decoded = try jsonString.jsonDecode() as? [String:Any]
            
            guard let dict = decoded?.keys.first else {
                return false
            }
            
            if  DatabaseController.insertDocument(dict, jsonStr: jsonString) == "" {
                result = true
            }
            
        } catch let error {
            print(error)
        }
        
        return result
    }
    
    class func StoreObject(_ collectionName: String, _ jsonString: String ) -> Bool {
        
        var result : Bool = false
            
        if  DatabaseController.updateInsertDocument(collectionName, jsonStr: jsonString) == "" {
            result = true
        }
        
        return result
    }
    
    class func getAllCollections() -> String {
        
        return DatabaseController.getAllCollections()
    }

    
}
