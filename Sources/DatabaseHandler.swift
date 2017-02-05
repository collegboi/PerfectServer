//
//  DatabaseHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 05/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB

/// Defines and returns the Web Authentication routes
public func makeDatabaseRoutes() -> Routes {
    var routes = Routes()

    //routes.add(method: .get, uri: "/storage/Tables", handler: mongoGetCollections)
    routes.add(method: .get, uri: "/storage/{collection}", handler: mongoHandler)
    routes.add(method: .get, uri: "/storage/{collection}/{objectid}", handler: mongoFilterHandler)
    routes.add(method: .post, uri: "/storage", handler: databasePost)
    routes.add(method: .post, uri: "/storage/{collection}", handler: databaseCollectionPost)
    routes.add(method: .delete, uri: "/storage/{collection}/{objectid}", handler: removeCollectionDoc)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func mongoGetCollections(request: HTTPRequest, _ response: HTTPResponse) {
    
    let returning = Storage.getAllCollections()
    
    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
}

func databasePost(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if Storage.parseAndStoreObject(jsonStr) {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    
    response.completed()
}

func databaseCollectionPost(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if Storage.StoreObject(collectionName, jsonStr) {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    response.completed()
}

func mongoFilterHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let objectID = request.urlVariables["objectid"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no objectID"))
        response.completed()
        return
    }
    
    let returning = DatabaseController.retrieveCollection(collectionName, objectID)
    
    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
    
}

func mongoHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    
    var returning = ResultBody.errorBody(value: "nocollections")
    
    if collectionName == "Tables" {
        returning = Storage.getAllCollections()
    } else {
        returning = DatabaseController.retrieveCollection(collectionName)
    }
    
    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
}

func removeCollectionDoc(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let objectID = request.urlVariables["objectid"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no objectID"))
        response.completed()
        return
    }
    
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !DatabaseController.remoteDocument(collectionName, objectID) {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()

}

