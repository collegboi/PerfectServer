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
    
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            collection.close()
            database.close()
            client.close()
        }
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
        
        let newObjectID = self.asMyUUID().string
        
        document.append(key: "_id", string: newObjectID  )

        
        let _ = collection.insert(document: document)
        
        return ""
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
        
        if objectID == "" {
            self.insertDocument(collectionName, jsonStr: jsonStr)
        }
        else {
            
            let query = BSON()
            query.append(key: "_id", string: objectID)
            
            let _ = collection.update(selector: query, update: document)
        
        }
        
        return ""
        
    }
    
    static func retrieveCollection(_ collectioName: String) -> String {
        
        // define collection
        
        // open a connection
        let client = openMongoDB()
        
        // set database, assuming "test" exists
        let db = connectDatabase(client)
        
        // define collection
        guard let collection = db.getCollection(name: collectioName) else {
            return ""
        }
        
        // Here we clean up our connection,
        // by backing out in reverse order created
        defer {
            collection.close()
            db.close()
            client.close()
        }
        
        // Perform a "find" on the perviously defined collection
        let fnd = collection.find(query: BSON())
        
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
