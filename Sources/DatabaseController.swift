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

#if os(Linux)
    import LinuxBridge
#endif

class DatabaseController {
    
    static func openMongoDB() -> MongoClient {
        // open a connection
        return try! MongoClient(uri: "mongodb://localhost:27017")
    }
    
    private static func connectDatabase(_ client: MongoClient) -> MongoDatabase? {

        return client.getDatabase(name: "locql" )
    }
    
    static func connectDatabase(_ client: MongoClient, apID: String , name: String = "") -> MongoDatabase? {
        
        //Unique for creating apps
        if apID == "JKHSDGHFKJGH454645GRRLKJF" {
            return client.getDatabase(name: "locql" )
        }
        
        let databaseName = self.retrieveCollectionQueryValues(collectioName: "TBApplication", key: "appKey", value: apID, field: "databaseName")
        
        //That apID does not exits, so not data
        if databaseName == "" {
            return nil
        }
        
        //If we want the shared database
        if name != "" {
            return client.getDatabase(name: name )
        }
        
        return client.getDatabase(name: databaseName )
    }
    
    static func getAllColectionsArr(_ apID: String)-> [String] {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        guard let db = connectDatabase(client, apID: apID) else {
            return []
        }
        
        let collections: [String] = db.collectionNames()
        
        defer {
            self.closeMongoDB(db, client: client)
        }
        
        return collections
        
    }
    
    static func retrieveCollectionString(_ apID: String, _ collectioName: String ) -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        
        guard let db = connectDatabase(client, apID: apID) else {
            return "Error with connecting"
        }

        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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
    
    static func closeMongoDB(_ database: MongoDatabase, client: MongoClient ) {
        database.close()
        client.close()
    }
    
    static func closeMongoDB(_ collection: MongoCollection, database: MongoDatabase, client: MongoClient ) {
        collection.close()
        database.close()
        client.close()
    }
    
    static func closeMongoDB(client: MongoClient ) {
        client.close()
    }
    
