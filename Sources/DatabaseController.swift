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

    
    static func connectDatabase(_ client: MongoClient ) -> MongoDatabase {
        // set database, assuming "test" exists
        return client.getDatabase(name: "locql")
    }
    
    static func closeMongoDB(_ collection: MongoCollection, database: MongoDatabase, client: MongoClient ) {
        collection.close()
        database.close()
        client.close()
    }
    
    static func getAllCollections() -> String {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
        let collections = db.collectionNames()
        
        defer {
            db.close()
            client.close()
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
    static func dropCollection(_ collectionName:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    static func renameCollection(_ oldCollectionName:String, newCollectionName:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    static func removeIndex(_ collectionName:String, index:String) -> Bool {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    static func createUniqueIndex(_ collectionName: String, index: String) -> String {
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    static func insertCollection(_ collectionName: String, jsonStr: String ) -> String {
        
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
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    
    private class func moment(_ seconds: TimeInterval) -> Date {
        let interval = TimeInterval(seconds)
        let date = Date(timeIntervalSince1970: interval)
        return date
    }
    
    private class func getNow() -> Double {
        
        var posixTime = timeval()
        gettimeofday(&posixTime, nil)
        return Double((posixTime.tv_sec * 1000) + (Int(posixTime.tv_usec)/1000))
    }
    
    private class var nowDate: String {
        return "\(self.moment(self.getNow()))"
    }
    
    
    @discardableResult
    static func insertDocument(_ collectionName: String, jsonStr: String ) -> String {
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    
    
    @discardableResult
    static func updateInsertDocument(_ collectionName: String, jsonStr: String ) -> String {
    
        var objectID = ""
        
        do {
            
            let decoded = try jsonStr.jsonDecode() as? [String:Any]
            
            if (decoded?["_id"] as? String ) != nil {
                objectID =  decoded?["_id"] as! String
            }
            
        } catch let error {
            print(error)
        }
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return ""
        }
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
        
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
            self.insertDocument(collectionName, jsonStr: jsonStr)
        }
        else {
            
            let query = BSON()
            query.append(key: "_id", string: objectID)
            
            document.append(key: "updated", string: self.nowDate )
            
            let _ = collection.update(selector: query, update: document)
        
        }
        
        return ""
    }
    
    static func safeRemoveDocument(_ collectioName: String, _ jsonStr: String ) -> Bool {
        
        guard let document = try? BSON.init(json: jsonStr) else {
            return false
        }
        document.append(key: "deleted", string: "1")
        document.append(key: "updated", string: self.nowDate)
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    
    static func removeDocument(_ collectioName: String, _ documentID: String ) -> Bool {
    
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
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
    
    static func retrieveCollectionQuery(_ collectioName: String, _ documentID: String, skip: Int = 0, limit: Int = 100 ) -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        // set database
        let db = connectDatabase(client)
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
            return ""
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
        
        // return a formatted JSON array.
        return  "{\"data\":[\(arr.joined(separator: ","))]}"
    }
    
    static func retrieveCollectionQuery(_ collectioName: String, query: String, skip: Int = 0, limit: Int = 100 ) -> String {
        
        
        // open a connection
        let client = openMongoDB()
        
        // set database
        let db = connectDatabase(client)
        
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
        let fnd = collection.find(query: query, fields: nil, flags: .none, skip: skip, limit: limit, batchSize: .allZeros)
        
        // Initialize empty array to receive formatted results
        var arr = [String]()
        
        // The "fnd" cursor is typed as MongoCursor, which is iterable
        for x in fnd! {
            arr.append(x.asString)
        }
        
        // return a formatted JSON array.
        return  "{\"data\":[\(arr.joined(separator: ","))]}"
    
    }
    
    static func checkIfExist(_ collectioName: String, objects: [String:String]  ) -> Bool {
        
        let client = openMongoDB()
        
        let db = connectDatabase(client)
        
        guard let collection = db.getCollection(name: collectioName) else {
            return false
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
                return true
            }
            
        } else {
            return false
        }

        return false
    }
    

    
    
    static func retrieveCollection(_ collectioName: String, _ objectID: String = "", skip: Int = 0, limit: Int = 100 ) -> String {
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
            return ""
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
        
        // return a formatted JSON array.
        return  "{\"data\":[\(arr.joined(separator: ","))]}"
        
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
