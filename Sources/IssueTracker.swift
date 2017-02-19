//
//  IssueTracker.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 28/01/2017.
//
//


#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif


class IssueTracker {
    
    static func sendNewIssue(_ appKey:String, _ collectionName: String, _ issueObject: String ) -> String {
        
        return DatabaseController.updateInsertDocument(appKey, collectionName, jsonStr: issueObject)
    }
    
    static func getAllIssues(_ appKey:String, _ collectionName: String) -> String {
        
        return DatabaseController.retrieveCollection(appKey, collectionName)
    }
    
    
    static func getIssue(_ appkey:String, _ collectionName: String, _ issueID: String ) -> String {
        
        return DatabaseController.retrieveCollectionQuery(appkey, collectionName, issueID)
    }
}
