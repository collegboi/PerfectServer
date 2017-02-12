//
//  SystemHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB


/// Defines and returns the Web Authentication routes
public func makeSystemRoutes() -> Routes {
    var routes = Routes()
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/system/", handler: getSystemStatus)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getSystemStatus(request: HTTPRequest, _ response: HTTPResponse) {

    var returnStr = ResultBody.errorBody(value: "error")
    
    #if os(Linux)
        returnStr = SystemController.getMemoryLinuxUsuage()
    #else
        returnStr = SystemController.getMemoryMacUsuage()
    #endif
    
    response.appendBody(string: returnStr)
    response.completed()
}
