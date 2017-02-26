//
//  ConfigSettingsHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 25/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB


/// Defines and returns the Web Authentication routes
public func makeConfigSettingRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/api/configSettings/", handler: sendConfigSettings)
    
    routes.add(method: .get, uri: "/api/configSettings/", handler: getConfigSettings)
    
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getConfigSettings(request: HTTPRequest, _ response: HTTPResponse) {
    
    let returnStr = ResultBody.errorBody(value: "config settings not found" )
    
    let result = "{\"data\":" + ConfigSettingController.getConfigFile() + "}"
    
    if result == "" {
        response.appendBody(string: returnStr)
    } else {
        response.appendBody(string: result)
    }
    response.completed()
}


func sendConfigSettings(request: HTTPRequest, _ response: HTTPResponse) {
    
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    var returnStr =  ResultBody.successBody(value: "updated")
    
    if !ConfigSettingController.sendConfigFile(jsonStr) {
        returnStr =  ResultBody.errorBody(value: "not updated")
    }
    
    response.appendBody(string: returnStr)
    response.completed()
}
