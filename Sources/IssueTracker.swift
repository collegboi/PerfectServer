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
    
    static func sendNewIssue(_ issueObject: String ) -> String {
        
        return DatabaseController.updateInsertDocument("Issue", jsonStr: issueObject)
    }
    
    static func getAllIssues() -> String {
        
        return DatabaseController.retrieveCollection("Issue")
    }
    
    
    static func getIssue(_ issueID: String ) {
        
        
        
    }
    
}
