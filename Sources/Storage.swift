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
    
    class func StoreObjects(_ collectionName: String, _ jsonString: String ) -> Bool {
        
        var result : Bool = false
        
        if  DatabaseController.insertCollection(collectionName, jsonStr: jsonString) == "" {
            result = true
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
    
    class func getCollectionStr(_ collection:String, query: String) -> String {
        return DatabaseController.retrieveCollectionQueryStr(collection, query: query)
    }
    
    class func getCollectionStr(_ collection: String) ->String{
        return DatabaseController.retrieveCollectionString(collection)
    }
    
    
    class func getAllCollections() -> String {
        return DatabaseController.getAllCollections()
    }
    
    
    class func createIndex(_ collection: String, index: String ) -> String {
        return DatabaseController.createUniqueIndex(collection, index: index)
    }
    
    
    class func dropIndex(_ collection: String, index:String) {
        DatabaseController.removeIndex(collection, index: index)
    }
    
    
    class func renameCollection(_ oldCollection: String, newCollection: String) {
        DatabaseController.renameCollection(oldCollection, newCollectionName: newCollection)
    }
    
    
    class func dropCollection(_ collection: String){
        DatabaseController.dropCollection(collection)
    }
    
    class func getQueryCollection(_ collection: String, json: String, skip: Int = 0, limit: Int = 100) -> String {
        return DatabaseController.retrieveCollectionQuery(collection, query: json, skip: skip , limit: limit)
    }
    
}
