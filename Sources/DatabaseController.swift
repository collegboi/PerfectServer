//
//  MongoDB.swift
//  PerfectProject2
//
//  Created by Timothy Barnard on 19/01/2017.
//
//
import StORM
import MongoDB
import PerfectLogger
import Foundation
import SwiftMoment

#if os(Linux)
    import LinuxBridge
#endif

class DatabaseController {
    
    private var appVersion: String = ""
    private var testMode: Int = 0
    private var appKey: String = ""
    private var collectioName: String = ""
    
    func setAppVersion(_ value: String) {
        self.appVersion = value
    }
    func setTestMode(_ value: Int) {
        self.testMode = value
    }
    func setAppKey(_ value: String) {
        self.appKey = value
    }
    func setCollectiomName(_ value: String) {
        self.collectioName = value
    }
    
    
    private func testBasic(_ message: String) {
        LogFile.location = "./database.log"
    
        LogFile.info(message)
    }
    
    private func openMongoDB() -> MongoClient {
        // open a connection
        return try! MongoClient(uri: "mongodb://localhost:27017")
    }
    
    private func connectDatabaseLocal(_ client: MongoClient) -> MongoDatabase? {
        
        return client.getDatabase(name: "locql" )
    }
    
    private func closeMongoDB(_ database: MongoDatabase, client: MongoClient ) {
        database.close()
        client.close()
    }
    
    private func closeMongoDB(_ collection: MongoCollection, database: MongoDatabase, client: MongoClient ) {
        collection.close()
        database.close()
        client.close()
    }
    
    private func closeMongoDB(client: MongoClient ) {
        client.close()
    }
    
    private func getDatabaseName() -> String {
        
        // open a connection
        let client = openMongoDB()
        
        let db = client.getDatabase(name: "locql")
        
        let query = BSON()
        query.append(key: "appKey", string: self.appKey)
        
        
        // define collection
        guard let collection = db.getCollection(name: "TBApplication") else {
            return ""
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        
        let fnd = collection.find(query: query)
        
        let jsonStr = (fnd?.jsonString)!
        
        let data = JSONController.parseDatabaseAny(jsonStr)[0] as? [String:Any]
        
        guard let field = data?["databaseName"] as? String else {
            return ""
        }
        
        return field
    }
    
    private func connectDatabase(_ client: MongoClient, name: String = "") -> MongoDatabase? {
        
        //self.testBasic(self.appKey + "-" + name)
        
        //Unique for creating apps
        if self.appKey == "JKHSDGHFKJGH454645GRRLKJF" {
            return client.getDatabase(name: "locql" )
        }
        
        let databaseName = self.getDatabaseName()
        
        //That apID does not exits, so not data
        if databaseName == "" {
            return nil
        }
        
        //If we want the shared database
        if name != "" {
            return client.getDatabase(name: name )
        }
        
        if self.testMode != 0 {
            return client.getDatabase(name: databaseName + "_Test" )
        }
        
        return client.getDatabase(name: databaseName )
    }
    
    private func getCollectionObject() -> MongoCollection?  {
        return nil
    }
    
    func getAllColectionsArr()-> [String] {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        guard let db = connectDatabase(client) else {
            return []
        }
        
        let collections: [String] = db.collectionNames()
        
        defer {
            self.closeMongoDB(db, client: client)
        }
        
        return collections
    }
    
    func retrieveCollectionString() -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }

        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return "Collection does not exist"
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        
        // Perform a "find" on the perviously defined collection
        let fnd = collection.find()
        
