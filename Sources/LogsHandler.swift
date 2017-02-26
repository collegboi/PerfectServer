//
//  LogsHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 22/02/2017.
//
//

import Foundation

import PerfectLib
import PerfectHTTP
import MongoDB
import Turnstile


/// Defines and returns the Web Authentication routes
public func makeLogsRoutes() -> Routes {
    var routes = Routes()
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/api/{appkey}/logs/", handler: serverLogsHandler)
    routes.add(method: .get, uri: "/api/{appkey}/dbLogs/", handler: databaseLogsHandler)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func serverLogsHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
//    guard let appKey = request.urlVariables["appkey"] else {
//        response.appendBody(string: ResultBody.errorBody(value: "missing apID"))
//        response.completed()
//        return
//    }
    
    let logs = LogController.getRequestLogs()
    let logs2  = logs.replacingOccurrences(of: "\"", with: "")
    let allLogs = logs2.components(separatedBy: "\n")
    
    var array = [String]()
    
    for logs in allLogs {
        array.append("\"\(logs)\"")
    }
    
    response.appendBody(string: "{\"data\":[\(array.joined(separator: ","))]}")
    response.completed()
}


func databaseLogsHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    //    guard let appKey = request.urlVariables["appkey"] else {
    //        response.appendBody(string: ResultBody.errorBody(value: "missing apID"))
    //        response.completed()
    //        return
    //    }
    
    let logs = LogController.getDatabaseLogs()
    let logs2  = logs.replacingOccurrences(of: "\"", with: "")
    let allLogs = logs2.components(separatedBy: "\n")
    
    var array = [String]()
    
    for logs in allLogs {
        array.append("\"\(logs)\"")
    }
    
    response.appendBody(string: "{\"data\":[\(array.joined(separator: ","))]}")
    response.completed()
}
