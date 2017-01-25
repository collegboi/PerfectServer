//
//  MongoDB.swift
//  PerfectProject2
//
//  Created by Timothy Barnard on 19/01/2017.
//
//

import PerfectLib
import MongoDB

class DatabaseController {
    
    
    static func openMongoDB() -> MongoClient {
        
        // open a connection
        return try! MongoClient(uri: "mongodb://localhost:27017")
    }

    
    static func connectDatabase(_ client: MongoClient ) -> MongoDatabase {
        // set database, assuming "test" exists
        return client.getDatabase(name: "local")
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

        
        let _ = collection.insert(document: document)
        
        return ""
//        if returnValue == MongoResult.success {
//            return "Success"
//        } else {
//            return "Failure"
//        }
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
    
}
