//
//  LoginHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB
import Turnstile


/// Defines and returns the Web Authentication routes
public func makeLoginRoutes() -> Routes {
    var routes = Routes()
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/serverlogin/{username}/{password}", handler: serverLoginHandler)
    routes.add(method: .post, uri: "/serverRegister/", handler: serverRegisterHandler)
    //routes.add(method: .get, uri: "/login/{uniquekey}/{username}/{password}", handler: loginHandler)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func serverLoginHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let username = request.urlVariables["username"] else {
        response.appendBody(string: ResultBody.errorBody(value: "username missing"))
        response.completed()
        return
    }
    
    guard let password = request.urlVariables["password"] else {
        response.appendBody(string: ResultBody.errorBody(value: "password missing"))
        response.completed()
        return
    }
    
    if AuthenticationController.tryLoginWith(username, password: password) {
        response.appendBody(string: ResultBody.successBody(value: "success"))
    } else {
        response.appendBody(string: ResultBody.errorBody(value: "error"))
    }
    
    
    response.completed()
}

func serverRegisterHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    let returning = AuthenticationController.tryRegister(jsonStr)
    
    response.appendBody(string: ResultBody.successBody(value: returning))
    response.completed()
}
