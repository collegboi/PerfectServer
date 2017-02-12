//
//  TranslationHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 04/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB


/// Defines and returns the Web Authentication routes
public func makeTranslationRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/translation/", handler: sendTranslation)
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/translation/{translation}/{version}", handler: getTranslationFile)
    //routes.add(method: .get, uri: "/translation/{translation}/{objectid}/", handler: getTrackerIssuesObject)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getTranslationFile(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let translationFilePath = request.urlVariables["translation"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing translation"))
        response.completed()
        return
    }
    
    guard let version = request.urlVariables["version"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing version"))
        response.completed()
        return
    }
    
    let returning = Translations.getTranslationFile(translationFilePath, version)
    
    response.appendBody(string: returning)
    response.completed()
}

//func getTrackerIssuesObject(request: HTTPRequest, _ response: HTTPResponse) {
//    
//    guard let collectionName = request.urlVariables["collection"] else {
//        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
//        response.completed()
//        return
//    }
//    
//    guard let documentObject = request.urlVariables["objectid"] else {
//        response.appendBody(string: ResultBody.errorBody(value: "no object id"))
//        response.completed()
//        return
//    }
//    
//    let returnObject = IssueTracker.getIssue(collectionName, documentObject)
//    
//    response.appendBody(string: returnObject)
//    response.completed()
//}


func sendTranslation(request: HTTPRequest, _ response: HTTPResponse) {
    
    //let jsonStr = request.postBodyString //else {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    var returnStr =  ResultBody.successBody(value: "created")
    
    Translations.postTranslationFile(jsonStr)
    
    returnStr = ResultBody.successBody(value: returnStr )
    
    response.appendBody(string: returnStr)
    response.completed()
}
