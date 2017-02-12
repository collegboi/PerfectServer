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

    let returning = SystemController.getMemoryUsusageinMB()
    
    response.appendBody(string: returning)
    response.completed()
}
