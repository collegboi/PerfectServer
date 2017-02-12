//
//  LocalDatabaseHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 12/02/2017.
//
//

import Foundation

class LocalDatabaseHandler {
    
    
    public class func getCollection(_ collectionName: String, query: [String:String]) -> [[String:Any]] {
        
        let strQuery = JSONController.parseJSONToStr(dict: query)
        
        let returnData = DatabaseController.retrieveCollectionQuery(collectionName, query: strQuery)
        
        return JSONController.parseDatabase(returnData)
    }
}