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
    
    routes.add(method: .post, uri: "/api/{appkey}/translation/", handler: sendTranslation)
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/api/{appkey}/translation/{language}/{version}", handler: getTranslationFile)
    routes.add(method: .get, uri: "/api/{appkey}/translationVersion/{language}/{langversion}", handler: getTranslationVersionFile)
    //routes.add(method: .get, uri: "/translation/{translation}/{objectid}/", handler: getTrackerIssuesObject)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func getTranslationVersionFile(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appKey = request.urlVariables["appkey"]  else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appKey"))
        response.completed()
        return
    }
    
    guard let language = request.urlVariables["language"]  else {
        response.appendBody(string: ResultBody.errorBody(value: "missing language"))
        response.completed()
        return
    }
    
    
    guard let langversion = request.urlVariables["langversion"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing version"))
        response.completed()
        return
    }
    
    let returning = Translations.getTranslationVersionFile(appKey, langversion, language)
    
    response.appendBody(string: returning)
    response.completed()
}

func getTranslationFile(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appKey = request.urlVariables["appkey"]  else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appKey"))
        response.completed()
        return
    }
    
    guard let language = request.urlVariables["language"]  else {
        response.appendBody(string: ResultBody.errorBody(value: "missing language"))
        response.completed()
        return
    }

    guard let version = request.urlVariables["version"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing version"))
        response.completed()
        return
    }
    
    let returning = Translations.getTranslationFile(appKey, version, language)
    
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
    
    guard let appKey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing apID"))
        response.completed()
        return
    }

    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    var returnStr =  ResultBody.successBody(value: "created")
    
    Translations.postTranslationFile(appKey, jsonStr)
    
    returnStr = ResultBody.successBody(value: returnStr )
    
    response.appendBody(string: returnStr)
    response.completed()
}
