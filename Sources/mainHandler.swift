//
//  mainHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 25/02/2017.
//
//

import PerfectLib
import PerfectHTTP


/// Defines and returns the Web Authentication routes
public func mainHandler() -> Routes {
    //var routes = Routes()
    
    //routes.add(method: .post, uri: "/api/{secreykey}/*", handler: sendConfigSettings)
    
    //print("\(routes.navigator.description)")
    
    let route = Route(uri: "/tester", handler: getTester)
    
    let routes = Routes(baseUri: "/api/v1/{secretkey}/{appkey}/storage", routes: [route])
    
    return routes
}


func getTester(request: HTTPRequest, _ response: HTTPResponse) {
    
    let returnStr = ResultBody.errorBody(value: "config settings not found" )
    
    let result = "{\"data\":" + ConfigSettingController.getConfigFile() + "}"
    
    if result == "" {
        response.appendBody(string: returnStr)
    } else {
        response.appendBody(string: result)
    }
    response.completed()
}
