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
    
    class func parseAndStoreObject(_ apID: String,_ jsonString: String ) -> Bool {
        
        var result : Bool = false
        
        do {
            
            let decoded = try jsonString.jsonDecode() as? [String:Any]
            
            guard let dict = decoded?.keys.first else {
                return false
            }
            
            if  DatabaseController.insertDocument(apID, dict, jsonStr: jsonString) == "" {
                result = true
            }
            
        } catch let error {
            print(error)
        }
        
        return result
    }
    
    class func StoreObjects(_ apID: String,_ collectionName: String, _ jsonString: String ) -> Bool {
        
        var result : Bool = false
        
        if  DatabaseController.insertCollection(apID, collectionName, jsonStr: jsonString) == "" {
            result = true
        }
        
        return result
    }
    
    class func StoreObject(_ apID: String,_ collectionName: String, _ jsonString: String ) -> Bool {
        
        var result : Bool = false
            
        if  DatabaseController.updateInsertDocument(apID, collectionName, jsonStr: jsonString ) == "" {
            result = true
        }
        
        return result
    }
    
    class func getCollectionStr(_ apID: String,_ collection:String, query: String) -> String {
        return DatabaseController.retrieveCollectionQueryStr(apID, collection, query: query)
    }
    
    class func getCollectionStr(_ apID: String,_ collection: String) ->String{
        return DatabaseController.retrieveCollectionString(apID, collection)
    }
    
    class func getAllDatabases(_ apID: String) -> String {
        return DatabaseController.getAllDatabases(apID)
    }
    
    class func getAllCollections(_ apID: String) -> String {
        return DatabaseController.getAllCollections(apID)
    }
    
    
    class func createIndex(_ apID: String,_ collection: String, index: String ) -> String {
        return DatabaseController.createUniqueIndex(apID, collection, index: index)
    }
    
    
    class func dropIndex(_ apID: String, _ collection: String, index:String) {
        DatabaseController.removeIndex(apID, collection, index: index)
    }
    
    
    class func renameCollection(_ apID: String, _ oldCollection: String, newCollection: String) {
        DatabaseController.renameCollection(apID, oldCollection, newCollectionName: newCollection)
    }
    
    
    class func dropCollection(_ apID: String, _ collection: String){
        DatabaseController.dropCollection(apID, collection)
    }
    
    class func getQueryCollection(_ apID: String,_ collection: String, json: String, skip: Int = 0, limit: Int = 100) -> String {
        return DatabaseController.retrieveCollectionQuery(apID, collection, query: json, skip: skip , limit: limit)
    }
    
}
