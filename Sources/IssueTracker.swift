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
        
        let storage = Storage()
        storage.setAppKey(appKey)
        storage.setCollectionName(collectionName)
        
        return storage.updateInsertDocument(issueObject)
    }
    
    static func getAllIssues(_ appKey:String, _ collectionName: String) -> String {
        
        let storage = Storage()
        storage.setAppKey(appKey)
        storage.setCollectionName(collectionName)
        
        return storage.getCollectionStr()
    }
    
    
    static func getIssue(_ appkey:String, _ collectionName: String, _ issueID: String ) -> String {
        let storage = Storage()
        storage.setAppKey(appkey)
        storage.setCollectionName(collectionName)
        
        return storage.getCollectionStr(query: issueID)
    }
}
