//
//  TrackerHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 28/01/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB


/// Defines and returns the Web Authentication routes
public func makeTrackerRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/tracker", handler: sendTrackerIssue)
    routes.add(method: .get, uri: "/tracker/{collection}", handler: getTrackerIssues)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getTrackerIssues(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    let returning = IssueTracker.getAllIssues()
    
    response.appendBody(string: returning)
    response.completed()
}


func sendTrackerIssue(request: HTTPRequest, _ response: HTTPResponse) {
    
    //let jsonStr = request.postBodyString //else {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    var returnStr =  ResultBody.successBody(value: "notCreated")
    
    let result = IssueTracker.sendNewIssue(jsonStr)
        
    returnStr = ResultBody.successBody(value: result )
    
    response.appendBody(string: returnStr)
    response.completed()
}