        guard let jsonStr = fnd?.jsonString else {
            return ""
        }
        return jsonStr
    }

    
    func getAllDatabases() -> String {
        
        // open a connection
        let client = openMongoDB()
    
        let databases = client.databaseNames()
        
        defer {
            self.closeMongoDB(client: client)
        }
        
        do {
            
            let json = try databases.jsonEncodedString()
            
            return  "{\"data\":\(json)}"
            
        } catch let error {
            print(error)
        }
        
        return "{\"data\":[]}"
        
    }

    
    func getAllCollections() -> String {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        let collections = db.collectionNames()
        
        defer {
            self.closeMongoDB(db, client: client)
        }
        
        do {
        
            let json = try collections.jsonEncodedString()
            
            return  "{\"data\":\(json)}"
            
        } catch let error {
            print(error)
        }
        
        return "{\"data\":[]}"
        
    }
    
    @discardableResult
    func dropCollection() -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return false
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.drop()
        
        return true
    }
    
    
    @discardableResult
    func renameCollection(_ oldCollectionName:String, newCollectionName:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: oldCollectionName) else {
            return false
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.rename(newDbName: db.name(), newCollectionName: newCollectionName, dropExisting: true)
        
        return true
    }
    
    @discardableResult
    func removeIndex(_ index:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return false
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.dropIndex(name: index)
        
        return true
    }
    
    
    @discardableResult
    func createUniqueIndex(_ index: String) -> String {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ""
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let mongoIndex = MongoIndexOptions.init(name: "index_"+index, background: nil, unique: true, dropDups: nil, sparse: nil,
                                                expireAfterSeconds: nil, v: nil, defaultLanguage: nil, languageOverride: nil,
                                                                            weights: nil, geoOptions: nil, storageOptions: nil)
        
        let indexBSON = BSON()
        indexBSON.append(key: index)
        
        let _ = collection.createIndex(keys: indexBSON, options: mongoIndex)

        return "index_"+index
    }
    
    @discardableResult
    func insertCollection(_ jsonStr: String ) -> String {
        
        let collectionValues = JSONController.parseJSONToArrDic(jsonStr)
        
        var bsonArray = [BSON]()
        
        for documentItem in collectionValues {
         
            let json = JSONController.parseJSONToStr(dict: documentItem)
            
            guard let document = try? BSON.init(json: json) else {
                return ""
            }
            
            let newObjectID = self.myNewUUID()
            
            document.append(key: "_id", string: newObjectID  )
            
            bsonArray.append(document)
        }
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return "Error with collection name"
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.insert(documents: bsonArray)
        
        return ""
        //        if returnValue == MongoResult.success {
        //            return "Success"
        //        } else {
        //            return "Failure"
        //        }
    }
    
    private func nowDateTime() -> String {
        let m = moment()
        return m.format()
    }
    
    private var nowDate: String {
        return self.nowDateTime()
    }
    
    
    @discardableResult
    func insertDocument(_ jsonStr: String ) -> String {
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return "Error with collection name"
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let newObjectID = self.myNewUUID()
        
        document.append(key: "_id", string: newObjectID  )
        document.append(key: "created", string: self.nowDate )
        document.append(key: "updated", string: self.nowDate )
        document.append(key: "deleted", string: "0")
        
        let _ = collection.insert(document: document)
        
        return newObjectID
//        if returnValue == MongoResult.success {
//            return "Success"
//        } else {
//            return "Failure"
//        }
    }
    
    
    private func retrieveCollectionQueryValues(_ key: String, value: String, field: String, collectionName: String = "") -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        let query = BSON()
        query.append(key: key, string: value)
        
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ""
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        
        let fnd = collection.find(query: query)// fields: fields, flags: .none, skip: 0, limit: 1, batchSize: .allZeros)
        
        let jsonStr = (fnd?.jsonString)!
        
        let data = JSONController.parseDatabaseAny(jsonStr)[0] as? [String:Any]
        
        guard let field = data?[field] as? String else {
            return ""
        }
        
        return field
    }

    func retrieveCollectionQueryStrFields(_ query: String, fields: String ) -> [String] {
        
        
        var fieldRecords = [String]()
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return fieldRecords
        }
        
        guard let query = try? BSON.init(json: query) else {
            return fieldRecords
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return fieldRecords
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        
        let fnd = collection.find(query: query)
        
        
        
        let jsonCollection = fnd?.jsonString ?? ""
        
        if jsonCollection != "" {
            
            let records = JSONController.parseDatabaseAny(jsonCollection)
            
            for record in records {
                
                guard let dict = record as? [String:Any] else {
                    continue
                }
                
                guard let field = dict[fields] as? String else {
                    continue
                }
                
                fieldRecords.append(field)
            }
        }
        
        return fieldRecords
        
    }

    
    func retrieveCollectionQueryStr(_ query: String ) -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        guard let query = try? BSON.init(json: query) else {
            return ""
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ""
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        // Perform a "find" on the perviously defined collection
        let fnd = collection.find(query: query)
        
        return fnd?.jsonString ?? ""
    }
    
    @discardableResult
    func updateDocument(_ jsonStr: String, query: String) -> String {
        
        var objectID = ""
        
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        
        guard let queryDocument = try? BSON.init(json: query) else {
            return ""
        }
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return "Error with collection name"
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
            
        let _ = collection.update(selector: queryDocument, update: document)
        
        return "Success"
    }

    
    
    @discardableResult
    func updateInsertDocument(_ jsonStr: String ) -> String {
    
        var objectID = ""
        //var databaseName = ""
        
        do {
            
            let decoded = try jsonStr.jsonDecode() as? [String:Any]
            
            if (decoded?["_id"] as? String ) != nil {
                objectID =  decoded?["_id"] as! String
            }
            
//            if let database = decoded?["databaseName"] as? String {
//                databaseName = database
//            }
            
        } catch let error {
            print(error)
        }
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        document.append(key: "deleted", string: "0")
        document.append(key: "updated", string: self.nowDate)
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return "Error with collection name"
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        if objectID == "" {
            document.append(key: "inserted", string: self.nowDate)
            objectID = self.insertDocument(jsonStr)
        }
        else {
            
            let query = BSON()
            query.append(key: "_id", string: objectID)
            
            document.append(key: "updated", string: self.nowDate )
            
            let _ = collection.update(selector: query, update: document)
        
        }
        
        return objectID
    }
    
    func safeRemoveDocument(_ jsonStr: String ) -> Bool {
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return false
        }
        document.append(key: "deleted", string: "1")
        document.append(key: "updated", string: self.nowDate)
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return false
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let jsonObjects = JSONController.parseJSONToDict(jsonStr)
        
        guard let documentID = jsonObjects["_id"] as? String else {
            return false
        }
        
        let query = BSON()
        
        query.append(key: "_id", string: documentID)
        
        let _ = collection.update(selector: query, update: document)
        
        return  true
    }
    
    func removeCollection() -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return false
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.drop()
        
        return  true
    }
    
    func removeDatabase() -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(db, client: client)
        }
        
        let _ = db.drop()
        
        return  true
    }

    
    func removeDocument(_ documentID: String ) -> Bool {
    
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return false
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let query = BSON()
        query.append(key: "_id", string: documentID)
        
        let _ = collection.remove(selector: query)
        
        return  true
    }
    
    func retrieveCollectionDocumentID(_ documentID: String, skip: Int = 0, limit: Int = 100 ) -> [String] {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return ["Error with connecting"]
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ["collection not existing"]
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let query = BSON()
        query.append(key: "issueID", string: documentID)
        
        // Perform a "find" on the perviously defined collection
        let fnd = collection.find(query: query, fields: nil, flags: .none, skip: skip, limit: limit, batchSize: .allZeros)
        
        // Initialize empty array to receive formatted results
        var arr = [String]()
        
        // The "fnd" cursor is typed as MongoCursor, which is iterable
        for x in fnd! {
            arr.append(x.asString)
        }
        
        return arr
    }
    
    func retrieveCollectionQuery(_ query: String, skip: Int = 0, limit: Int = 100 ) -> [String] {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return ["Error with connecting"]
        }
        
        guard let query = try? BSON.init(json: query) else {
            return ["parsing query error"]
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ["collection error"]
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        // Perform a "find" on the perviously defined collection
        let fnd = collection.find(query: query, fields: nil, flags: .none, skip: skip, limit: limit, batchSize: .allZeros)
        
        // Initialize empty array to receive formatted results
        var arr = [String]()
        
        // The "fnd" cursor is typed as MongoCursor, which is iterable
        for x in fnd! {
            arr.append(x.asString)
        }
        
        return  arr
    }
    
    func retrieveCollection(_ objectID: String = "", skip: Int = 0, limit: Int = 100 ) -> [String] {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return ["Error with connecting"]
        }
        
        // define collection
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ["collection error"]
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let query = BSON()
        
        if objectID != "" {
            query.append(key: "_id", string: objectID)
        }
        
        // Perform a "find" on the perviously defined collection
        let fnd = collection.find(query: query, fields: nil, flags: .none, skip: skip, limit: limit, batchSize: .allZeros)
        
        // Initialize empty array to receive formatted results
        var arr = [String]()
        
        // The "fnd" cursor is typed as MongoCursor, which is iterable
        for x in fnd! {
            arr.append(x.asString)
        }
        
        return  arr
    }

    
    func checkIfExist(_ objects: [String:String]  ) -> (Bool, String ) {
        
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return ( false, "error" )
        }
        
        guard let collection = db.getCollection(name: self.collectioName) else {
            return ( false, "error" )
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let query = BSON()
        
        if objects.count > 0 {
            
            for ( key, value ) in objects {
                query.append(key: key, string: value)
            }
            
            let fnd = collection.find(query: query)
            
            var arr = [String]()
            for x in fnd! {
                arr.append(x.asString)
            }
            
            if arr.count == 1 {
                
                return ( true, "[\(arr.joined(separator: ","))]" )
            }
            
        } else {
            return ( false, "error" )
        }

        return ( false, "error" )
    }
    
    private func myNewUUID() -> String {
        let x = asMyUUID()
        return x.string
    }
}

struct asMyUUID {
    var uuid: uuid_t
    
    init() {
        let u = UnsafeMutablePointer<UInt8>.allocate(capacity:  MemoryLayout<uuid_t>.size)
        defer {
            u.deallocate(capacity: MemoryLayout<uuid_t>.size)
        }
        uuid_generate_random(u)
        uuid = uuid_t(u[0], u[1], u[2], u[3], u[4], u[5], u[6], u[7], u[8], u[9], u[10], u[11], u[12], u[13], u[14], u[15])
    }
    
    var string: String {
        let u = UnsafeMutablePointer<UInt8>.allocate(capacity:  MemoryLayout<uuid_t>.size)
        let unu = UnsafeMutablePointer<Int8>.allocate(capacity:  37) // as per spec. 36 + null
        defer {
            u.deallocate(capacity: MemoryLayout<uuid_t>.size)
            unu.deallocate(capacity: 37)
        }
        var uu = self.uuid
        memcpy(u, &uu, MemoryLayout<uuid_t>.size)
        uuid_unparse_lower(u, unu)
        return String(validatingUTF8: unu)!
    }
}