    static func getAllDatabases(_ apID: String) -> String {
        
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

    
    static func getAllCollections(_ apID: String) -> String {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
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
    static func dropCollection(_ apID: String,_ collectionName:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
            return false
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.drop()
        
        return true
    }
    
    
    @discardableResult
    static func renameCollection(_ apID: String,_ oldCollectionName:String, newCollectionName:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
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
    static func removeIndex(_ apID: String,_ collectionName:String, index:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
            return false
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let _ = collection.dropIndex(name: index)
        
        return true
    }
    
    
    @discardableResult
    static func createUniqueIndex(_ apID: String,_ collectionName: String, index: String) -> String {
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return "Error with connecting"
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
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
    static func insertCollection(_ apID: String,_ collectionName: String, jsonStr: String ) -> String {
        
        let collectionValues = JSONController.parseJSONToArrDic(jsonStr)
        
        var bsonArray = [BSON]()
        
        for documentItem in collectionValues {
         
            let json = JSONController.parseJSONToStr(dict: documentItem)
            
            guard let document = try? BSON.init(json: json) else {
                return ""
            }
            
            let newObjectID = self.asMyUUID().string
            
            document.append(key: "_id", string: newObjectID  )
            
            bsonArray.append(document)
        }
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return "Error with connecting"
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
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
    
    private static func nowDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        return dateFormatter.string(from: Date())
    }
    
//    private class func moment(_ seconds: TimeInterval) -> Date {
//        let interval = TimeInterval(seconds)
//        let date = Date(timeIntervalSince1970: interval)
//        return date
//    }
//    
//    private class func getNow() -> Double {
//        
//        var posixTime = timeval()
//        gettimeofday(&posixTime, nil)
//        return Double((posixTime.tv_sec * 1000) + (Int(posixTime.tv_usec)/1000))
//    }
    
    private class var nowDate: String {
        return self.nowDateTime()
    }
    
    
    @discardableResult
    static func insertDocument(_ apID: String,_ collectionName: String, jsonStr: String ) -> String {
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return "Error with connecting"
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
            return "Error with collection name"
        }
        
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        let newObjectID = self.asMyUUID().string
        
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
    
    
    private static func retrieveCollectionQueryValues( collectioName: String, key: String, value: String, field: String) -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client) else {
            return "Error with connecting"
        }
        
        let query = BSON()
        query.append(key: key, string: value)
        
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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

    
    static func retrieveCollectionQueryStr(_ apID: String,_ collectioName: String, query: String ) -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return "Error with connecting"
        }
        
        guard let query = try? BSON.init(json: query) else {
            return ""
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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
    static func updateDocument(_ apID: String,_ collectionName: String, jsonStr: String, query: String) -> String {
        
        var objectID = ""
        var databaseName = ""
        
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        
        guard let queryDocument = try? BSON.init(json: query) else {
            return ""
        }
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID, name: databaseName) else {
            return "Error with connecting"
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
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
    static func updateInsertDocument(_ apID: String,_ collectionName: String, jsonStr: String ) -> String {
    
        var objectID = ""
        var databaseName = ""
        
        do {
            
            let decoded = try jsonStr.jsonDecode() as? [String:Any]
            
            if (decoded?["_id"] as? String ) != nil {
                objectID =  decoded?["_id"] as! String
            }
            
            if let database = decoded?["databaseName"] as? String {
                databaseName = database
            }
            
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
        
        guard let db = connectDatabase(client, apID: apID, name: databaseName) else {
            return "Error with connecting"
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: collectionName) else {
            return "Error with collection name"
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            self.closeMongoDB(collection, database: db, client: client)
        }
        
        if objectID == "" {
            document.append(key: "inserted", string: self.nowDate)
            self.insertDocument(apID, collectionName, jsonStr: jsonStr)
        }
        else {
            
            let query = BSON()
            query.append(key: "_id", string: objectID)
            
            document.append(key: "updated", string: self.nowDate )
            
            let _ = collection.update(selector: query, update: document)
        
        }
        
        return ""
    }
    
    static func safeRemoveDocument(_ apID: String,_ collectioName: String, _ jsonStr: String ) -> Bool {
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return false
        }
        document.append(key: "deleted", string: "1")
        document.append(key: "updated", string: self.nowDate)
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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
    
    static func removeCollection(_ apID: String,_ collectioName: String ) -> Bool {
        
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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

    
    static func removeDocument(_ apID: String,_ collectioName: String, _ documentID: String ) -> Bool {
    
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return false
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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
    
    static func retrieveCollectionQuery(_ apID: String,_ collectioName: String, documentID: String, skip: Int = 0, limit: Int = 100 ) -> [String] {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return ["Error with connecting"]
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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
    
    static func retrieveCollectionQuery(_ apID: String,_ collectioName: String, query: String, skip: Int = 0, limit: Int = 100 ) -> [String] {
        
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return ["Error with connecting"]
        }
        
        guard let query = try? BSON.init(json: query) else {
            return ["parsing query error"]
        }
        
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
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
    
    static func checkIfExist(_ apID: String,_ collectioName: String, objects: [String:String]  ) -> (Bool, String ) {
        
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return ( false, "error" )
        }
        
        guard let collection = db.getCollection(name: collectioName) else {
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
    

    
    
    static func retrieveCollection(_ apID: String,_ collectioName: String, _ objectID: String = "", skip: Int = 0, limit: Int = 100 ) -> [String] {
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        guard let db = connectDatabase(client, apID: apID) else {
            return ["Error with connecting"]
        }
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
            return [""]
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
    
    func myNewUUID() -> String {
        let x = asMyUUID()
        return x.string
    }
    struct asMyUUID {
        let uuid: uuid_t
        
        public init() {
            let u = UnsafeMutablePointer<UInt8>.allocate(capacity:  MemoryLayout<uuid_t>.size)
            defer {
                u.deallocate(capacity: MemoryLayout<uuid_t>.size)
            }
            uuid_generate_random(u)
            self.uuid = asMyUUID.uuidFromPointer(u)
        }
        
        public init(_ string: String) {
            let u = UnsafeMutablePointer<UInt8>.allocate(capacity:  MemoryLayout<uuid_t>.size)
            defer {
                u.deallocate(capacity: MemoryLayout<uuid_t>.size)
            }
            uuid_parse(string, u)
            self.uuid = asMyUUID.uuidFromPointer(u)
        }
        
        init(_ uuid: uuid_t) {
            self.uuid = uuid
        }
        
        private static func uuidFromPointer(_ u: UnsafeMutablePointer<UInt8>) -> uuid_t {
            // is there a better way?
            return uuid_t(u[0], u[1], u[2], u[3], u[4], u[5], u[6], u[7], u[8], u[9], u[10], u[11], u[12], u[13], u[14], u[15])
        }
        
        public var string: String {
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

}
