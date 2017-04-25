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
    
    private var appKey: String = ""
    private var testMode: Int = 0
    private var appVersion: String = ""
    private var collectionName: String = ""
    
    func setAppKey(_ value: String) {
        self.appKey = value
    }
    func setTestMode(_ value: Int) {
        self.testMode = value
    }
    func setAppVersion(_ value: String) {
        self.appVersion = value
    }
    func setCollectionName(_ value: String) {
        self.collectionName = value
    }
    
    func getCollectioName() -> String {
        return self.collectionName
    }
    
    private func getDatabaseController() -> DatabaseController {
        
        let databaseController = DatabaseController()
        databaseController.setAppVersion(appVersion)
        databaseController.setAppKey(appKey)
        databaseController.setCollectiomName(collectionName)
        databaseController.setTestMode(testMode)
        return databaseController
    }
    
    func checkIfExist(_ objects: [String:String]  ) -> (Bool, String ) {
        let databaseController = getDatabaseController()
        return databaseController.checkIfExist(objects)
    }
    
    func parseAndStoreObject(_ jsonString: String ) -> Bool {
        
        var result : Bool = false
        
        do {
            
            let decoded = try jsonString.jsonDecode() as? [String:Any]
            
            guard let dict = decoded?.keys.first else {
                return false
            }
            
            let databaseController = getDatabaseController()
            databaseController.setCollectiomName(dict)
            
            if  databaseController.insertDocument(jsonString) == "" {
                result = true
            }
            
        } catch let error {
            print(error)
        }
        
        return result
    }
    
    func StoreObjects(_ jsonString: String ) -> Bool {
        
        var result : Bool = false
        
        let databaseController = getDatabaseController()
        
        if  databaseController.insertCollection(jsonString) == "" {
            result = true
        }
        
        return result
    }
    
    func StoreObject(_ jsonString: String ) -> (Bool, String ) {
        
        var result : Bool = true
        var message: String = ""
        
        let databaseController = getDatabaseController()
        
        message =  databaseController.updateInsertDocument(jsonString )
        
        if message == "" {
            result = false
            message = "error"
        }
        
        return (result, message)
    }
    
    
    func getCollectionValues() -> String {
        
        let databaseController = getDatabaseController()
        
        let applicationObject: [String:String] = ["appKey": self.appKey]
        let applicationString = JSONController.parseJSONToStr(dict: applicationObject)
        
        databaseController.setCollectiomName("TBApplication")
        databaseController.setAppKey("JKHSDGHFKJGH454645GRRLKJF")
        
        let applicationArr = databaseController.retrieveCollectionQuery(applicationString)
        let applicationObjects = JSONController.parseJSONToDict("\(applicationArr.joined(separator: ","))")
        
        let queryObject: [String:String] = ["version":appVersion, "applicationID": applicationObjects["_id"] as? String ?? ""]
        let queryString = JSONController.parseJSONToStr(dict: queryObject)
        
        databaseController.setCollectiomName("RemoteConfig")
        let removeVersion = databaseController.retrieveCollectionQuery(queryString)
        
        let configObjects = JSONController.parseJSONToDict("\(removeVersion.joined(separator: ","))")
        
        let objectParams = "\"config\": { \"version\": \"\( configObjects["version"] ?? 0.0 )\", \"date\": \"\(configObjects["updated"] ?? 0.0)\" }"
        
        let newDatabaseController = getDatabaseController()
        
        let collectionParms =  newDatabaseController.retrieveCollection()
        let collectionString = "\"count\":\(collectionParms.count),\"data\":[\(collectionParms.joined(separator: ","))]"
        
        return "{ \(objectParams), \(collectionString)  }"
    }
    
    func getDocumentWithObjectID(_ objectID: String = "", skip: Int = 0, limit: Int = 100 ) -> String {
        
        let databaseController = getDatabaseController()
        
        let document = databaseController.retrieveCollection(objectID, skip: skip, limit: limit )
        
        return "{\"data\":[\(document.joined(separator: ","))]}"
    }
    
    @discardableResult
    func updateDocument(jsonStr: String, query: String) -> String {
        let databaseController = getDatabaseController()
        return databaseController.updateDocument(jsonStr, query: query)
    }
    
    @discardableResult
    func insertDocument(jsonStr: String) -> String {
        let databaseController = getDatabaseController()
        return databaseController.insertDocument(jsonStr)
    }
    
    func removeDocument(_ documentID: String) -> Bool {
        let databaseController = getDatabaseController()
        return databaseController.removeDocument(documentID)
    }
    
    @discardableResult
    func updateInsertDocument(_ jsonStr: String) -> String {
        let databaseController = getDatabaseController()
        return databaseController.updateInsertDocument(jsonStr)
    }
    
    func safeRemoveDocument(_ document: String ) -> Bool {
        let databaseController = getDatabaseController()
        return databaseController.safeRemoveDocument(document)
    }
    
    func removeCollection() -> Bool {
        let databaseController = getDatabaseController()
        return databaseController.removeCollection()
    }
    
    func removeDatabase() -> Bool {
        let databaseController = getDatabaseController()
        return databaseController.removeDatabase()
    }
    
    func getCollectionStr(query: String) -> String {
        let databaseController = getDatabaseController()
        return databaseController.retrieveCollectionQueryStr(query)
    }
    
    func getCollectionStrFields(query: String, fields : String) -> [String] {
        let databaseController = getDatabaseController()
        return databaseController.retrieveCollectionQueryStrFields(query, fields: fields)
    }
    
    func getAllColectionsArr() -> [String] {
        let databaseController = getDatabaseController()
        return databaseController.getAllColectionsArr()
    }
    
    
    func getCollectionStr() ->String{
        let databaseController = getDatabaseController()
        return databaseController.retrieveCollectionString()
    }
    
    func getAllDatabases() -> String {
        let databaseController = getDatabaseController()
        return databaseController.getAllDatabases()
    }
    
    func getAllCollections() -> String {
        let databaseController = getDatabaseController()
        return databaseController.getAllCollections()
    }
    
    func getQueryCollection(_ json: String, skip: Int = 0, limit: Int = 100) -> String {
        
        let databaseController = getDatabaseController()
        let collectionObjs = databaseController.retrieveCollectionQuery(json, skip: skip , limit: limit)
        
        return "{\"count\":\(collectionObjs.count),\"data\":[\(collectionObjs.joined(separator: ","))]}"
    }
    
    func createIndex(_ index: String ) -> String {
        let databaseController = getDatabaseController()
        return databaseController.createUniqueIndex(index)
    }
    
    
    func dropIndex(_ index:String) {
        let databaseController = getDatabaseController()
        databaseController.removeIndex(index)
    }
    
    
    func renameCollection(_ oldCollection: String, newCollection: String) {
        let databaseController = getDatabaseController()
        databaseController.renameCollection(oldCollection, newCollectionName: newCollection)
    }
    
    
    func dropCollection() {
        let databaseController = getDatabaseController()
        databaseController.dropCollection()
    }
    
    func dropDatabase() -> String {
        let databaseController = getDatabaseController()
        return databaseController.dropDatabase()
    }
    
    class func replicateDatabase(_ appID: String) {
        
        let databaseController = DatabaseController()
        databaseController.setAppKey(appID)
        let collections = databaseController.getAllColectionsArr()
        
        if collections.count > 0 {
            
            for collection in collections {
                
                databaseController.setCollectiomName(collection)
                let collectionData = databaseController.retrieveCollectionString()
                
                databaseController.setTestMode(1)
                databaseController.insertDocument(collectionData)
            }
        }
        
        databaseController.setTestMode(0)
        databaseController.setCollectiomName("TBApplication")
        databaseController.setAppKey("JKHSDGHFKJGH454645GRRLKJF")
        
        let applicationQuery: [String:String] = ["appKey": appID]
        let applicationQueryString = JSONController.parseJSONToStr(dict: applicationQuery)
        let applicationArr = databaseController.retrieveCollectionQueryStr(applicationQueryString)
        
        var applicationObject = JSONController.parseJSONToDict(applicationArr)
        
        if applicationObject.count > 0 {
            
            applicationObject["testDB"] = "1"
            
            let appString = JSONController.parseJSONToStr(dict: applicationObject)
            
            databaseController.updateDocument(appString, query: applicationQueryString)
        }
        
        
    }
    
}
