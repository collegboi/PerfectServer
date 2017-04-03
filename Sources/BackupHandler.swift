//
//  BackupHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 18/02/2017.
//
//


import PerfectLib
import PerfectHTTP
import MongoDB


/// Defines and returns the Web Authentication routes
public func makeBackupRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/api/{appkey}/backup/now", handler: doBackup)
    
    routes.add(method: .get, uri: "/api/{appkey}/backup/", handler: getBackupList)
    
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getBackupList(request: HTTPRequest, _ response: HTTPResponse) {
    
    let returnStr = ResultBody.successBody(value: "" )
    
    response.appendBody(string: returnStr)
    response.completed()
}


func doBackup(request: HTTPRequest, _ response: HTTPResponse) {
    
    BackupService.doBackupNow()
    
    let returnStr = ResultBody.successBody(value: "" )
    
    response.appendBody(string: returnStr)
    response.completed()
}
