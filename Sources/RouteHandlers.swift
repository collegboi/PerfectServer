//
//  RouteHandlers.swift
//  PerfectProject2
//
//  Created by Timothy Barnard on 19/01/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB

/// Defines and returns the Web Authentication routes
public func makeRoutes() -> Routes {
    var routes = Routes()
    
    
    routes.add(method: .get, uris: ["/", "index.html"], handler: indexHandler)
    routes.add(method: .get, uri: "/foo/*/baz", handler: echoHandler)
    routes.add(method: .get, uri: "/foo/bar/baz", handler: echoHandler)
    routes.add(method: .get, uri: "/user/{id}/baz", handler: echo2Handler)
    routes.add(method: .get, uri: "/user/{id}", handler: echo2Handler)
    routes.add(method: .post, uri: "/user/{id}/baz", handler: echo3Handler)
    
    
    // Test this one via command line with curl:
    // curl --data "{\"id\":123}" http://0.0.0.0:8181/raw --header "Content-Type:application/json"
    routes.add(method: .post, uri: "/raw", handler: rawPOSTHandler)
    
    // Trailing wildcard matches any path
    routes.add(method: .get, uri: "**", handler: echo4Handler)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func indexHandler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "Index handler: You accessed path \(request.path)")
    response.completed()
}
func echoHandler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "Echo handler: You accessed path \(request.path) with variables \(request.urlVariables)")
    response.completed()
}
func echo2Handler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "<html><body>Echo 2 handler: You GET accessed path \(request.path) with variables \(request.urlVariables)<br>")
    response.appendBody(string: "<form method=\"POST\" action=\"/user/\(request.urlVariables["id"] ?? "error")/baz\"><button type=\"submit\">POST</button></form></body></html>")
    response.completed()
}
func echo3Handler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "<html><body>Echo 3 handler: You POSTED to path \(request.path) with variables \(request.urlVariables)</body></html>")
    response.completed()
}
func echo4Handler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "<html><body>Echo 4 (trailing wildcard) handler: You accessed path \(request.path)</body></html>")
    response.completed()
}
func rawPOSTHandler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "<html><body>Raw POST handler: You POSTED to path \(request.path) with content-type \(request.header(.contentType)) and POST body \(request.postBodyString)</body></html>")
    response.completed()
}
