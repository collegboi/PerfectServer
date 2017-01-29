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
    
    static func sendNewIssue( _ collectionName: String, _ issueObject: String ) -> String {
        
        return DatabaseController.updateInsertDocument(collectionName, jsonStr: issueObject)
    }
    
    static func getAllIssues(_ collectionName: String) -> String {
        
        return DatabaseController.retrieveCollection(collectionName)
    }
    
    
    static func getIssue(_ collectionName: String, _ issueID: String ) -> String {
        
        return DatabaseController.retrieveCollectionQuery(collectionName, issueID)
    }
    
}
