//
//  RCHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 21/01/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB

/// Defines and returns the Web Authentication routes
public func makeRCRoutes() -> Routes {
    var routes = Routes()
    
    
    routes.add(method: .get, uris: ["/", "index.html"], handler: indexRCHandler)
    routes.add(method: .post, uri: "/remote", handler: sendRemoteConfig)
    routes.add(method: .get, uri: "/remote", handler: getRemoteConfig)
    
    
    // Test this one via command line with curl:
    // curl --data "{\"id\":123}" http://0.0.0.0:8181/raw --header "Content-Type:application/json"
    routes.add(method: .post, uri: "/raw", handler: rawPOSTHandler)
    
    // Trailing wildcard matches any path
    routes.add(method: .get, uri: "**", handler: echo4Handler)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func indexRCHandler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "Index handler: You accessed path \(request.path)")
    response.completed()
}

func getRemoteConfig(request: HTTPRequest, _ response: HTTPResponse) {
    
    let returnStr = RemoteConfig.getContentsOfFile("")
    
    response.appendBody(string: returnStr)
    response.completed()
}


func sendRemoteConfig(request: HTTPRequest, _ response: HTTPResponse) {
    
    //let jsonStr = request.postBodyString //else {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    var returnStr =  ResultBody.successBody(value: "notCreated")
    
    if RCVersion.sendRemoteConfig(jsonString: jsonStr) {
   
        returnStr = ResultBody.successBody(value: "created")
    }
    
    response.appendBody(string: returnStr)
    response.completed()
}
