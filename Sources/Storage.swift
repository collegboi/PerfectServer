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
    
    class func getCollectionValues(_ appkey: String, _ collectionName: String, appVersion: String ) -> String {
        
        let applicationObject: [String:String] = ["appKey": appkey]
        let applicationString = JSONController.parseJSONToStr(dict: applicationObject)
        
        let applicationArr = DatabaseController.retrieveCollectionQuery("JKHSDGHFKJGH454645GRRLKJF", "TBApplication", query: applicationString)
        let applicationObjects = JSONController.parseJSONToDict("\(applicationArr.joined(separator: ","))")
        
        let queryObject: [String:String] = ["version":appVersion, "applicationID": applicationObjects["_id"] as? String ?? ""]
        let queryString = JSONController.parseJSONToStr(dict: queryObject)
        
        let removeVersion = DatabaseController.retrieveCollectionQuery("JKHSDGHFKJGH454645GRRLKJF", "RemoteConfig", query: queryString)
        
        let configObjects = JSONController.parseJSONToDict("\(removeVersion.joined(separator: ","))")
        
        let objectParams = "\"config\": { \"version\": \"\( configObjects["version"] ?? 0.0 )\", \"date\": \"\(configObjects["updated"] ?? 0.0) \" }"
    
        let collectionParms =  DatabaseController.retrieveCollection(appkey, collectionName)
        let collectionString = "\"count\":\(collectionParms.count),\"data\":[\(collectionParms.joined(separator: ","))]"
        
        return "{ \(objectParams), \(collectionString)  }"
    }
    
    class func getDocumentWithObjectID(_ apID: String,_ collectioName: String, _ objectID: String = "", skip: Int = 0, limit: Int = 100 ) -> String {
    
        let document = DatabaseController.retrieveCollection(apID,collectioName, objectID, skip: skip, limit: limit )
        
        return "{\"data\":[\(document.joined(separator: ","))]}"
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
    
    class func getQueryCollection(_ apID: String,_ collection: String, json: String, skip: Int = 0, limit: Int = 100) -> String {
        
        let collectionObjs = DatabaseController.retrieveCollectionQuery(apID, collection, query: json, skip: skip , limit: limit)
        
        return "{\"count\":\(collectionObjs.count),\"data\":[\(collectionObjs.joined(separator: ","))]}"
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
    
}
